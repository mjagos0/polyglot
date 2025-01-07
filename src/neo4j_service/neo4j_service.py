from pathlib import Path
from flask import Flask, request, jsonify
import uuid
import json

from neo4j_connection import NEO4J_CONNECTION

class NEO4J_SERVICE:
    _BASE_DIR = Path(__file__).resolve().parent
    _QUERIES_DIR = "cypher"
    _OPS = {
        "Follow": _BASE_DIR / _QUERIES_DIR / "follow.cypher",
        "Purchase": _BASE_DIR / _QUERIES_DIR / "purchase.cypher",
        "GetRecommendation": _BASE_DIR / _QUERIES_DIR / "recommend.cypher"
    }

    def __init__(self):
        connection = NEO4J_CONNECTION()
        self.neo4j = connection.client

    def _fetch_query(self, op: str) -> str:
        if op not in self._OPS:
            raise KeyError(f"Operation '{op}' not found in available queries.")
        
        with open(self._OPS[op], 'r') as file:
            return file.read()

    def follow(self, user_id_from: int, user_id_to: int):
        params = {"user_id_from": user_id_from, "user_id_to": user_id_to}
        query = self._fetch_query("Follow")
        self.neo4j.execute_query(query, params)

        return True
    
    def purchase(self, user_id: int, product_id: int):
        params = {"user_id": user_id, "product_id": product_id}
        query = self._fetch_query("Purchase")
        self.neo4j.execute_query(query, params)

        return True

    def recommend(self, user_id: int):
        params = {"user_id": user_id}
        query = self._fetch_query("GetRecommendation")
        result = self.neo4j.execute_query(query, params)
        
        return [record['id'] for record in result.records]

app = Flask(__name__)
neo4j_service = NEO4J_SERVICE()

@app.route('/user/follow', methods=['POST'])
def user_follow():
    try:
        params = request.json if request.is_json else {}
        user_id_from = params.get('user_id_from')
        user_id_to = params.get('user_id_to')

        if user_id_from is None or user_id_to is None:
            raise ValueError("Two user_ids are required to perform this operation")

        result = neo4j_service.follow(user_id_from, user_id_to)
        return jsonify({"status": "success", "data": result}), 200
    except KeyError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    
@app.route('/user/purchase', methods=['POST'])
def user_purchase():
    try:
        params = request.json if request.is_json else {}
        user_id = params.get('user_id')
        product_id = params.get('product_id')

        if user_id is None or product_id is None:
            raise ValueError("Purchase requires 'user_id' and 'laptop_id' parameters")

        result = neo4j_service.purchase(user_id, product_id)
        return jsonify({"status": "success", "data": result}), 200
    except KeyError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    
@app.route('/user/recommend', methods=['GET'])
def user_recommend():
    try:
        user_id = request.args.get('user_id', type=int)

        if user_id is None:
            raise ValueError("Recommend requires 'user_id' parameter")

        result = neo4j_service.recommend(user_id)
        return jsonify({"status": "success", "data": result}), 200
    except KeyError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/')
def health_check():
    return jsonify({"status": "running", "message": "NEO4J Service is active"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5005, debug=True)