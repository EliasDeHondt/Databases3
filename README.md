![database-warehouse-icon](/images/database-warehouse-icon.png)
# Catchem - TreasureHunt System

## Introduction

Catchem is a worldwide treasure hunt organizer allowing volunteers to hide treasures with online instructions for seekers. This project aims to create a system akin to GeoCache, focusing primarily on data management and providing necessary artifacts to implement the system.


## Problem Description

Catchem manages registered users, treasures, and stages for treasure hunts. Key elements include:

- User data: firstname, lastname, street, number, city, email.
- Treasures: containing difficulty, terrain, size, and stages.
- Two types of treasures: "DirectTargetTreasure" and "MultiStageTreasure."
- Stages: physical or virtual with varying visibility levels.
- Logs: found, not found, or general messages.

## Scope of Work

- **Phase 1: Data Management**
  - XML Data Transformation using XSLT and Talend.
  - Schema modification for tables `Country2` and `City2`.
  - Integration of validated Foreign Keys.
  
- **Phase 2: Data Warehouse**
  - Creation of a star schema around "TreasureFound" subject area.
  - Populate the schema using ETL processes.
  - Analytical queries for various insights.

- **Phase 3: Database Optimization**
  - Implementing performance optimizations such as logical indexed views, partitioning, column storage, and compression.

## Getting Started

To start this project:

1. Clone the repository.
2. Install the required dependencies listed in `requirements.txt`.
3. Review the `docs` directory for detailed instructions for each phase.
4. Follow the outlined steps in the project directory for each phase.

## Documentation

In the `docs` directory, you'll find comprehensive guides and explanations for:

- Phase-wise project setup.
- Usage instructions.
- Data transformation processes.
- Data warehouse schema and ETL procedures.
- Database optimization approaches and results.

## Evaluation Criteria

Evaluation will be based on:

- Adherence to provided instructions.
- Correctness and efficiency of implemented functionalities.
- Clarity and completeness of documentation.
- Demonstration of optimized database performance.

## Deadline

How to deliver before a deadline?
Delivery must take place at the following times.
This means that at that moment you make a commit and push and provide that commit with a tag:
- Tuesday 28/11 3:45 PM: tag `v1`
- Tuesday 19/12 3:45 PM: tag `v2`
- Sunday 7/01/2023 23:59: tag `v3`
In addition to that commit, you must also always complete the reflection document `/reflection.md` and add it to the repository.

## Talend Java Code

### DimDay
```Java
int month = Integer.parseInt(TalendDate.formatDate("M", input_row.date));
int day =  Integer.parseInt(TalendDate.formatDate("dd", input_row.date));

if ((month == 12 && day >= 21) || (month >= 1 && month <= 2) || (month == 3 && day < 20)) {
  output_row.season = "Winter";
}

else if ((month == 3 && day >= 20) || (month >= 4 && month <= 5) || (month == 6 && day < 21)) {
  output_row.season = "Spring";
}

else if ((month == 6 && day >= 21) || (month >= 7 && month <= 8) || (month == 9 && day < 23)) {
  output_row.season = "Summer";
}

else if ((month == 9 && day >= 23) || (month >= 10 && month <= 11) || (month == 12 && day < 21)) {
	output_row.season = "Fall";
}

output_row.date=input_row.date;
```

### DimUser
```Java
if (input_row.experience_level == 0) output_row.experience_level = "Starter";
else if (input_row.experience_level < 4) output_row.experience_level = "Amateur";
else if (input_row.experience_level >= 4 && input_row.experience_level <= 10) output_row.experience_level = "Professional";
else output_row.experience_level = "Pirate";

if (input_row.dedicator > 0) output_row.dedicator = "Yes";
else output_row.dedicator = "No";

output_row.dimUser_key=input_row.dimUser_key;
output_row.first_name=input_row.first_name;
output_row.last_name=input_row.last_name;
output_row.streetnumber=input_row.streetnumber;
output_row.street=input_row.street;
output_row.city=input_row.city;
output_row.country=input_row.country;
```

### TreasureFound
```Java
Date logTime = input_row.log_time;
Date sessionStart = input_row.session_start;
long diffInMillis = logTime.getTime() - sessionStart.getTime();
Date diffDate = new Date(diffInMillis);

output_row.durationQuest = diffDate;
output_row.treasure_id = input_row.treasure_id;
output_row.log_time = input_row.log_time;
output_row.hunter_id = input_row.hunter_id;
// En
if (input_row.weatherType == 200) output_row.dimRain_key = 1;
else if (input_row.weatherCode == 300) output_row.dimRain_key = 1;
else if (input_row.weatherCode == 500) output_row.dimRain_key = 1;
else if (input_row.weatherCode == 600) output_row.dimRain_key = 2;
else if (input_row.weatherCode == 701) output_row.dimRain_key = 2;
else if (input_row.weatherCode == 741) output_row.dimRain_key = 2;
else if (input_row.weatherCode == 781) output_row.dimRain_key = 2;
else if (input_row.weatherCode == 800) output_row.dimRain_key = 2;
else if (input_row.weatherCode == 801) output_row.dimRain_key = 2;
else output_row.dimRain_key = 0;

output_row.dateRecord = input_row.dateRecord;
```

## Talend SQL Code
```SQL
-- Dimension "User"
SELECT id, first_name, last_name, number, street,
(SELECT city_name FROM city WHERE city_id = user_table.city_city_id),
(SELECT name FROM country WHERE code = (SELECT country_code FROM city WHERE city_id = user_table.city_city_id)),
(SELECT COUNT(*) FROM treasure_log WHERE user_table.id = treasure_log.hunter_id),
(SELECT COUNT(*) FROM treasure WHERE user_table.id = treasure.owner_id),
(SELECT TOP 1 log_time FROM treasure_log WHERE user_table.id = treasure_log.hunter_id)
FROM user_table


-- Dimension "TreasureType"
SELECT DISTINCT id, difficulty, terrain FROM treasure
LEFT JOIN treasure_stages ts ON id = ts.treasure_id
WHERE id IN (SELECT treasure_id FROM treasure_log WHERE log_type = 2)

SELECT COUNT(stages_id), treasure_id FROM treasure_stages GROUP BY treasure_id;


-- WeatherHistory
SELECT TOP 10 latitude, longitude FROM city;


-- Feitentabel "TreasureFound"
SELECT DISTINCT  treasure_id,  session_start, log_time, hunter_id FROM treasure_log WHERE log_type = 2;
SELECT dimUser_key, dimUser_SK, scd_start, scd_end FROM	dimUser;
SELECT dimDay_key, date FROM dimDay;
SELECT weatherType, hour, day, month, year FROM weatherHistory;
SELECT dimTreasureType_key, difficulty, terrain, size FROM	dimTreasureType;

SELECT DISTINCT id, difficulty, terrain FROM treasure
LEFT JOIN treasure_stages ts ON id = ts.treasure_id
WHERE id IN (SELECT treasure_id FROM treasure_log WHERE log_type = 2)

SELECT COUNT(stages_id), treasure_id FROM treasure_stages GROUP BY treasure_id;
```

## Auteur
```JSON
{
  "auteurs": [
    {
      "first_name": "Elias",
      "last_name": "De Hondt",
      "leeftijd": 22,
      "email": "elias.dehondt@student.kdg.be",
      "passie": "Alchemist van elektronica",
      "superkracht": "Transformeert koffie in code!",
      "favoriete_programmeertaal": "C# en Python",
      "levensmotto": "Perfection is everything",
      "uitdaging": "Leren van nieuwe technologieën voor kunstmatige intelligentie en machine learning"
    },
    {
      "first_name": "Kobe",
      "last_name": "Wijnants",
      "email": "kobe.wijnants@student.kdg.be",
      "leeftijd": 19,
      "passie": "Avonturen beleven in de digitale wildernis",
      "superkracht": "Code kloppen met ogen dicht!",
      "favoriete_programmeertaal": "Java en Python",
      "levensmotto": "Leef elke dag alsof het een nieuw avontuur is",
      "uitdaging": "Werken aan een open-sourceproject"
    }
  ]
}
```