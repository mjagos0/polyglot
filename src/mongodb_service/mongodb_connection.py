from pymongo import MongoClient

class MONGODB_CONNECTION:
    MONGODB_PARAMS = {
        "host": "localhost",
        "port": 27017
    }

    def __init__(self):
        self.connect()

    def connect(self):
        self.client = MongoClient(**self.MONGODB_PARAMS)