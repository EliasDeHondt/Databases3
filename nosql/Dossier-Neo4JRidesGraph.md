![database-warehouse-icon](/images/database-warehouse-icon.png)

# Neo4J Rides Graph Dossier


## <span style="color:#42f542">Deel 1: Neo4J Rides Graph installeren<span>
### Installatie van Neo4J met Docker

- docker installatie
```powershell
docker run -d --name neo4j-container --volume $HOME/neo4j/data:/data --volume=$HOME/neo4j/import:/import  --publish=7474:7474 --publish=7687:7687 neo4j:latest
```

### inloggen op Neo4j browser

- browse naar de Neo4j browser op "http://localhost:7474"
- standaard username/paswoord zijn neo4j/neo4j

- standaard is de neo4j databank beschikbaar op "http://localhost:7687"

## <span style="color:#42f542">Deel 2: Importeren van de catchem tabellen<span>
### Exporteer je tabellen naar csv

1. Gebruik het sql export script om alleen data van een bepaalde periode te exporteren:
- Neo4j-Dataset-export.sql

2. Gebruik export data in sql management studio om deze tabellen om te zetten naar csv

### csv's in docker container zetten

1. plaats de csv's in de import directory die je hebt verbonden aan je docker container. Op deze manier komen de csv's op de juiste plek waar Neo4J zal zoeken.


### csv's inladen en relaties definiëren in neo4j

1. importeer city
```sql
LOAD CSV WITH HEADERS FROM "file:///csv/Neo4J-Dataset-city.csv" AS row
CREATE (:City {
  city_id: row.city_id,
  city_name: row.city_name,
  latitude: toFloat(row.latitude),
  longitude: toFloat(row.longitude),
  postal_code: row.postal_code,
  country_code: row.country_code
});
```

2. importeer country
```sql
LOAD CSV WITH HEADERS FROM "file:///csv/Neo4J-Dataset-country.csv" AS row
CREATE (:Country {
  code: row.code,
  code3: row.code3,
  name: row.name
});
```

3. importeer treasure
```sql
LOAD CSV WITH HEADERS FROM "file:///csv/Neo4J-Dataset-treasure.csv" AS row
CREATE (:Treasure {
  id: row.id, 
  difficulty: row.difficulty, 
  terrain: row.terrain,
  city_id: row.city_city_id,
  owner_id: row.owner_id
});
```

4. importeer user_table
```sql
LOAD CSV WITH HEADERS FROM "file:///csv/Neo4J-Dataset-user_table.csv" AS row
CREATE (:User {
  id: row.id, 
  first_name: row.first_name, 
  last_name: row.last_name, 
  mail: row.mail, 
  number: row.number, 
  street: row.street,
  city_id: row.city_city_id
});
```

5. importeer treasure_log
```sql
LOAD CSV WITH HEADERS FROM "file:///csv/Neo4J-Dataset-treasure_log.csv" AS row
CREATE (:Treasure_log {
  id: row.id,
  description: row.description,
  log_time: row.log_time,
  log_type: toInteger(row.log_type),
  session_start: row.session_start,
  hunter_id: row.hunter_id,
  treasure_id: row.treasure_id
});
```

### leg de relaties in neo4j

1. city - country

```sql
MATCH (city:City), (country:Country)
WHERE city.country_code = country.code
CREATE (city)-[:IN_COUNTRY]->(country)
```

2. city - treasure

```sql
MATCH (treasure:Treasure), (city:City)
WHERE treasure.city_id = city.city_id
CREATE (city)-[:HAS_TREASURE]->(treasure);
```

3. treasure - user
```sql
MATCH (treasure:Treasure), (user:User)
WHERE treasure.owner_id = user.id
CREATE (user)-[:OWNS_TREASURE]->(treasure);
```

4. user - city
```sql
MATCH (city:City), (user:User)
WHERE city.city_id = user.city_id
CREATE (user)-[:LIVES_IN]->(city);
```

5. user - treasure
```sql
MATCH (user:User), (log:Treasure_log), (treasure:Treasure)
WHERE user.id = log.hunter_id AND treasure.id = log.treasure_id
CREATE (user)-[:HAS_FOUND]->(treasure)
```

### Test je nodes en relaties

1. Laat de relaties zien
```sql
CALL db.schema.visualization()
```

2. Laat alle nodes en relaties zien (kan zijn dat je "initial node display" hoger moet zetten om alles te zien)
```sql
Match (n)-[r]->(m)
Return n,r,m
```

## <span style="color:#42f542">Deel 3: Queries<span>

### Vraag 1
Identificeer voor een bepaalde stad, welke andere stad hier sterk aan gekoppeld is. Je doet dit door te kijken welke andere steden de hunters in die stad ook bezoeken.

Ik zal "Citta' Del Vaticano" gebruiken als voorbeeld

```sql 
MATCH (targetCity:City {city_name: "Chhatrari"})-[:HAS_TREASURE]->(treasure:Treasure)<-[:HAS_FOUND]-(hunter:User)-[:HAS_FOUND]->(otherTreasure:Treasure)<-[:HAS_TREASURE]-(otherCity:City)
WHERE targetCity <> otherCity
WITH otherCity, COUNT(DISTINCT hunter) AS sharedHunters
ORDER BY sharedHunters DESC
LIMIT 1
RETURN otherCity, sharedHunters;
```

![query1 graph](/images/graph-query1.png)

Chikhali Kanhoba heeft de sterkste koppeling omdat ze 2 hunters delen

### Vraag 2
Maak een query om 'fellow hunters' te zoeken die vergelijkbare hunts
doen dan jezelf. Dat zijn hunters die vaak dezelfde treasures zochten.

in dit voorbeeld gebruik ik hunter "Lessie Beahan" met user id "0x0000788FE2E246B482E054E11A2C8F25"

```sql
MATCH (yourUser:User {id: "0x0000788FE2E246B482E054E11A2C8F25"} )-[:HAS_FOUND]->(yourTreasures:Treasure)
WITH yourUser, COLLECT(DISTINCT yourTreasures) AS yourTreasuresList
MATCH (fellowHunter:User)-[:HAS_FOUND]->(commonTreasures:Treasure)
WHERE fellowHunter.id <> yourUser.id AND commonTreasures IN yourTreasuresList
RETURN fellowHunter, COLLECT(DISTINCT commonTreasures) AS sharedTreasures, yourUser
ORDER BY SIZE(sharedTreasures) DESC;
```

![query2 graph](/images/graph-query2.png)

### Vraag 3
Verzin een andere nuttige zoekfunctie die ten volle gebruik maakt van
de graph mogelijkheden.

Ik heb er voor gekozen om een zoekfunctie te maken die de top 5 users met de meeste treasures vindt. 
Over deze users geven we dan alle informatie weer: al zijn gevonden treasurs en de city en country waar hij in woont

```sql
MATCH (hunter:User)-[:OWNS_TREASURE]->(treasure:Treasure)
WITH hunter, COUNT(treasure) AS ownedTreasures
OPTIONAL MATCH (hunter)-[:HAS_FOUND]->(foundTreasure:Treasure)
RETURN hunter,
       ownedTreasures,
       COLLECT(DISTINCT foundTreasure) AS foundTreasures,
       [(hunter)-[:LIVES_IN]->(city:City) | city] AS cities,
       [(hunter)-[:LIVES_IN]->(city)-[:IN_COUNTRY]->(country:Country) | country] AS countries
ORDER BY ownedTreasures DESC
LIMIT 5;
```

![query3 graph](/images/graph-query3.png)