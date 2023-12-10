/***************************************
 *                                     *
 *   Created by Elias & Kobe           *
 *   Visit https://eliasdh.com         *
 *                                     *
 ***************************************/

 -- begin datum: 2020-09-11 05:14:35.7400000
 -- eind datum:  2023-09-12 10:38:53.7400000

DECLARE @currentDate DATETIME = '2020-09-11 05:14:35.740';
DECLARE @endDate DATETIME = '2023-09-12 10:38:53.740';

DECLARE @cities TABLE (city VARCHAR(100));
INSERT INTO @cities VALUES ('Kameyama'), ('Blansko'), ('Traismauer'), ('Tresbœuf'), ('Ōgaki'), ('Borisoglebskiy'), ('Ambajogai'), ('García'), ('Toyota-shi'), ('Milas');

DECLARE @weatherConditions TABLE (weatherCode INT, weatherType VARCHAR(100));
INSERT INTO @weatherConditions VALUES (200, 'Thunderstorm'), (300, 'Drizzle'), (500, 'Rain'), (600, 'Snow'), (701, 'Mist'), (741, 'Fog'), (781, 'Tornado'), (800, 'Clear'), (801, 'Clouds');

WHILE @currentDate <= @endDate
BEGIN
    DECLARE @city VARCHAR(100);
    DECLARE @weatherCode INT;

    SELECT TOP 1 @city = city FROM @cities ORDER BY NEWID();
    SELECT TOP 1 @weatherCode = weatherCode FROM @weatherConditions ORDER BY NEWID();

    DECLARE @hour INT = DATEPART(HOUR, @currentDate);
    DECLARE @day INT = DATEPART(DAY, @currentDate);
    DECLARE @month INT = DATEPART(MONTH, @currentDate);
    DECLARE @year INT = YEAR(@currentDate);

    INSERT INTO weatherHistory (city, weatherCode, weatherType, humidity, hour, day, month, year)
    VALUES (@city, @weatherCode, (SELECT weatherType FROM @weatherConditions WHERE weatherCode = @weatherCode), 80, @hour, @day, @month, @year);

    SET @currentDate = DATEADD(HOUR, 1, @currentDate);

    IF @currentDate > @endDate
        BREAK;
END;