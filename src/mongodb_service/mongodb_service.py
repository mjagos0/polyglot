from datetime import datetime, timezone
from pymongo import ReturnDocument
from flask import Flask, request, jsonify

from mongodb_connection import MONGODB_CONNECTION

class MONGODB_SERVICE():
    def __init__(self):
        connection = MONGODB_CONNECTION()
        self.mongodb = connection.client['polyglot']

    def _get_next_id(self) -> int:
        counter = self.mongodb['counters'].find_one_and_update(
            {'_id': 'statement_id'},
            {'$inc': {'seq': 1}},
            upsert=True,
            return_document=ReturnDocument.AFTER
        )
        return counter['seq']

    def create_statement(self, user_id: int, purchase: dict) -> int:
        statement_id = self._get_next_id()

        statement = {
            "_id": statement_id,
            "user_id": user_id,
            "purchase": purchase,
            "creation_date": datetime.now(timezone.utc)
        }
        
        self.mongodb['statements'].insert_one(statement)
        return statement_id
    
    def get_statements(self, user_id: int) -> tuple:
        statements = self.mongodb['statements'].find(
                {"user_id": user_id},
                {"_id": 1}  # Only retrieve the _id field
            )
        return [x['_id'] for x in statements]

    def read_statement(self, statement_id: int):
        statement = self.mongodb['statements'].find_one(
                {"_id": statement_id},
        )
        return statement

    
app = Flask(__name__)
mongodb_service = MONGODB_SERVICE()

@app.route('/statement/create', methods=['POST'])
def statement_create():
    try:
        params = request.json if request.is_json else {}
        user_id = params.get('user_id')
        purchase = params.get('purchase')

        result = mongodb_service.create_statement(user_id, purchase)
        return jsonify({"status": "success", "data": result}), 200
    except KeyError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    
@app.route('/statement/get', methods=['GET'])
def statement_get():
    try:
        user_id = request.args.get('user_id', type=int)

        result = mongodb_service.get_statements(user_id)
        return jsonify({"status": "success", "data": result}), 200
    except KeyError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    
@app.route('/statement/read', methods=['GET'])
def statement_read():
    try:
        statement_id = request.args.get('statement_id', type=int)
        result = mongodb_service.read_statement(statement_id)
        if (result is None):
            raise KeyError(f"Statement {statement_id} does not exist")

        return jsonify({"status": "success", "data": result}), 200
    except KeyError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/')
def health_check():
    return jsonify({"status": "running", "message": "MONGODB Service is active"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003, debug=True)