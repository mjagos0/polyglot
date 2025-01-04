from pathlib import Path
from datetime import datetime, timezone

from cassandra_connection import CASSANDRA_CONNECTION
from flask import Flask, request, jsonify

class CASSANDRA_SERVICE():
    _BASE_DIR = Path(__file__).resolve().parent
    _QUERIES_DIR = "cql"
    _OPS = {
        "CreateLog": _BASE_DIR / _QUERIES_DIR / "create_log.cql",
        "ReadLog": _BASE_DIR / _QUERIES_DIR / "read_log.cql"
    }

    def __init__(self):
        connection = CASSANDRA_CONNECTION("polyglot_logs")
        self.cassandra = connection.cluster

    def _fetch_query(self, op: str) -> str:
        if op not in self._OPS:
            raise KeyError(f"Operation '{op}' not found in available queries.")
        
        with open(self._OPS[op], 'r') as file:
            return file.read()
        
    def create_log(self, user_id: int, action: str, parameters: dict, tags: list) -> bool:
        query = self._fetch_query('CreateLog')
        current_time = datetime.now(timezone.utc)
        self.cassandra.execute(
            query, 
            (user_id, current_time, action, parameters, tags)
        )
 
        return True
    
    def read_log(self, user_id: int, limit: int = 10):
        output = []
        query = self._fetch_query('ReadLog')
        rows = self.cassandra.execute(
            query, 
            (user_id, limit)
        )
        for row in rows:
            output.append({
                "userId": row.userid,
                "timestamp": row.timestamp,
                "action": row.action,
                "parameters": dict(row.parameters) if row.parameters is not None else None,
                "tags": row.tags
            })

        return output


app = Flask(__name__)
cassandra_service = CASSANDRA_SERVICE()

@app.route('/log/create', methods=['POST'])
def log_create():
    try:
        params = request.json if request.is_json else {}
        user_id = params.get('user_id')
        action = params.get('action')
        tags = params.get('tags', [])
        parameters = params.get('parameters', {})

        if not user_id or not action:
            raise ValueError("Both 'user_id' and 'action' are required")
        if not isinstance(tags, list):
            raise ValueError("'tags' must be a list")
        
        if isinstance(parameters, dict):
            parameters = {k: str(v) for k, v in parameters.items()}
        else:
            raise ValueError("'parameters' must be a dictionary")

        result = cassandra_service.create_log(user_id, action, parameters, tags)
        return jsonify({"status": "success", "data": result}), 200
    except KeyError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    
@app.route('/log/read', methods=['GET'])
def log_read():
    try:
        user_id = request.args.get('user_id', type=int)
        limit = request.args.get('limit', type=int, default=10)

        if user_id is None:
            raise ValueError("'user_id' is required as a query parameter")

        result = cassandra_service.read_log(user_id, limit)
        return jsonify({"status": "success", "data": result}), 200
    except KeyError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/')
def health_check():
    return jsonify({"status": "running", "message": "CASSANDRA Service is active"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5004, debug=True)