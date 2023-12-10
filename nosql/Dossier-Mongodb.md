![database-warehouse-icon](/images/database-warehouse-icon.png)

# MongoDB Dossier


## <span style="color:#4F94F0">Deel 1: MongoDB installeren<span>
### Installatie van MongoDB met Docker

1. **Pull de MongoDB Docker Image:**
    ```bash
    docker pull mongo
    ```

2. **Start MongoDB in een Docker Container:**
    ```bash
    docker run -d -p 27017:27017 --name mongodb mongo
    ```

3. **Controleer draaiende Docker containers:**
    ```bash
    docker ps
    ```

   ![dossier-mongodb-1](/images/dossier-mongodb-1.png)

### Installatie van MongoDB CLI (Command Line Interface)

1. **Installeer MongoDB Clients:**
    ```bash
    sudo apt install mongodb-clients -y
    ```

### Gebruik van MongoDB

1. **Verbinding maken met de lokaal draaiende MongoDB:**
    ```bash
    mongo --host localhost --port 27017
    ```

2. **Sluit de MongoDB Shell:**
    ```bash
    exit;
    ```

### Beheer van MongoDB Docker Container

1. **Start de eerder aangemaakte MongoDB Container:**
    ```bash
    docker start mongodb
    ```

2. **Stop de draaiende MongoDB Container:**
    ```bash
    docker stop mongodb
    ```

3. **Verwijder de MongoDB Container:**
    ```bash
    docker rm mongodb
    ```
## <span style="color:#4F94F0">Deel 2: MongoDB Compass<span>

### Installatie van MongoDB Compass

1. **Download MongoDB Compass:**
   - Ga naar de officiële [MongoDB Compass Downloadpagina](https://www.mongodb.com/try/download/compass) en selecteer de juiste versie voor je besturingssysteem (Windows, macOS, Linux).
   - Volg de installatie-instructies voor jouw besturingssysteem om MongoDB Compass te installeren.

### Verbinding maken met MongoDB via MongoDB Compass

1. **Open MongoDB Compass:**
   - Start MongoDB Compass na de installatie.

2. **Verbinding maken met MongoDB:**
   - Voer de vereiste informatie in voor de verbinding:
     - Host: `localhost`
     - Port: `27017` (of de poort waarop MongoDB draait, als deze is gewijzigd)
     - Klik op 'Connect' om verbinding te maken met je lokale MongoDB-instantie.

3. **Verken en Beheer je MongoDB-databases:**
   - Na het verbinden zou je alle databases en collecties moeten zien. Je kunt queries uitvoeren, documenten bekijken, indexen beheren, etc.

   ![dossier-mongodb-1](/images/dossier-mongodb-2.png)

## <span style="color:#4F94F0">Deel 3: Data importeren in MongoDB<span>

### Importeren van Data in MongoDB via Command Line

1. **Zorg voor het dataformaat:**
   - Zorg ervoor dat het te importeren bestand een geschikt formaat heeft zoals JSON, CSV, BSON, etc.

2. **Gebruik `mongoimport` commando:**
   - Syntax voor importeren van een JSON-bestand:
     ```bash
     mongoimport --host=localhost --port=27017 --db=<database_name> --collection=<collection_name> --file=<path/to/file.json> --jsonArray
     ```
     Vervang `<database_name>`, `<collection_name>`, en `<path/to/file.json>` met de juiste waarden.

   - Voor andere formaten zoals CSV, gebruik de juiste vlaggen en opties voor `mongoimport`. Raadpleeg de MongoDB documentatie voor specifieke formaten.

### Importeren van Data in MongoDB via MongoDB Compass

1. **Open MongoDB Compass:**
   - Start MongoDB Compass en maak verbinding met je MongoDB-server (zoals eerder beschreven in deel 2).

2. **Klik op "Import Data":**
   - Zoek naar een knop of optie in MongoDB Compass om data te importeren. Deze kan zich bevinden in de toolbars of in een dropdown-menu.

3. **Selecteer het Dataformaat en Bestand:**
   - Kies het juiste formaat van het te importeren bestand (JSON, CSV, etc.).
   - Selecteer het bestand dat je wilt importeren.

4. **Stel de Doel-database en -collectie in:**
   - Specificeer de database en collectie waarin je de data wilt importeren.

5. **Start de Import:**
   - Bevestig de instellingen en start het importeren van de data.

### Datacontrole en Beheer na Import

1. **Verifieer de Geïmporteerde Data:**
   - Gebruik MongoDB Compass of de CLI om te controleren of de gegevens correct zijn geïmporteerd in de beoogde database en collectie.

2. **Voer Queries uit en Beheer de Data:**
   - Voer queries uit om de geïmporteerde data te bekijken, bewerken of beheren zoals vereist.

   [MongoDB-Dataset-Treasure](/nosql//MongoDB-Dataset-Treasure.json)

   [MongoDB-Dataset-Stage](/nosql//MongoDB-Dataset-Stage.json)

   [MongoDB-Dataset-City](/nosql//MongoDB-Dataset-City.json)

   [MongoDB-Dataset-Country](/nosql//MongoDB-Dataset-Country.json)

## <span style="color:#4F94F0">Deel 4: Clustering 1<span>

![dossier-mongodb-3](/images/dossier-mongodb-3.png)

![dossier-mongodb-4](/images/dossier-mongodb-4.png)

### ❓Naamgevingen❓
- 1 Configuratieserver
   - `configsvr`
- 3 Shards
   - `shard1`, `shard2`, `shard3`
- 1 Routers (mongo's):
   - `mongos`

### 📚Netwerk📚
- Huidige poortconfiguratie:
   - configsvr: 10001
   - shard1: 30001
   - shard2: 30002
   - shard3: 30003
   - mongos: 20001

- Handige Ip-adressen:
   - configsvr: 192.168.80.2
   - shard1: 192.168.80.4
   - shard2: 192.168.80.5
   - shard3: 192.168.80.6
   - mongos: 192.168.80.3

### 📋Onderhoud📋
- Starten van de cluster
   ```bash
   docker start configsvr shard1 shard2 shard3 mongos
   ```
- Stoppen van de cluster:
   ```bash
   docker stop configsvr shard1 shard2 shard3 mongos
   ```
- Verwijderen van de cluster:
   ```bash
   docker network rm mongo-cluster-network
   docker rm configsvr shard1 shard2 shard3 mongos
   ```

### ✨Stappen✨

#### 👉Stap 1: Docker Network aanmaken:
   ```bash 
   docker network create --subnet=192.168.80.0/24 mongo-cluster-network
   ```

#### 👉Stap 2: Config Server opzetten (configsvr):
   ```bash 
   docker run -d -p 10001:27017 --name configsvr --network mongo-cluster-network --ip 192.168.80.2 mongo:5 mongod --configsvr --replSet configReplSet

   docker exec -it configsvr mongosh rs.initiate()
   ```

#### 👉Stap 3: Starten van de Shards (shard1, shard2, shard3):
   ```bash
   docker run -d -p 30001:27017 --name shard1 --network mongo-cluster-network --ip 192.168.80.4 mongo:5 mongod --shardsvr --replSet shard1ReplSet 
   docker run -d -p 30002:27017 --name shard2 --network mongo-cluster-network --ip 192.168.80.5 mongo:5 mongod --shardsvr --replSet shard2ReplSet
   docker run -d -p 30003:27017 --name shard3 --network mongo-cluster-network --ip 192.168.80.6 mongo:5 mongod --shardsvr --replSet shard3ReplSet

   docker exec -it shard1 mongosh rs.initiate()
   docker exec -it shard2 mongosh rs.initiate()
   docker exec -it shard3 mongosh rs.initiate()
   ```

#### 👉Stap 4: Start de Mongos Router (mongos):
   ```bash
   docker run -d -p 20001:27017 --name mongos --network mongo-cluster-network --ip 192.168.80.3 mongo:5 mongos --configdb configReplSet/192.168.80.2:27017 --bind_ip_all

   docker exec -it mongos mongosh sh.addShard("shard1ReplSet/192.168.80.4:30001")
   docker exec -it mongos mongosh sh.addShard("shard2ReplSet/192.168.80.5:30002")
   docker exec -it mongos mongosh sh.addShard("shard3ReplSet/192.168.80.6:30003")
   ```

#### 👉Stap 5: Verbinden met de MongoDB Cluster:
   ```bash
   mongo mongodb://192.168.80.3:20001

   docker exec -it configsvr bash
   docker exec -it shard1 bash
   docker exec -it shard2 bash
   docker exec -it shard3 bash
   docker exec -it mongos bash
   ```

## <span style="color:#4F94F0">Deel 4: Clustering 2<span>

![dossier-mongodb-5](/images/dossier-mongodb-5.png)
![dossier-mongodb-6](/images/dossier-mongodb-6.png)

### ❓Naamgevingen❓
- Configuratieserver (replicaset met 3 leden):
   - `configsvr01`, `configsvr02`, `configsvr03`
- 3 Shards (elk een PSS-replicaset met 3 leden)
   - `shard01-a`, `shard01-b`, `shard01-c`
   - `shard02-a`, `shard02-b`, `shard02-c`
   - `shard03-a`, `shard03-b`, `shard03-c`
- 2 Routers (mongo's):
   - `router01`, `router02`

### 📚Netwerk📚
- Huidige poortconfiguratie:
   - configsvr01: `27119`
   - configsvr02: `27120`
   - configsvr03: `27121`
   - Shards 01:
      - shard01-a: `27122`
      - shard02-a: `27123`
      - shard03-a: `27124`
   - Shards 02:
      - shard01-b: `27125`
      - shard02-b: `27126`
      - shard03-b: `27127`
   - Shards 03:
      - shard01-c: `27128`
      - shard02-c: `27129`
      - shard03-c: `27130`
   - router01: `27017`
   - router02: `27118`

- Handige Ip-adressen:
   - configsvr01: `Docker DHCP`
   - configsvr02: `Docker DHCP`
   - configsvr03: `Docker DHCP`
   - Shards 01:
      - shard01-a: `Docker DHCP`
      - shard02-a: `Docker DHCP`
      - shard03-a: `Docker DHCP`
   - Shards 02:
      - shard01-b: `Docker DHCP`
      - shard02-b: `Docker DHCP`
      - shard03-b: `Docker DHCP`
   - Shards 03:
      - shard01-c: `Docker DHCP`
      - shard02-c: `Docker DHCP`
      - shard03-c: `Docker DHCP`
   - router01: `Docker DHCP`
   - router02: `Docker DHCP`

### 📋Onderhoud📋
- Starten van de cluster
   ```bash
   docker start configsvr01 configsvr02 configsvr03 shard01-a shard01-b shard01-c shard02-a shard02-b shard02-c shard03-a shard03-b shard03-c router01 router02
   ```
- Stoppen van de cluster:
   ```bash
   docker stop configsvr01 configsvr02 configsvr03 shard01-a shard01-b shard01-c shard02-a shard02-b shard02-c shard03-a shard03-b shard03-c router01 router02
   ```
- Verwijderen van de cluster:
   ```bash
   docker rm configsvr01 configsvr02 configsvr03 shard01-a shard01-b shard01-c shard02-a shard02-b shard02-c shard03-a shard03-b shard03-c router01 router02
   ```

### ✨Stappen✨

#### 👉 Step 1: Start all of the containers 
   ```bash
   cd /
   git clone https://github.com/EliasDeHondt/Databases2.git
   cd Databases2/nosql/
   docker-compose up -d
   ```

#### 👉Stap 2: Initialiseer de replicasets (configuratieservers en shards)
   Voer deze opdrachten één voor één uit in de terminal:
   ```bash
   docker-compose exec configsvr01 sh -c "mongosh < /scripts/init-configserver.js"

   docker-compose exec shard01-a sh -c "mongosh < /scripts/init-shard01.js"
   docker-compose exec shard02-a sh -c "mongosh < /scripts/init-shard02.js"
   docker-compose exec shard03-a sh -c "mongosh < /scripts/init-shard03.js"
   ```   

#### 👉 Step 3: Initialiseren van de router
   ```bash
   docker-compose exec router01 sh -c "mongosh < /scripts/init-router.js"
   ```

#### 👉 Step 4: Verbinden met de router
   ```bash
   mongodb://192.168.70.129:27117,192.168.70.129:27118
   ```

#### 👉Stap 5: Verbinding testen met de MongoDB Cluster:
   ```bash
   # Verbinden met de router
   mongo mongodb://192.168.70.129:27117,192.168.70.129:27118
   # Controleren of de database shards worden herkend
   sh.status();
   # Bekijken van de replicaset-configuratieservers
   rs.status();
   # Lijst van databases
   show dbs
   # Controleren van de cluster status
   db.runCommand({ isMaster: 1 });

   use Catchem
   show collections
   db.city.find().limit(5);
   db.city.find({ "country_code": "JP" }).limit(1);

   db.jouw_collectie_naam.updateOne(
      { 
         "country_code": "JP" 
      },
      { 
      $set: { "country_code": "JPDemo" } 
      }
   );

   ```