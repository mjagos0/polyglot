## Database Systems 2: Polyglot project
Topic: Online store specializing in second hand laptops.

Participants: Marek Jagoš

#### Project description
This project is about developing an online store that sells used and refurbished laptops.The store offers two main types of products: used laptops and refurbished laptops. For refurbished laptops, the company either upgrades existing models or repurposes components from multiple laptops to create a new one. These refurbished laptops are sold under new SKU numbers and come with a short warranty.

The platform will offer features such as product searching and filtering. It will handle user data, including personal information, login credentials, shopping carts, purchase history, and personalized recommendations. It will also log user activity on the site. Additionally, frequently accessed data will be cached to improve website performance.

#### Functional requirements
- Product browsing and filtering
- Refurbished laptop component tracking
- User activity logging
- Sessions
- Caching
- User accounts
- Shopping cart
- Purchase history

#### Project parts
- Product inventory: PostgreSQL
- User accounts: PostgreSQL
- User sessions: Redis
- Shopping carts: Redis
- Purchase history: MongoDB
- Activity logs: Cassandra
- Personalized recommendations: Neo4j
- Caching frequent accessed data: Redis

#### Argumentation
- **Product inventory: PostgreSQL**: The product inventory will require complex filtering. Although some flexibility in the schema is needed, the overall structure will remain fairly stable, therefore RDBMS with JSON is more suitable than Document store.

- **User accounts: PostgreSQL**: We need constraint enforcement and encryption to store user data. Speed is not critical.

- **User sessions: Redis**: In-memory data store capabilities, fast read and write speeds. Since session data doesn't require complex querying or relational integrity, Redis handles temporary user sessions with minimal latency.

- **Shopping carts: Redis**: Similar to user sessions, shopping cart data is a key-value type structure where each user is associated with items added to their cart. Redis provides an optimal solution due to its ability to quickly store and retrieve this temporary, session-based data.

- **Purchase history: MongoDB**: Purchase history will consist of semi-structured data that does not require frequent updates. We also need the ability to occasionally query values (usually simple queries). We need the capability ot update it, but it will be rare. There will be more writes, but still in considerably low volume. Since in this case there is not much to gain from wide column stores, document store will be used for the sake of simplicty.

- **Activity logs: Cassandra**: High volume of write operations, rare reads, timeseries data. Wide column stores are ideal for this. We shouldn't use Redis since we need to query the values occasionally.

- **Personalized recommendations: Neo4j**: Graph database to track relationships.

- **Caching frequent accessed data: Redis**: Redis for caching. Fast, in-memory, simple.