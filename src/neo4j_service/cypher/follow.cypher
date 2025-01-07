MATCH (u_from:User {id: $user_id_from}), (u_to:User {id: $user_id_to})
CREATE (u_from)-[:Follow]->(u_to)