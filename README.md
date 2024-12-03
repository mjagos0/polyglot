### Polyglot project
This is an extended university project that uses **polyglot persistence** to build an e-shop backend with Java and various database technologies. It uses
- **PostgreSQL** TODO: Add version
    - User accounts & authentication
    - Product inventory
- **Redis** TODO: Add version
    - User sessions
    - Shopping carts
    - Caching frequently accessed data in PostgreSQL
- **MongoDB** TODO: Add version
    - Purchase history
- **Cassandra** TODO: Add version
    - Activity logs
- **Neo4j** TODO: Add version
    - Recommendation system

This project is for showcase purposes. We could, of course, build an eshop with just PostgreSQL. However, it elaborates on the idea that some NoSQL technologies may be more suitable for certain purposes. The argumentation why given technology is used: [argumentation.md](docs/argumentation.md).

#### Polyglot persistence
> *Polyglot persistence is a term that refers to using multiple data storage technologies within a single system, in order to meet varying data storage needs. Such a system may consist of multiple applications, or it may be a single application with smaller components.* - Wikipedia

#### Build project
##### Docker
This project will be packaged in a Docker container.

##### Maven
This project can be compiled with Maven, however it requires all database systems to be running on the machine with valid connection configuration.