from pathlib import Path

from psql_connection import PSQL_CONNECTION
from flask import Flask, request, jsonify

class PSQL_SERVICE:
    _BASE_DIR = Path(__file__).resolve().parent
    _QUERIES_DIR = "sql"
    _OPS = {
        "FetchProducts": _BASE_DIR / _QUERIES_DIR / "fetch_products.sql",
        "UserLogin": _BASE_DIR / _QUERIES_DIR / "user_login.sql",
        "GetUserId": _BASE_DIR / _QUERIES_DIR / "get_user_id.sql",
        "IsAdmin": _BASE_DIR / _QUERIES_DIR / "is_admin.sql"
    }

    def __init__(self):
        self.psql = PSQL_CONNECTION()

    def _fetch_query(self, op: str) -> str:
        if op not in self._OPS:
            raise KeyError(f"Operation '{op}' not found in available queries.")
        
        with open(self._OPS[op], 'r') as file:
            return file.read()

    def fetch_products(self, filter: dict = {}) -> list:
        query = self._fetch_query("FetchProducts")
        params = {}

        for key in filter.keys():
            match (key):
                case "id":
                    query += f"\nAND p.id = %(id)s"
                    params['id'] = filter['id']
                case "vendor":
                    query += f"\nAND v.vendor = %(vendor)s"
                    params['vendor'] = filter['vendor']
                case "product_type":
                    query += f"\nAND pt.product_type = %(product_type)s"
                    params['product_type'] = filter['product_type']
                case "product_condition":
                    query += f"\nAND pc.product_condition = %(product_condition)s"
                    params['product_condition'] = filter['product_condition']
                case "mpn":
                    query += f"\nAND p.mpn = %(mpn)s"
                    params['mpn'] = filter['mpn']
                case "product_warranty":
                    query += f"\nAND p.product_warranty = %(product_warranty)s"
                    params['product_warranty'] = filter['product_warranty']
                case "product_warranty_min":
                    query += f"\nAND p.product_warranty >= %(product_warranty_min)s"
                    params['product_warranty_min'] = filter['product_warranty_min']
                case "product_warranty_max":
                    query += f"\nAND p.product_warranty <= %(product_warranty_max)s"
                    params['product_warranty_max'] = filter['product_warranty_max']
                case "stock_quantity":
                    query += f"\nAND p.stock_quantity = %(stock_quantity)s"
                    params['stock_quantity'] = filter['stock_quantity']
                case "stock_quantity_min":
                    query += f"\nAND p.stock_quantity >= %(stock_quantity_min)s"
                    params['stock_quantity_min'] = filter['stock_quantity_min']
                case "stock_quantity_max":
                    query += f"\nAND p.stock_quantity <= %(stock_quantity_max)s"
                    params['stock_quantity_max'] = filter['stock_quantity_max']
                case "price":
                    query += f"\nAND p.price = %(price)s"
                    params['price'] = filter['price']
                case "price_min":
                    query += f"\nAND p.price >= %(price_min)s"
                    params['price_min'] = filter['price_min']
                case "price_max":
                    query += f"\nAND p.price <= %(price_max)s"
                    params['price_max'] = filter['price_max']
                case "Disk Type":
                    query += f"\nAND p.attributes->>'Disk Type' = %(Disk Type)s"
                    params['Disk Type'] = filter['Disk Type']
                case "Disk Storage Size":
                    query += f"\nAND p.attributes->>'Disk Storage Size' = %(Disk Storage Size)s"
                    params['Disk Storage Size'] = filter['Disk Storage Size']
                case "RAM Size":
                    query += f"\nAND p.attributes->>'RAM Size' = %(RAM Size)s"
                    params['RAM Size'] = filter['RAM Size']
                case "Screen Size":
                    query += f"\nAND p.attributes->>'Screen Size' = %(Screen Size)s"
                    params['Screen Size'] = filter['Screen Size']
                case "Operating system":
                    query += f"\nAND p.attributes->>'Operating system' = %(Operating system)s"
                    params['Operating system'] = filter['Operating system']
                case "Processor Name":
                    query += f"\nAND p.attributes->>'Processor Name' = %(Processor Name)s"
                    params['Processor Name'] = filter['Processor Name']
            
        query = query.replace("AND", "WHERE", 1)
        return self.psql.execute_query(query, params)
    
    def user_login(self, user_name: str, user_password: str) -> bool:
        query = self._fetch_query("UserLogin")
        params = {'user_name': user_name, 'user_password': user_password}
        result = self.psql.execute_query(query, params)
        if not len(result):
            return False
        else:
            return result[0][0]
    
    def get_user_id(self, user_name: str) -> str:
        query = self._fetch_query("GetUserId")
        params = {'user_name': user_name}
        return self.psql.execute_query(query, params)[0][0]
    
    def is_admin(self, user_name: str) -> str:
        query = self._fetch_query("IsAdmin")
        params = {'user_name': user_name}
        return self.psql.execute_query(query, params)[0][0]


app = Flask(__name__)
psql_service = PSQL_SERVICE()

@app.route('/fetch_products', methods=['GET'])
def fetch_products():
    try:
        params = request.json if request.is_json else {}
        result = psql_service.fetch_products(params)
        return jsonify({"status": "success", "data": result}), 200
    except KeyError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    
@app.route('/get_user_id', methods=['GET'])
def get_user_id():
    try:
        params = request.json if request.is_json else {}
        
        user_name = params.get('user_name')
        if not user_name:
            raise ValueError("'user_name' is required.")

        result = psql_service.get_user_id(user_name)
        return jsonify({"status": "success", "data": result}), 200
    except KeyError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    
@app.route('/is_admin', methods=['GET'])
def is_admin():
    try:
        user_name = request.args.get('user_name')
        if not user_name:
            raise ValueError("'user_name' is required.")

        result = psql_service.is_admin(user_name)
        return jsonify({"status": "success", "data": result}), 200
    except KeyError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

    
@app.route('/user_login', methods=['POST'])
def user_login():
    try:
        params = request.json if request.is_json else {}
        user_name = params.get('user_name')
        user_password = params.get('user_password')
        
        if not user_name or not user_password:
            raise ValueError("Both 'user_name' and 'user_password' are required.")
        
        result = psql_service.user_login(user_name, user_password)
        return jsonify({"status": "success", "data": result}), 200
    
    except KeyError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/')
def health_check():
    return jsonify({"status": "running", "message": "PSQL Service is active"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)