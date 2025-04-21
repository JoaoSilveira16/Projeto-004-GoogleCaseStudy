-- Analisando os dados...

-- Dados das corridas com duracão entre 1min e 4h representam a maior parte das corridas...

-- Média de duracão das corridas em um intervalo de até 4 horas
select avg(ride_length) from all_rides ar where ride_length <= interval '04:00:00';									-- 15:40 min de média para todos os usuários

-- Média de duracão das corridas para MEMBROS em um intervalo de até 4 horas
select avg(ride_length) from all_rides ar where member_casual = 'member' and ride_length <= interval '04:00:00';	-- 12:05 min de média para MEMBROS

-- Média de duracão das corridas para CASUAIS em um intervalo de até 4 horas
select avg(ride_length) from all_rides ar where member_casual = 'casual' and ride_length <= interval '04:00:00';	-- 21:55 min de média para CASUAIS

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Total de corridas em cada dia da semana (MODA para todos os usuários)
SELECT day_of_week, COUNT(ride_id) AS total
FROM all_rides
GROUP BY day_of_week
ORDER BY total DESC;

-- Total de corridas em cada dia da semana para CASUAIS (MODA para os Casuais)
SELECT day_of_week, COUNT(ride_id) AS total										-- Casuais tem preferencia: Sábado > Domingo > Sexta > Quarta > Quinta > Segunda > Terca
FROM all_rides
where member_casual = 'casual'
GROUP BY day_of_week
ORDER BY total DESC;

-- Total de corridas em cada dia da semana para MEMBROS (Moda para os Membros)
SELECT day_of_week, COUNT(ride_id) AS total										-- Membros tem preferencia: Quarta > Terca > Quinta > Segunda > Sexta > Sábado > Domingo
FROM all_rides
where member_casual = 'member'
GROUP BY day_of_week
ORDER BY total DESC;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT COUNT(ride_id) AS total_members										-- Total de corridas para quem é Member 2.579.672
FROM all_rides
where member_casual = 'member'

SELECT COUNT(ride_id) AS total_casual										-- Total de corridas para quem é Casual 1.486.972
FROM all_rides
where member_casual = 'casual'

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Horário de inicio das corridas de usuários CASUAIS
SELECT 
  EXTRACT(HOUR FROM started_at) AS hour_of_day,			-- Hora do dia: 17 > 16 > 15 > 18 > 14 > 13 > 12 > 11 > 19 > 10
  COUNT(*) AS ride_count
FROM all_rides
WHERE member_casual = 'casual' and ride_length <= interval '04:00:00'
GROUP BY hour_of_day
ORDER BY ride_count desc;

-- Horário de inicio das corridas de usuários MEMBROS
SELECT 
  EXTRACT(HOUR FROM started_at) AS hour_of_day,			-- Hora do dia: 17 > 16 > 18 > 8 > 15 > 7 > 19 > 12 > 14 > 13
  COUNT(*) AS ride_count
FROM all_rides
WHERE member_casual = 'member' and ride_length <= interval '04:00:00'
GROUP BY hour_of_day
ORDER BY ride_count desc;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Corridas ordenadas de 1 min até 4h no máximo.
select * from all_rides
where ride_length <= interval '04:00:00'
order by ride_length asc ;

select * from all_rides
where ride_length <= interval '04:00:00'
and member_casual = 'member'
order by ride_length asc ;

select * from all_rides
where ride_length <= interval '04:00:00'
and member_casual = 'casual'
order by ride_length asc ;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Tipos de bicicleta						-- Classic Bike 2.568.843
select rideable_type, count(*) as total		-- Eletric Bike 1.450.855
from all_rides ar							-- Electric Scooter 46.946
group by rideable_type;

-- Tipos de bicicleta usados por membros
select rideable_type, count(*) as total
from all_rides ar
where member_casual = 'member'
group by rideable_type;

-- Tipos de bicicleta usados por casuais
select rideable_type, count(*) as total
from all_rides ar
where member_casual = 'casual'
group by rideable_type;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
