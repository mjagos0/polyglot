import redis
import keyring

REDIS_PARAMS = {
    "host": "localhost",
    "port": 6398,
    "decode_responses": True,
    "password": keyring.get_password("db2", "f24_jagosmar")
}

def redis_service() {
    r = redis.Redis(**REDIS_PARAMS)
}

