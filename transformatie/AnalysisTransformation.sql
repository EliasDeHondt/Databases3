/***************************************
 *                                     *
 *   Created by Elias & Kobe           *
 *   Visit https://eliasdh.com         *
 *                                     *
 ***************************************/



-- DELETE all data from the tables
DELETE FROM city2;
DELETE FROM country2;

-- Hoeveel steden zijn er in de XML?
SELECT country2.name AS "Land",
    city2.country_code AS "Landcode",
    COUNT(*) AS "Aantal steden in XML"
FROM city2 city2
    JOIN country2 country2 ON city2.country_code = country2.code
GROUP BY city2.country_code, country2.name
ORDER BY COUNT(*) DESC;



-- Vergelijk City2 name met City name
SELECT city.city_name AS "City Names",
    city2.city_name AS "City2 Names"
FROM city city
    JOIN city2 city2 ON city.city_id = city2.city_id;



-- Vergelijk Country2 name met Country name
SELECT country.name AS "Country Names",
    country2.name AS "Country2 Names"
FROM country country
    JOIN country2 country2 ON country.code 
    COLLATE Cyrillic_General_100_CS_AS_KS_WS_SC_UTF8 = country2.code;



-- Vergelijk alles van city2 met city (er zijn nog een paar city_names die verschillen door ' en -)
SELECT
    *,
    CONCAT(
        CASE WHEN city.city_id <> city2.city_id THEN 'city_id is different, ' ELSE '' END,
        CASE WHEN city.city_name  
        COLLATE Cyrillic_General_100_CS_AS_KS_WS_SC_UTF8 <> city2.city_name THEN 'city_name is different, ' ELSE '' END,
        CASE WHEN city.country_code  
        COLLATE Cyrillic_General_100_CS_AS_KS_WS_SC_UTF8 <> city2.country_code THEN 'country_code is different, ' ELSE '' END,
        CASE WHEN city.latitude <> city2.latitude THEN 'latitude is different, ' ELSE '' END,
        CASE WHEN city.longitude <> city2.longitude THEN 'longitude is different, ' ELSE '' END,
        CASE WHEN city.postal_code  
        COLLATE Cyrillic_General_100_CS_AS_KS_WS_SC_UTF8 <> city2.postal_code THEN 'postal_code is different, ' ELSE '' END
    ) AS difference_description
FROM city
    LEFT JOIN city2 ON city.city_id = city2.city_id
WHERE 
    city.city_id <> city2.city_id OR
    city.city_name 
    COLLATE Cyrillic_General_100_CS_AS_KS_WS_SC_UTF8 <> city2.city_name OR
    city.country_code  
    COLLATE Cyrillic_General_100_CS_AS_KS_WS_SC_UTF8 <> city2.country_code OR
    city.latitude <> city2.latitude OR
    city.longitude <> city2.longitude OR
    city.postal_code 
    COLLATE Cyrillic_General_100_CS_AS_KS_WS_SC_UTF8 <> city2.postal_code;



-- Vergelijk alles van country2 met country (alles is hetzelfde)
SELECT *, CONCAT(
    CASE WHEN country.code 
    COLLATE Cyrillic_General_100_CS_AS_KS_WS_SC_UTF8 <> country2.code then 'code is different, ' else '' end,
    CASE WHEN country.code3 
    COLLATE Cyrillic_General_100_CS_AS_KS_WS_SC_UTF8 <> country2.code3 then 'code3 is different, ' else '' end,
    CASE WHEN country.name 
    COLLATE Cyrillic_General_100_CS_AS_KS_WS_SC_UTF8 <> country2.name then 'name is different, ' else '' end
    ) as difference_description
FROM country
    LEFT JOIN country2 on country.code  COLLATE Cyrillic_General_100_CS_AS_KS_WS_SC_UTF8 = country2.code
WHERE 
    country.code 
    COLLATE Cyrillic_General_100_CS_AS_KS_WS_SC_UTF8 <> country2.code OR
    country.code3 
    COLLATE Cyrillic_General_100_CS_AS_KS_WS_SC_UTF8 <> country2.code3 OR
    country.name 
    COLLATE Cyrillic_General_100_CS_AS_KS_WS_SC_UTF8 <> country2.name;



/*
Deze query vergelijkt karakter per karakter de overeenkomst tussen de landnamen in de tabellen country en country2.
Het berekent het percentage van overeenkomende karakters op elke positie in de landnamen.
*/

SELECT
    co.name AS "Country Name",
    LEN(co.name) AS "Length",
    co2.name AS "Country2 Name",
    LEN(co2.name) AS "Length",
    CONCAT(
        CAST(
            (SUM(
                CASE 
                    WHEN SUBSTRING(co.name COLLATE Cyrillic_General_100_CS_AS_KS_WS_SC_UTF8, Numbers.number, 1) = SUBSTRING(co2.name, Numbers.number, 1) THEN 1.0
                    ELSE 0.0
                END
            ) * 100.0 / NULLIF(
                CASE 
                    WHEN LEN(co.name) >= LEN(co2.name) THEN LEN(co.name)
                    ELSE LEN(co2.name)
                END, 0)
            ) AS DECIMAL(10,2)),
        '%'
    ) AS "Match"
FROM country co
    JOIN country2 co2 ON co.code COLLATE Cyrillic_General_100_CS_AS_KS_WS_SC_UTF8 = co2.code
CROSS APPLY (
    SELECT number
    FROM master.dbo.spt_values
    WHERE type = 'P' AND number BETWEEN 1 AND 
    CASE 
        WHEN LEN(co.name) >= LEN(co2.name) THEN LEN(co.name)
        ELSE LEN(co2.name)
    END
) AS Numbers
GROUP BY co.name, co2.name;



/*
Deze query vergelijkt karakter per karakter de overeenkomst tussen de stadnamen in de tabellen city en city2.
Het berekent het percentage van overeenkomende karakters op elke positie in de stadnamen.
*/

SELECT
    c.city_name AS "City Name",
    LEN(c.city_name) AS "Length",
    c2.city_name AS "City2 Name",
    LEN(c2.city_name) AS "Length2",
    CONCAT(
        CAST(
            (SUM(
                CASE 
                    WHEN SUBSTRING(c.city_name 
                    COLLATE Cyrillic_General_100_CS_AS_KS_WS_SC_UTF8, Numbers.number, 1) = SUBSTRING(c2.city_name, Numbers.number, 1) 
                    THEN 1.0
                    ELSE 0.0
                END
            ) * 100.0 / NULLIF(
                CASE 
                    WHEN LEN(c.city_name) >= LEN(c2.city_name) THEN LEN(c.city_name)
                    ELSE LEN(c2.city_name)
                END, 0)
            ) AS DECIMAL(10,2)),
        '%'
    ) AS "Match Percentage"
FROM city c
    JOIN city2 c2 ON c.city_id = c2.city_id
CROSS APPLY (
    SELECT number
    FROM master.dbo.spt_values
    WHERE type = 'P' AND number BETWEEN 1 AND 
    CASE 
        WHEN LEN(c.city_name) >= LEN(c2.city_name) THEN LEN(c.city_name)
        ELSE LEN(c2.city_name)
    END
) AS Numbers
GROUP BY c.city_name, LEN(c.city_name), c2.city_name, LEN(c2.city_name);