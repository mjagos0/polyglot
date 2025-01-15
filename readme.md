# Polyglot Project

## Overview
The **Polyglot Project** is an application designed to demonstrate polyglot persistence by utilizing multiple database systems for different tasks. The system is built to handle the operations of an **online store specializing in used and refurbished laptops**.

## Functional Requirements
The application provides the following core functionalities:
- Product browsing and filtering
- User activity logging
- Session management
- Caching
- User accounts management
- Shopping cart operations
- Purchase history tracking

## Database System Utilization
Different databases are used for specific tasks to optimize performance and scalability:

- **PostgreSQL**: Product inventory, user accounts
- **Redis**: User sessions, shopping carts, caching
- **MongoDB**: Purchase history
- **Cassandra**: Activity logs
- **Neo4j**: Personalized recommendations

## Technology Stack
- **Backend Framework:** Python (Flask)
- **Containerization:** Docker Compose
- **Databases:** PostgreSQL, Redis, MongoDB, Cassandra, Neo4j
- **Communication:** REST APIs

## Architecture
- Each database connection is encapsulated in a microservice.
- Microservices expose API routes for database-specific operations.
- The main application interacts with microservices via HTTP requests.

## Prerequisites
1. [Docker](https://docs.docker.com/get-docker/):
   ```bash
   docker --version
   ```

2. Supported Python version:
   ```
   python --version
   pip --version
   ```

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/mjagos0/polyglot_project.git
   cd polyglot_project
   ```
2. Create a Python virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Run the application:
   ```bash
   source run_app.sh
   ```

## Testing
The application includes a testing pipeline:
- **Unit Tests:** Test individual microservices and functions
- **Integration Tests:** Validate interaction between microservices
- **User Tests:** Simulate user-level operations

Run tests using (application must be running):
```bash
./run_tests.sh
```

## Console Application
An interactive Python console session is available for user interaction. Example commands include:
- `fetch_products`
- `login`
- `logout`
- `update_cart`
- `purchase`
- `get_statements`
- `read_statement`
- `read_log`
- `follow`
- `get_recommendations`

### Example Interaction
```python
fetch_products({"vendor": "HP", "product_condition": "Excellent", "Screen Size": "15.6"})
> [
   [
      5,
      "HP",
      "Refurbished Laptop",
      "Excellent",
      "RFBSHLPT-5",
      2,
      1,
      829.0,
      {
         "Disk Storage Size":256,
         "Disk Type":"SSD",
         "Operating system":"Windows 11",
         "Processor Name":"Intel Core i9-9900X",
         "RAM Size":8,
         "Screen Size":15.6
      },
      "Fri, 03 Jan 2025 23:45:40 GMT",
      "Fri, 03 Jan 2025 23:45:40 GMT"
   ],
   [
      73,
      "HP",
      "Refurbished Laptop",
      "Excellent",
      "RFBSHLPT-66",
      1,
      3,
      759.0,
      {
         "Disk Storage Size":128,
         "Disk Type":"HDD",
         "Operating system":"Windows 11",
         "Processor Name":"Intel Core i3-8300",
         "RAM Size":4,
         "Screen Size":15.6
      },
      "Fri, 03 Jan 2025 23:45:41 GMT",
      "Fri, 03 Jan 2025 23:45:41 GMT"
   ]
]
login("testuser1", "password")
> 'Incorrect credentials'
login("testuser1", "password1")
> 'Welcome back testuser1'
update_cart(5, 1)
> {5: 1}
purchase()
> 1
read_statement(1)
> {'_id': 1, 'creation_date': 'Fri, 03 Jan 2025 23:31:12 GMT', 'purchase': {5: 1}, 'user_id': 7}
update_cart(5, 2)
> {5: 2}
logout()
> 'User testuser1 logged out'
login("testuser1", "password1")
> 'Welcome back testuser1'
read_cart()
> {5: 2}
read_log(7)
> [
   {
      "action":"Read Logs",
      "parameters":{
         "filter":"{'user_name': 7}"
      },
      "tags":[
         "MONGODB"
      ],
      "timestamp":"Fri, 03 Jan 2025 23:48:15 GMT",
      "userId":7
   },
   ...
]
follow(7)
> True
get_recommendation()
> [1] # Laptops that followed users have purchased recently
```

## License
This project is licensed under the MIT License.

## Author
**Marek Jagoš** (jagos.marek@outlook.cz)
