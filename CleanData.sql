-- 1) Criamos uma grande tabela consolidada com todos os 12 meses.

CREATE TABLE all_rides as
SELECT * FROM "202404_divvy_tripdata"
UNION ALL
SELECT * FROM "202405_divvy_tripdata"
UNION ALL
SELECT * FROM "202406_divvy_tripdata"
UNION ALL
SELECT * FROM "202407_divvy_tripdata"
UNION ALL
SELECT * FROM "202408_divvy_tripdata"
UNION ALL
SELECT * FROM "202409_divvy_tripdata"
UNION ALL
SELECT * FROM "202410_divvy_tripdata"
UNION ALL
SELECT * FROM "202411_divvy_tripdata"
UNION ALL
SELECT * FROM "202412_divvy_tripdata"
UNION ALL
SELECT * FROM "202501_divvy_tripdata"
UNION ALL
SELECT * FROM "202502_divvy_tripdata"
UNION ALL
SELECT * FROM "202503_divvy_tripdata"
;

-- Visualizando a nova tabela:
select * from all_rides;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2) Verificacão e limpeza de linhas vazias ou nulas.

delete FROM all_rides
WHERE 
  -- Estações de início/fim
  (start_station_name IS NULL OR start_station_name = '') OR
  (end_station_name IS NULL OR end_station_name = '') OR
  (start_station_id IS NULL OR start_station_id = '') OR
  (end_station_id IS NULL OR end_station_id = '') OR

  -- Coordenadas geográficas
  start_lat IS NULL OR
  start_lng IS NULL OR
  end_lat IS NULL OR
  end_lng IS NULL OR

  -- Datas e horários
  (started_at IS NULL OR started_at = '') OR
  (ended_at IS NULL OR ended_at = '') OR

  -- Informações da viagem
  (ride_id IS NULL OR ride_id = '') OR
  (rideable_type IS NULL OR rideable_type = '') OR
  (member_casual IS NULL OR member_casual = '');

/*

Primeiro, rodamos uma versão da consulta SQL acima com (SELECT *) para verificar as linhas com valores vazios ou NULL...
Em seguida, rodamos uma segunda versão da consulta com (SELECT COUNT(*)) para ver a quantidade de linhas que precisam ser limpas...
Valores limpos = 1.679.432 de 5.779.568 em 9s de execucão
E por último, rodamos a versão acima para limpar, com (DELETE FROM all_rides)

Portanto, temos um total de 4.100.136 de linhas para analisar.
*/

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3) Verificacão e limpeza de linhas com (ended_at < started_at).
-- Nosso objetivo com essa consulta é "preparar o terreno" para criar uma coluna 'ride_length' para verificar e analisar a duracão das corridas.
  
SELECT *
FROM all_rides
WHERE ended_at < started_at;

DELETE
FROM all_rides
WHERE ended_at < started_at;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4) Após eliminarmos as inconsistências, podemos criar a tabela 'ride_length'.

ALTER TABLE all_rides
ALTER COLUMN started_at TYPE TIMESTAMP
USING started_at::timestamp;

ALTER TABLE all_rides
ALTER COLUMN ended_at TYPE TIMESTAMP
USING ended_at::timestamp;
----------- Os comandos acima foram necessários para trocar o tipo de 'varchar' para 'timestamp'.

ALTER TABLE all_rides -- cria a nova coluna
ADD COLUMN ride_length INTERVAL;


UPDATE all_rides -- adiciona os valores na nova coluna
SET ride_length = ended_at - started_at;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5) Agora, verificamos os tempos das corridas e analisamos a necessidade de uma nova limpeza nos dados.

select count(*) from all_rides ar where ride_length >= interval '00:00:00';
-- Temos 4.100.101 corridas válidas com duracão maior ou igual a zero.

select count(*) from all_rides ar where ride_length <= INTERVAL '00:01:00';
-- Corridas com duracao igual ou abaixo de 1min são 33.457... Representam menos de 1% do total...
-- Além disso, podem ser corridas com inconsistências nos dados, corridas canceladas ou corridas de teste...

-- Portanto, optamos por limpar e excluir essas linhas...
delete from all_rides where ride_length <= interval '00:01:00';
-- Agora temos 4.066.644 linhas

-- Aqui, observamos algumas corridas que são incomuns (duracão superior a 4horas).
select count(*) from all_rides ar where ride_length >= INTERVAL '04:00:00';
-- São 6954 corridas que podem representar inconsistências nos dados, mas optamos por mantê-las e, caso necessário, podemos destacá-las com futuras consultas.

-- Visualizando:
select * from all_rides ar order by ride_length desc;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 6) Precisamos criar uma coluna chamada day_of_week para uma análise futura.

-- Criamos a coluna dia da semana.
ALTER TABLE all_rides
ADD COLUMN day_of_week TEXT;

-- Adicionamos os dias na coluna.
UPDATE all_rides
SET day_of_week = TRIM(TO_CHAR(started_at, 'Day'));

-- Visualizando:
select * from all_rides;

------------------------------------------------------------------------------------------------------------------------------------------------------------------