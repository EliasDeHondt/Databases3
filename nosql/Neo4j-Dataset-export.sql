--aan de hand van treasure_log zullen we enkel data gebruiken die van een bepaalde periode komt, 
--zo gebruiken we niet te veel data maar zijn we zeker dat de data relaties heeft met de rest van de data.

--treasure_log
select *
from treasure_log
where log_time > ('2022-01-01') and log_time < ('2022-03-30');

--treasure
select distinct treasure.id, treasure.difficulty, treasure.terrain, treasure.city_city_id, treasure.owner_id
from treasure
left JOIN treasure_log on treasure_log.treasure_id = treasure.id
where log_time > ('2022-01-01') and log_time < ('2022-03-30');

--city
select distinct city.city_id, city.city_name, city.latitude, city.longitude, city.postal_code, city.country_code
from city
left join treasure on treasure.city_city_id = city.city_id
left JOIN treasure_log on treasure_log.treasure_id = treasure.id
where log_time > ('2022-01-01') and log_time < ('2022-03-30');

--country
select distinct country.code, country.code3, country.name
from country
left join city on city.country_code = country.code
left join treasure on treasure.city_city_id = city.city_id
left JOIN treasure_log on treasure_log.treasure_id = treasure.id
where log_time > ('2022-01-01') and log_time < ('2022-03-30');

--user_table
select distinct u.id, u.first_name, u.last_name, u.mail, u.number, u.street, u.city_city_id
from user_table u
left JOIN treasure_log on treasure_log.hunter_id = u.id
where log_time > ('2022-01-01') and log_time < ('2022-03-30');