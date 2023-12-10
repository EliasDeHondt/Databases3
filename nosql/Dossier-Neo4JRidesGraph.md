![database-warehouse-icon](/images/database-warehouse-icon.png)

# Neo4J Rides Graph Dossier


## <span style="color:#42f542">Deel 1: Neo4J Rides Graph installeren<span>
### Installatie van Neo4J met Docker

- docker installatie
```powershell
docker run --name neo4j-container --volume $HOME/neo4j/data:/data  --publish=7474:7474 --publish=7687:7687 neo4j:latest
```

### inloggen op Neo4j browser

- browse naar de Neo4j browser op "http://localhost:7474"
- standaard username/paswoord zijn neo4j/neo4j

- standaard is de neo4j databank is beschikbaar op "http://localhost:7687"

## <span style="color:#42f542">Deel 2: Importeren van de catchem tabellen<span>
### Exporteer je tabellen naar csv

Gebruik export data in sql management studio om volgende tabellen om te zetten naar csv:
- user_table
- treasure
- city
- country

### csv's in docker container zetten

1. plaats de csv's in je directory die je hebt verbonden aan je docker container
2. gebruik mv om ze in de import directory van je docker container te zetten
```bash
mv /data/CSV /var/lib/neo4j/import
```
3. voeg de waarde dbms.memory.transaction.total.max=4G toe in /var/lib/neo4j/conf/neo4j.conf om de maximale transactie memory usage te verhogen (anders zal user_table niet lukken)

### csv's inladen en relaties definiëren in neo4j

1. importeer city
```sql
LOAD CSV WITH HEADERS FROM 'file:///csv/Neo4J-Dataset-city.csv' AS row
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
  street: row.street
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


## <span style="color:#42f542">Deel 3: Queries<span>

### Vraag 1
Identificeer voor een bepaalde stad, welke andere stad hier sterk aan
gekoppeld is. Je doet dit door te kijken welke andere steden de
hunters in die stad ook bezoeken.

```sql

```

### vraag 2
Maak een query om 'fellow hunters' te zoeken die vergelijkbare hunts
doen dan jezelf. Dat zijn hunters die vaak dezelfde treasures zochten.

```sql

```

### vraag 3
Verzin een andere nuttige zoekfunctie die ten volle gebruik maakt van
de graph mogelijkheden.

```sql

```