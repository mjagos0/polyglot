MATCH (u:User {id: $user_id})-[:Follow]->(followed:User)-[:Purchased]->(l:Laptop)
RETURN DISTINCT l.id AS id