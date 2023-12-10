![database-warehouse-icon](/images/database-warehouse-icon.png)
# Performantie

## Analysis Optimization (optimalisatie dossier)
![Before Index](/images/info-dwh.png)

### Index
Indexering verbetert de ophaalsnelheid van gegevens door structuren te optimaliseren op basis van specifieke velden of kolommen.

```sql
SET STATISTICS TIME ON;
GO

SELECT u.experience_level AS ExperienceLevel, 
  AVG(DATEDIFF(minute, tf.creationDate, GETDATE())) 
  AS GemiddeldeTijdVindenSchatInMinuten
FROM dimUser u
JOIN treasureFound tf ON u.dimUser_key = tf.dimUser_key
GROUP BY u.experience_level;

SET STATISTICS TIME OFF;
GO
```
<br>

| ExperienceLevel | GemiddeldeTijdVindenSchatInMinuten |
|-----------------|------------------------------------|
| Professional    | 127                                |
| Amateur         | 126                                |
| Pirate          | 127                                |
<br>

- (Before index creation)
  - Evidence

    ![Before Index](/images/before-index.png)

- Index creation

  Een NONCLUSTERED index is het beste omdat het efficiënt 
  zoekopdrachten kan uitvoeren zonder de fysieke volgorde 
  van de tabelgegevens te wijzigen.
  ```sql
  CREATE NONCLUSTERED INDEX IX_ExperienceLevel 
  ON dbo.dimUser(experience_level);
  ```

- (After index creation)
  - Evidence

    ![After Index](/images/after-index.png)


### Partitionering

Partitioneren verdeelt grote databasetabellen in kleinere door bijvoorbeeld een tabel op te splitsen per jaar.

```sql
SELECT COUNT(tf.treasureFound_key) AS aantal_caches, d.year
FROM treasureFound tf
JOIN dimDay d ON tf.dimDay_key = d.dimDay_key
GROUP by d.year
ORDER BY d.year;
```
<br>

| aantal_caches | year |
| ------------- | ---- |
| 116282        | 2020 |
| 378130        | 2021 |
| 380160        | 2022 |
| 263148        | 2023 |
</br>

- (Before partitionering)
 - Evidence

  ![Before partitioning](/images/before-partitioning.png)

- Partition creation

(horizontal) Partitoning zal de tabel op delen in verschillende delen op basis van de kolom "year", door deze opdeling kan de databank gaan zoeken in een bepaald deel van de tabel in plaats van heel de tabel.

```sql
-- Partition function
CREATE PARTITION FUNCTION [yearPartitioningFunction](INT)
AS RANGE RIGHT FOR VALUES (2020, 2021, 2022, 2023);
GO

-- Partition scheme
CREATE PARTITION SCHEME [yearPartitioningScheme] 
AS PARTITION [yearPartitioningFunction] ALL TO ([PRIMARY]);
GO

--get the pk constraint
SELECT CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'dimDay' AND CONSTRAINT_NAME LIKE 'PK%';

-- Alter the Table to Use Partition Scheme
ALTER TABLE dbo.dimDay DROP CONSTRAINT [PK__dimDay__0A543B5612B66E17];
GO

ALTER TABLE dbo.dimDay ADD CONSTRAINT [PK__dimDay__0A543B5612B66E17] PRIMARY KEY NONCLUSTERED (dimDay_key)
WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
      ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
GO

-- Create Clustered Index using the partition scheme
CREATE CLUSTERED INDEX IX__dimDay_year ON dbo.dimDay (year)
WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
      ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
ON [yearPartitioningScheme](year);
GO

--drop partition and table
DROP TABLE dimDay
drop partition scheme yearPartitioningScheme
drop partition function yearPartitioningFunction
```

- (After partitionering)

  - Evidence

![After partitioning](/images/after-partitioning.png)

### Column storage
Kolomopslag herstructureert de gegevensorganisatie door informatie op te slaan in kolommen in plaats van rijen, waardoor de prestaties van zoekopdrachten worden verbeterd, vooral voor analyses.

```sql
SELECT u.experience_level AS ExperienceLevel, 
    CONVERT(TIME, DATEADD(SECOND, AVG(DATEDIFF(SECOND, '00:00:00', tf.durationQuest)), '00:00:00'), 114)
    AS GemiddeldeTijdVindenSchatInMinuten
FROM dimUser u
JOIN treasureFound tf ON u.dimUser_key = tf.dimUser_key
GROUP BY u.experience_level;
```

| ExperienceLevel | GemiddeldeTijd |
| --------------- | -------------- |
| Amateur         | 2:20:35        |
| Pirate          | 2:16:12        |
| Professional    | 3:27:00        |

- (Before column storage)
  - evidence

    ![Before Column storage](/images/before-columnstorage.png)

- column storage creation

We doen dit op dimUser omdat dit een grote tabel is met historiek, hierbij werkt column storage optimaal.

```sql
-- Drop the primary key constraint on the dimUser table
ALTER TABLE dimUser
DROP CONSTRAINT PK__dimUser__9F70C0BE8CDB6B63;

-- Create a clustered Columnstore Index
CREATE CLUSTERED COLUMNSTORE INDEX IX_Columnstore_dimUser
ON dimUser;
```

- (After column storage)
  - evidence

    ![Before Column storage](/images/after-columnstorage.png)

### Compressie
Compressie minimaliseert de opslagvereisten door de gegevensgrootte te gebruiken met behulp van technieken zoals run-length-codering, woordenboekcodering of gzip-compressie.

- (Before compression)
  ```sql
  SELECT OBJECT_NAME(object_id) AS "Table Name",
    SUM(reserved_page_count) * 8 AS "Total Size KB",
    SUM(reserved_page_count) * 8 / 1024.0 AS "Total Size MB"
  FROM sys.dm_db_partition_stats
  WHERE OBJECT_NAME(object_id) = 'treasureFound'
  GROUP BY object_id;
  ```
  |   Table Name  | Total Size KB | Total Size MB |
  |---------------|---------------|---------------|
  | treasureFound | 68232         | 66.632812     |

  - Evidence

    ![Before Compressie](/images/before-compressie.png)

- Compression
  ```sql
  ALTER TABLE treasureFound
  REBUILD WITH (DATA_COMPRESSION = PAGE);
  ```
  - __PAGE__ = Row compression + Prefix compression
  - __ROW__ = Row compression
  - __NONE__ = No compression
  - __COLUMNSTORE__ = Columnstore compression

- (After compression)
  ```sql
  SELECT OBJECT_NAME(object_id) AS "Table Name",
    SUM(reserved_page_count) * 8 AS "Total Size KB",
    SUM(reserved_page_count) * 8 / 1024.0 AS "Total Size MB"
  FROM sys.dm_db_partition_stats
  WHERE OBJECT_NAME(object_id) = 'dimUser'
  GROUP BY object_id;
  ```
  |   Table Name  | Total Size KB | Total Size MB |
  |---------------|---------------|---------------|
  | treasureFound | 31272         | 30.539062     |

  - Evidence

    ![After Compressie](/images/after-compressie.png)