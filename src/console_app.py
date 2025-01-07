import requests
import logging
from functools import wraps

ENDPOINTS = {
    'PSQL': 'http://127.0.0.1:5001',
    'REDIS': 'http://127.0.0.1:5002',
    'MONGODB': 'http://127.0.0.1:5003',
    'CASSANDRA': 'http://127.0.0.1:5004',
    'NEO4J': 'http://127.0.0.1:5005'
}

SERVICES = {
    'PSQL': {
        'CheckHealth': ENDPOINTS['PSQL'] + '/',
        'FetchProducts': ENDPOINTS['PSQL'] + '/fetch_products',
        'UserLogin': ENDPOINTS['PSQL'] + '/user_login',
        'GetUserId': ENDPOINTS['PSQL'] + '/get_user_id',
        'IsAdmin': ENDPOINTS['PSQL'] + '/is_admin'
    },
    'REDIS': {
        'CheckHealth': ENDPOINTS['REDIS'] + '/',
        'CreateSession': ENDPOINTS['REDIS'] + '/session/create_session',
        'DropSession': ENDPOINTS['REDIS'] + '/session/drop_session',
        'SessionExists': ENDPOINTS['REDIS'] + '/session/session_exists',
        'UserHasActiveSession': ENDPOINTS['REDIS'] + '/session/user_has_active_session',
        'CreateCart': ENDPOINTS['REDIS'] + '/cart/create',
        'DeleteCart': ENDPOINTS['REDIS'] + '/cart/delete',
        'GetCart': ENDPOINTS['REDIS'] + '/cart/get',
        'UpdateCart': ENDPOINTS['REDIS'] + '/cart/update',
        'CartExists': ENDPOINTS['REDIS'] + '/cart/exists',
        'CartRead': ENDPOINTS['REDIS'] + '/cart/read'
    },
    'MONGODB': {
        'CheckHealth': ENDPOINTS['MONGODB'] + '/',
        'StatementCreate': ENDPOINTS['MONGODB'] + '/statement/create',
        'StatementGet': ENDPOINTS['MONGODB'] + '/statement/get',
        'StatementRead': ENDPOINTS['MONGODB'] + '/statement/read'
    },
    'CASSANDRA': {
        'CheckHealth': ENDPOINTS['CASSANDRA'] + '/',
        'LogCreate': ENDPOINTS['CASSANDRA'] + '/log/create',
        'LogRead': ENDPOINTS['CASSANDRA'] + '/log/read'
    },
    'NEO4J': {
        'CheckHealth': ENDPOINTS['NEO4J'] + '/',
        'FollowUser': ENDPOINTS['NEO4J'] + '/user/follow',
        'Purchase': ENDPOINTS['NEO4J'] + '/user/purchase',
        'Recommend': ENDPOINTS['NEO4J'] + '/user/recommend'
    }
}

class ConsoleApp:
    def __init__(self):
        self.active_user = None
        self.active_user_id = -1
        self.active_session = None
        self.active_cart = None
        self.is_admin = False

        self._check_health()
    
    # Service
    def _check_health(self):
        self.psql_health = self._check_service_health('PSQL')
        self.redis_health = self._check_service_health('REDIS')
        self.mongodb_health = self._check_service_health('MONGODB')
        self.cassandra_health = self._check_service_health('CASSANDRA')
        self.neo4j_health = self._check_service_health('NEO4J')

        if not self.psql_health:
            logging.warning("Products & Logins are unavailable, PSQL service is down")

        if not self.redis_health:
            logging.warning("Cart & Sessions are unavailable, REDIS service is down")

        if not self.mongodb_health:
            logging.warning("Statements are unavailable, MONGODB service is down")

        if not self.cassandra_health:
            logging.warning("Logs are unavailable, CASSANDRA service is down")

        if not self.neo4j_health:
            logging.warning("Recommendations are unavailable, NEO4J service is down")

    def _check_service_health(self, endpoint: str) -> bool:
        try:
            resp = requests.get(self._service(endpoint, 'CheckHealth'), timeout=5)
            if resp.status_code == 200:
                data = resp.json()
                return data.get("status") == "running"
            
            return False

        except (requests.ConnectionError, requests.Timeout) as e:
            return False
        except requests.RequestException as e:
            return False

    def _service(self, endpoint: str, service: str) -> str:
        if (endpoint_url := SERVICES.get(endpoint)) is None:
            raise RuntimeError(f"Endpoint {endpoint} is not available")
        
        if (service_url := endpoint_url.get(service)) is None:
            raise RuntimeError(f"Service {service} is not available")
        
        return service_url
        
    # User
    def _get_user_id(self, user_name: str) -> str:
        if (user_name is None):
            raise ValueError("user_name is None")

        resp = requests.get(
            self._service('PSQL', 'GetUserId'),
            json={
                "user_name": user_name,
            }
        )
        resp.raise_for_status()
        return resp.json()['data']
    
    def _user_login(self,  user_name: str, user_password: str) -> bool:
        resp = requests.post(
            self._service('PSQL', 'UserLogin'),
            json={
                "user_name": user_name,
                "user_password": user_password
            }
        )
        resp.raise_for_status()
        return resp.json()['data']
    
    def _is_admin(self, user_name: str) -> str:
        if (user_name is None):
            raise ValueError("user_name is None")

        resp = requests.get(
            self._service('PSQL', 'IsAdmin'),
            params={
                "user_name": user_name,
            }
        )
        
        resp.raise_for_status()
        return resp.json()['data']
    
    # Products
    def _fetch_products(self, filter: dict) -> dict:
        resp = requests.get(
            self._service('PSQL', 'FetchProducts'),
            json=filter
        )
        resp.raise_for_status()
        return resp.json()['data']

    # Session
    def _create_session(self, user_id: int) -> str:
        resp = requests.post(
            self._service('REDIS', 'CreateSession'),
            json={'user_id': user_id}
        )
        
        resp.raise_for_status()
        return resp.json()['data']
        
    def _drop_session(self, user_id: int) -> None:
        resp = requests.post(
            self._service('REDIS', 'DropSession'),
            json={'user_id': user_id}
        )
        
        resp.raise_for_status()
        return None
    
    def _session_exists(self, session_id: str) -> bool:
        if session_id is None:
            return False
        
        resp = requests.get(
            self._service('REDIS', 'SessionExists'),
            params={
                'session_id': session_id
            }
        )
        resp.raise_for_status() 
        return resp.json()['data']

    def _user_has_active_session(self, user_id: int) -> bool:
        resp = requests.get(
            self._service('REDIS', 'UserHasActiveSession'),
            params={
                'user_id': user_id
            }
        )
        resp.raise_for_status() 
        return resp.json()['data']

    # Cart
    def _create_cart(self, user_id: int) -> str:
        resp = requests.post(
            self._service('REDIS', 'CreateCart'),
            json={
                'user_id': user_id
            }
        )
        resp.raise_for_status()
        return resp.json()['data']

    def _drop_cart(self, user_id: int) -> str | None:
        resp = requests.post(
            self._service('REDIS', 'DeleteCart'),
            json={
                'user_id': user_id
            }
        )
        resp.raise_for_status()
        return None

    def _get_user_cart(self, user_id: int) -> str:
        resp = requests.get(
            self._service('REDIS', 'GetCart'),
            params={
                'user_id': user_id
            }
        )
        resp.raise_for_status()
        return resp.json()['data']

    def _user_cart_exists(self, user_id: int) -> str:
        resp = requests.get(
            self._service('REDIS', 'CartExists'),
            params={
                'user_id': user_id
            }
        )
        resp.raise_for_status()
        return resp.json()['data']

    def _cart_update(self, user_id: int, product_id: int, quantity: int) -> str:
        resp = requests.post(
            self._service('REDIS', 'UpdateCart'),
            json={
                'user_id': user_id,
                'product_id': product_id,
                'quantity': quantity
            }
        )
        resp.raise_for_status()
        return {int(k): int(v) for k, v in resp.json()['data'].items()}

    def _cart_read(self, user_id: int) -> dict:
        resp = requests.get(
            self._service('REDIS', 'CartRead'),
            params={
                'user_id': user_id
            }
        )
        resp.raise_for_status()
        return {int(k): int(v) for k, v in resp.json()['data'].items()}
    
    # Statements
    def _create_statement(self, user_id: int, purchase: dict) -> bool:
        resp = requests.post(
            self._service('MONGODB', 'StatementCreate'),
            json={
                'user_id': user_id,
                'purchase': purchase
            }
        )
        resp.raise_for_status()
        return resp.json()['data']
    
    def _get_statements(self, user_id: int) -> list:
        resp = requests.get(
            self._service('MONGODB', 'StatementGet'),
            params={
                'user_id': user_id
            }
        )
        resp.raise_for_status()
        return resp.json()['data']
    
    def _read_statement(self, statement_id: int) -> dict:
        resp = requests.get(
            self._service('MONGODB', 'StatementRead'),
            params={
                'statement_id': statement_id
            }
        )
        resp.raise_for_status()
        statement = resp.json()['data']
        statement['purchase'] = {int(k): int(v) for k, v in statement['purchase'].items()}
        return statement
    
    # Logs
    def _create_log(self, user_id: int, action: str, parameters: dict, tags: list) -> bool:
        if not self.cassandra_health:
            return
        
        resp = requests.post(
            self._service('CASSANDRA', 'LogCreate'),
            json={
                'user_id': user_id,
                'action': action,
                'tags': tags,
                'parameters': parameters
            }
        )
        resp.raise_for_status()
        return resp.json()['data']
    
    def _read_log(self, user_id: int, limit: int = 10) -> list:
        resp = requests.get(
            self._service('CASSANDRA', 'LogRead'),
            params={
                'user_id': user_id,
                'limit': limit
            }
        )
        resp.raise_for_status()
        return resp.json()['data']
    
    # Recommendatations
    def _follow_user(self, user_id_from: int, user_id_to: int):
        resp = requests.post(
            self._service('NEO4J', 'FollowUser'),
            json={
                'user_id_from': user_id_from,
                'user_id_to': user_id_to
            }
        )
        resp.raise_for_status()
        return resp.json()['data']
    
    def _purchase(self, user_id: int, product_id: int):
        resp = requests.post(
            self._service('NEO4J', 'Purchase'),
            json={
                'user_id': user_id,
                'product_id': product_id
            }
        )
        resp.raise_for_status()
        return resp.json()['data']
    
    def _recommend(self, user_id: int):
        resp = requests.get(
            self._service('NEO4J', 'Recommend'),
            params={
                'user_id': user_id
            }
        )
        resp.raise_for_status()
        return resp.json()['data']
    
    # User
    def fetch_products(self, filter: dict = None) -> dict:
        if not self.psql_health:
            raise RuntimeError("Cannot fetch products, PSQL service is down")
        
        if filter is None:
            filter = {}
        self._create_log(self.active_user_id, "fetch_products", filter, ["PSQL"])
        return self._fetch_products(filter)

    def login(self, user_name: str, user_password: str) -> str:
        if not self.psql_health:
            raise RuntimeError("Cannot login, PSQL service is down")
        
        self._create_log(self.active_user_id, "login", {'user_name': user_name}, ["PSQL"])
        if (self.active_session):
            return f"Already logged in as {self.active_user}"

        if (not self._user_login(user_name, user_password)):
            self._create_log(self.active_user_id, "Login Fail", {}, ["PSQL"])
            return "Incorrect credentials"

        self.active_user = user_name
        self.active_user_id = self._get_user_id(self.active_user)
        self.is_admin = self._is_admin(self.active_user)
        self.active_session = self._create_session(self.active_user_id)
        if (self._user_cart_exists(self.active_user_id)):
            self.active_cart = self._get_user_cart(self.active_user_id)
        else:
            self.active_cart = self._create_cart(self.active_user_id)

        self._create_log(self.active_user_id, "Login Success", {
            'user': self.active_user, 
            'session': self.active_session,
            'cart': self.active_cart
        }, ["PSQL"])
            
        return f"Welcome back {user_name}"
    
    def logout(self):
        if not self.psql_health:
            raise RuntimeError("Cannot logout, PSQL service is down")
        
        self._create_log(self.active_user_id, "logout", {}, ["PSQL"])
        if self.active_session is None:
            self._create_log(self.active_user, "Logout Fail", {'user': self.active_user}, ["PSQL"])
            return "No active session"
        
        log_user = self.active_user
        self._drop_session(self.active_user_id)
        self.active_cart = None
        self.active_session = None
        self.is_admin = False
        self.active_user_id = -1
        self.active_user = None
        
        self._create_log(self.active_user_id, "Logout Success", {'user': log_user}, ["PSQL"])

        return f"User {log_user} logged out"

    def update_cart(self, product_id, quantity):
        if not self.redis_health:
            raise RuntimeError("Cannot update cart, REDIS service is down")
        
        if self.active_session is None:
            return "No active session"

        self._create_log(self.active_user_id, "Update Cart", {'product_id': product_id, 'quantity': quantity}, ["REDIS"])
        return self._cart_update(self.active_user_id, product_id, quantity)

    def purchase(self) -> str:
        if not self.redis_health or not self.mongodb_health:
            raise RuntimeError("Cannot purchase, REDIS or MONGODB service is down")
        
        if self.active_session is None:
            return "No active session"
        
        cart_contents = self._cart_read(self.active_user_id)
        if (len(cart_contents.keys()) == 0):
            return "Cart is empty"
        
        for i in cart_contents.keys():
            self._purchase(self.active_user_id, i)

        statement_id = self._create_statement(self.active_user_id, cart_contents)
        self._drop_cart(self.active_user_id)
        self._create_cart(self.active_user_id)
        self._create_log(self.active_user_id, "Purchase", {'cart_contents': cart_contents}, ["REDIS"])
        return statement_id

    def read_cart(self) -> dict:
        if not self.redis_health:
            raise RuntimeError("Cannot read cart, REDIS service is down")
        
        if self.active_session is None:
            return "No active session"
        
        self._create_log(self.active_user_id, "Read Cart", {}, ["REDIS"])
        return self._cart_read(self.active_user_id)
    
    def clear_cart(self) -> str:
        if not self.redis_health:
            raise RuntimeError("Cannot clear cart, REDIS service is down")
        
        if self.active_session is None:
            return "No active session"

        self._create_log(self.active_user_id, "Clear Cart", {}, ["REDIS"])
        self._drop_cart(self.active_user_id)
        self._create_cart(self.active_user_id)

        return self._cart_read(self.active_user_id)

    def get_statements(self) -> list:
        if not self.mongodb_health:
            raise RuntimeError("Cannot get statements, MONGODB service is down")
        
        if self.active_session is None:
            return "No active session"
        
        self._create_log(self.active_user_id, "Get Statements", {}, ["MONGODB"])        
        return self._get_statements(self.active_user_id)

    def read_statement(self, statement_id: int) -> dict:
        if not self.mongodb_health:
            raise RuntimeError("Cannot read statements, MONGODB service is down")
        
        if self.active_session is None:
            return "No active session"
        
        self._create_log(self.active_user_id, "Read Statement", {'statement_id': statement_id}, ["MONGODB"])
        user_statements = self.get_statements()
        if (statement_id not in user_statements):
            self._create_log(self.active_user_id, "Read Statement Fail", {'statement_id': statement_id}, ["MONGODB"])
            return f"Statement {statement_id} does not belong to {self.active_user}"

        
        self._create_log(self.active_user_id, "Read Statement Success", {'statement_id': statement_id}, ["MONGODB"])
        return self._read_statement(statement_id)
    
    def read_log(self, user_id, limit = 10):
        if not self.cassandra_health:
            raise RuntimeError("Cannot read log, CASSANDRA service is down")
        
        if self.active_session is None:
            return "No active session"
        
        self._create_log(self.active_user_id, "Read Logs", {'filter': {'user_name': user_id}}, ["MONGODB"])
        return self._read_log(user_id, limit)
    
    def follow(self, user_id):
        if not self.neo4j_health:
            raise RuntimeError("Cannot follow user, NEO4J service is down")
        
        if self.active_session is None:
            return "No active session"
        
        self._create_log(self.active_user_id, "Follow User", {'filter': {'user_id': user_id}}, ["NEO4J"])
        return self._follow_user(self.active_user_id, user_id)
    
    def get_recommendation(self):
        if not self.neo4j_health:
            raise RuntimeError("Cannot follow user, NEO4J service is down")
        
        if self.active_session is None:
            return "No active session"
        
        self._create_log(self.active_user_id, "Getting recommendations", {}, ["NEO4J"])
        self._recommend(self.active_user_id)


app = ConsoleApp()
fetch_products = app.fetch_products
login = app.login
logout = app.logout
read_cart = app.read_cart
update_cart = app.update_cart
clear_cart = app.clear_cart
purchase = app.purchase
get_statements = app.get_statements
read_statement = app.read_statement
read_log = app.read_log
follow = app.follow
get_recommendation = app.get_recommendation
