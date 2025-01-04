Todo:
- Decorators to check health on _methods and update self.service_health

Publish:
- Readme.md
- Publish to github

Backlog:
- Hash user passwords
- Filter logs based on multiple criteria
- Add psql price service + pass price to mongodb statements
- Decrease stock when purchase is made

Docker setup:
sudo service docker start

docker compose up -d

docker exec -it postgres psql -U admin -d mydb
docker exec -it redis redis-cli
docker exec -it neo4j cypher-shell -u neo4j -p password
docker exec -it mongodb mongosh
docker exec -it cassandra cqlsh

docker compose down


# # Redis
# docker exec -i redis redis-cli FLUSHALL > /dev/null 2>&1

# # MongoDB
# docker exec -i mongodb mongosh <<EOF > /dev/null 2>&1
# use polyglot;
# db.statements.deleteMany({})
# EOF

# # Cassandra
# docker exec -i cassandra cqlsh -e "TRUNCATE polyglot_logs.logs;" > /dev/null 2>&1


Point distribution:
MAX: 42b
DU:  21.5b
Potřeba pro projekt: 20.5b

- 1b: Describe the subject area and write the functional requirements for the project
- 2b: Describe each project block, select an appropriate system, and justify your choice
- 14b (3 per NoSQL DB + 2 for PostgreSQL): Implement basic queries for each of the five databases according to the specific requirements below
- 3b: *Design each project block as a microservice
- 5b (1 per database): Successful integration of each database system into a working web application (no interface)
- 1b: Write brief explanations of how each database is used in the project

Additional possible extensions
- Simple graphical interface (2 points).
- Demonstrate user interaction with data from each database through the web interface (1 point).
- Total base points: 26.
- Implement data synchronization between different blocks
- Basic synchronization (e.g., clear cart in Redis at checkout) (+1 point)
- Advanced synchronization across multiple databases (+3 points)
- Implement error handling and data validation (+2 points)