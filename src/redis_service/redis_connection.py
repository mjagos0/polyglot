import redis

class REDIS_CONNECTION:
    REDIS_PARAMS = {
        "host": "localhost",
        "port": 6379,
        "decode_responses": True,
    }

    def __init__(self):
        self.client = self.connect()

    def connect(self) -> redis.Redis:
        return redis.Redis(**self.REDIS_PARAMS)
