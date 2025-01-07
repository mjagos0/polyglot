MATCH (u:User {id: $user_id}), (l:Laptop {id: $product_id})
CREATE (u)-[:Purchased]->(l)
RETURN u, l
