/***************************************
 *                                     *
 *   Created by Elias & Kobe           *
 *   Visit https://eliasdh.com         *
 *                                     *
 ***************************************/

-- [S1] Welke rol hebben datumparameters (dagen, weken, maanden, seizoen) op het aantal caches?
-- Conclusie: In de zomer is het aantal veel groter.
SELECT CASE WHEN d.date IS NOT NULL THEN CONVERT(date, d.date) ELSE NULL END AS Datum,
    DATEPART(WEEK, d.date) AS Week,
    DATEPART(MONTH, d.date) AS Maand,
    CASE
        WHEN DATEPART(MONTH, d.date) IN (12, 1, 2) THEN 'Winter'
        WHEN DATEPART(MONTH, d.date) IN (3, 4, 5) THEN 'Lente'
        WHEN DATEPART(MONTH, d.date) IN (6, 7, 8) THEN 'Zomer'
        WHEN DATEPART(MONTH, d.date) IN (9, 10, 11) THEN 'Herfst'
        ELSE NULL END AS Seizoen,
    COUNT(tf.treasureFound_key) AS Aantal_caches
FROM dimDay d
LEFT JOIN treasureFound tf ON d.dimDay_key = tf.dimDay_key
GROUP BY d.date,
    DATEPART(WEEK, d.date),
    DATEPART(MONTH, d.date),
    CASE
        WHEN DATEPART(MONTH, d.date) IN (12, 1, 2) THEN 'Winter'
        WHEN DATEPART(MONTH, d.date) IN (3, 4, 5) THEN 'Lente'
        WHEN DATEPART(MONTH, d.date) IN (6, 7, 8) THEN 'Zomer'
        WHEN DATEPART(MONTH, d.date) IN (9, 10, 11) THEN 'Herfst'
        ELSE NULL
    END
ORDER BY Datum;


-- [S1] Worden er gemiddeld minder caches gezocht op moeilijker terrein als het regent?
-- Conclusie: Bij "Not Rain" zoeken mensen meer caches.
SELECT 
    dtt.terrain,
    dr.weather_type AS WeatherType,
    COUNT(tf.treasureFound_key) AS TotalCachesFound
FROM dimTreasureType dtt
JOIN treasureFound tf ON dtt.dimTreasureType_key = tf.dimTreasureType_key
LEFT JOIN dimRain dr ON tf.dimRain_key = dr.dimRain_key
GROUP BY dtt.terrain, dr.weather_type
ORDER BY dtt.terrain, dr.weather_type;


-- [S1] Worden er in weekends meer moeilijkere caches gedaan?
-- Conclusie: In de weekdagen worden er moeilijkere caches gedaan.
SELECT CASE WHEN d.day IN (1, 7) THEN 'Weekend' ELSE 'Weekday' END AS DayType, dt.difficulty,
    COUNT(tf.dimTreasureType_key) AS NumberOfTreasures
FROM dimDay d
JOIN treasureFound tf ON d.dimDay_key = tf.dimDay_key
JOIN dimTreasureType dt ON tf.dimTreasureType_key = dt.dimTreasureType_key
GROUP BY CASE WHEN d.[day] IN (1, 7) THEN 'Weekend' ELSE 'Weekday' END, dt.difficulty
ORDER BY DayType, dt.difficulty;


-- [S1] Heeft het ervaringsniveau van gebruikers invloed op de tijd die nodig is om de schat te vinden?
-- Conclusie: Ja Professional doet er langer over (ze doen waarschijnlijk moeilijkere caches).
SELECT u.experience_level AS ExperienceLevel, 
    CONVERT(TIME, DATEADD(SECOND, AVG(DATEDIFF(SECOND, '00:00:00', tf.durationQuest)), '00:00:00'), 114)
    AS GemiddeldeTijdVindenSchatInMinuten
FROM dimUser u
JOIN treasureFound tf ON u.dimUser_key = tf.dimUser_key
GROUP BY u.experience_level;


-- [S1] Worden er meer caches gevonden in het weekend of de weekdagen?
-- Conclusie: Op weekdagen worden er meer caches gevonden.
SELECT CASE WHEN d.day = 1 OR d.day = 7 THEN 'Weekend' ELSE 'Doordeweeks' END AS DayType,
    COUNT(tf.dimTreasureType_key) AS TotalCachesFound
FROM treasureFound tf
JOIN dimDay d ON tf.dimDay_key = d.dimDay_key
GROUP BY CASE WHEN d.day = 1 OR d.day = 7 THEN 'Weekend' ELSE 'Doordeweeks' END;


-- [S2] Wat is de invloed van het type user op de duur van de treasurehunt? Doet een beginner er langer over?
-- Conclusie: Een Professional doet er het langst over, dan een Amateuer en dan een Pirate.
SELECT u.experience_level,
    CONVERT(TIME, DATEADD(SECOND, AVG(DATEDIFF(SECOND, '00:00:00', tf.durationQuest)), '00:00:00'), 114) AS average_time_spent
FROM treasureFound tf
JOIN dimUser u ON tf.dimUser_key = u.dimUser_key
GROUP BY u.experience_level;


-- [S2] Vinden users de cache gemiddeld sneller in de regen?
-- Conclusie: Ze vinden de cache gemiddeld sneller in de regen.
SELECT tf.dimRain_key,
    CONVERT(TIME, DATEADD(SECOND, AVG(CAST(DATEDIFF(SECOND, '00:00:00', tf.durationQuest) AS BIGINT)), '00:00:00'), 114) AS average_time_spent
FROM treasureFound tf
GROUP BY tf.dimRain_key;


-- [S2] Zoeken beginnende users gemiddeld naar grotere caches?
-- Conclusie: Ja ze doen er gemiddeld langer over.
SELECT dtt.size,
    CONVERT(TIME, DATEADD(SECOND, AVG(DATEDIFF(SECOND, '00:00:00', tf.durationQuest)), '00:00:00'), 114) AS average_time_spent
FROM treasureFound tf
JOIN dimUser u ON tf.dimUser_key = u.dimUser_key
JOIN dimTreasureType dtt ON tf.dimTreasureType_key = dtt.dimTreasureType_key
WHERE lower(u.experience_level) = 'amateur'
GROUP BY dtt.size
ORDER BY dtt.size;


-- [S2] Zijn beginnende gebruikers geneigd om naar grotere caches te zoeken vergeleken met meer ervaren gebruikers?
-- Conclusie: Nee, beginnende gebruiker zoeken naar kleinere caches.
SELECT u.experience_level, dtt.size, COUNT(tf.treasureFound_key) AS aantal_caches
FROM treasureFound tf
JOIN dimUser u ON tf.dimUser_key = u.dimUser_key
JOIN dimTreasureType dtt ON tf.dimTreasureType_key = dtt.dimTreasureType_key
GROUP BY u.experience_level, dtt.size
ORDER BY u.experience_level, dtt.size;


-- [S2] Hoe varieert het aantal caches dat gezocht wordt op basis van verschillende datumparameters (dagen, weken, maanden, seizoenen)?
-- Conclusie: Het aantal caches dat wordt gezocht stijgt over de jaren heen. is het hoogst in de zomer
SELECT COUNT(tf.treasureFound_key) AS aantal_caches, d.year
FROM treasureFound tf
JOIN dimDay d ON tf.dimDay_key = d.dimDay_key
GROUP by d.year
ORDER BY d.year;

SELECT COUNT(tf.treasureFound_key) AS aantal_caches, d.season
FROM treasureFound tf
JOIN dimDay d ON tf.dimDay_key = d.dimDay_key
GROUP by d.season
ORDER BY d.season;

SELECT COUNT(tf.treasureFound_key) AS aantal_caches, d.month
FROM treasureFound tf
JOIN dimDay d ON tf.dimDay_key = d.dimDay_key
GROUP by d.month
ORDER BY d.month;

SELECT COUNT(tf.treasureFound_key) AS aantal_caches, d.day
FROM treasureFound tf
JOIN dimDay d ON tf.dimDay_key = d.dimDay_key
GROUP by d.day
ORDER BY d.day;