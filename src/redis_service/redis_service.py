from flask import Flask, request, jsonify
import uuid
import json

from redis_connection import REDIS_CONNECTION

class REDIS_SERVICE:
    def __init__(self):
        connection = REDIS_CONNECTION()
        self.redis = connection.client

    def session_exists(self, session_id: str) -> bool:
        session = self.redis.get(f"session:{session_id}")
        return session is not None
    
    def user_has_active_session(self, user_id: int) -> bool:
        session_id = self.redis.hget(f"user:{user_id}", "session_id")
        if session_id is None:
            return False
        
        return self.session_exists(session_id)
    
    def create_session(self, user_id: int, timeout: int = 3600) -> str:
        session_id = str(uuid.uuid4())
        session_key = f"session:{session_id}"
        
        self.redis.setex(
            session_key,
            timeout,
            json.dumps({"user_id": user_id})
        )
        
        self.redis.hset(f"user:{user_id}", "session_id", session_id)
        return session_id
    
    def drop_session(self, user_id: int) -> bool:
        session_id = self.redis.hget(f"user:{user_id}", "session_id")
        if session_id:
            session_key = f"session:{session_id}"
            self.redis.delete(session_key)
            self.redis.hdel(f"user:{user_id}", "session_id")
            return True
        return False
    
    def create_shopping_cart(self, user_id: int) -> str:
        cart_id = str(uuid.uuid4())
        self.redis.hset(f"user:{user_id}", "cart_id", cart_id)

        return cart_id

    def delete_shopping_cart(self, user_id: int) -> bool:
        cart_id = self.redis.hget(f"user:{user_id}", "cart_id")
        if (cart_id):
            cart_id = f"cart:{cart_id}"
            self.redis.delete(cart_id)
            self.redis.hdel(f"user:{user_id}", "cart_id")
            return True
        return False

    def get_shopping_cart(self, user_id: int) -> str | None:
        return self.redis.hget(f"user:{user_id}", "cart_id")
    
    def cart_exists(self, user_id: int) -> str | None:
        return self.redis.hget(f"user:{user_id}", "cart_id") is not None

    def update_shopping_cart(self, user_id: str, product_id: int, quantity: int) -> bool:
        cart_id = self.get_shopping_cart(user_id)
        cart_key = f"cart:{cart_id}"
        new_quantity = self.redis.hincrby(cart_key, product_id, quantity)

        if new_quantity <= 0:
            self.redis.hdel(cart_key, product_id)
    
        return self.read_shopping_cart(user_id)
    
    def read_shopping_cart(self, user_id) -> bool:
        cart_id = self.get_shopping_cart(user_id)
        cart_key = f"cart:{cart_id}"
        return self.redis.hgetall(cart_key)


app = Flask(__name__)
redis_service = REDIS_SERVICE()

@app.route('/session/create_session', methods=['POST'])
def create_session():
    try:
        params = request.json if request.is_json else {}
        user_id = params.get('user_id')
        timeout = params.get('timeout', 3600)
        
        if not isinstance(user_id, int):
            raise ValueError("'user_id' must be an integer")
        
        result = redis_service.create_session(user_id, timeout)
        return jsonify({"status": "success", "data": result}), 200
    except KeyError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    
@app.route('/session/session_exists', methods=['GET'])
def session_exists():
    try:
        session_id = request.args.get('session_id', type=str)
        
        if session_id is None:
            raise ValueError("'session_id' is required")
        
        result = redis_service.session_exists(session_id)
        return jsonify({"status": "success", "data": result}), 200
    
    except ValueError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    
@app.route('/session/user_has_active_session', methods=['GET'])
def user_has_active_session():
    try:
        user_id = request.args.get('user_id', type=int)
        
        if user_id is None:
            raise ValueError("'user_id' is required")
        
        result = redis_service.user_has_active_session(user_id)
        return jsonify({"status": "success", "data": result}), 200
    
    except ValueError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/session/drop_session', methods=['POST'])
def drop_session():
    try:
        params = request.json if request.is_json else {}
        user_id = params.get('user_id')
        
        if not isinstance(user_id, int):
            raise ValueError("'user_id' must be an integer")
        
        success = redis_service.drop_session(user_id)
        if success:
            return jsonify({"status": "success", "message": "Session dropped successfully"}), 200
        else:
            return jsonify({"status": "error", "message": "Session does not exist or could not be dropped"}), 400
    
    except ValueError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    
@app.route('/cart/create', methods=['POST'])
def create_cart():
    try:
        params = request.json if request.is_json else {}
        user_id = params.get('user_id')
        
        if not isinstance(user_id, int):
            raise ValueError("'user_id' must be an integer")
        
        cart_id = redis_service.create_shopping_cart(user_id)
        return jsonify({"status": "success", "data": cart_id}), 200
    
    except ValueError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/cart/delete', methods=['POST'])
def delete_cart():
    try:
        params = request.json if request.is_json else {}
        user_id = params.get('user_id')
        
        if not isinstance(user_id, int):
            raise ValueError("'user_id' must be an integer")
        
        success = redis_service.delete_shopping_cart(user_id)
        return jsonify({"status": "success", "data": success}), 200
    except ValueError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/cart/get', methods=['GET'])
def get_cart():
    try:
        user_id = request.args.get('user_id', type=int)
        
        if user_id is None:
            raise ValueError("'user_id' is required")
        
        cart_id = redis_service.get_shopping_cart(user_id)
        return jsonify({"status": "success", "data": cart_id}), 200

    except ValueError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    
@app.route('/cart/exists', methods=['GET'])
def cart_exists():
    try:
        user_id = request.args.get('user_id', type=int)
        
        if user_id is None:
            raise ValueError("'user_id' is required")
        
        exists = redis_service.cart_exists(user_id)
        return jsonify({"status": "success", "data": exists}), 200
    
    except ValueError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/cart/update', methods=['POST'])
def update_cart():
    try:
        params = request.json if request.is_json else {}
        user_id = params.get('user_id')
        product_id = params.get('product_id')
        quantity = params.get('quantity')
        
        if not all(isinstance(x, (int, str)) for x in [user_id, product_id]) or not isinstance(quantity, int):
            raise ValueError("'user_id' and 'product_id' must be a string/int, and 'quantity' must be an integer.")
        
        result = redis_service.update_shopping_cart(user_id, product_id, quantity)
        return jsonify({"status": "success", "data": result}), 200
    
    except ValueError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

    
@app.route('/cart/read', methods=['GET'])
def read_cart():
    try:
        user_id = request.args.get('user_id', type=int)
        
        if user_id is None:
            raise ValueError("'user_id' is required")
        
        result = redis_service.read_shopping_cart(user_id)
        return jsonify({"status": "success", "data": result}), 200
    
    except ValueError as e:
        return jsonify({"status": "error", "message": str(e)}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/')
def health_check():
    return jsonify({"status": "running", "message": "REDIS Service is active"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=True)