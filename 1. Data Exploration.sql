/* Cyclistic Case Study (Google Big Query + Tableau) */
SELECT 
  COUNT(*)
FROM 
  `general-432301.wip.tripdata_test` 
-- return 5,715,693 records

/* ------------- Data Exploration -------------------- */

/* Check if station_id and station_name is ever NULL */
SELECT  *
  FROM `general-432301.wip.tripdata_test` 
  WHERE 
  start_station_id IS NULL and
  start_station_name IS NULL
-- returns 947,025 records

SELECT  *
  FROM `general-432301.wip.tripdata_test` 
  WHERE 
  end_station_id IS NULL and
  end_station_name IS NULL
-- returns 989,476 records

/* Check if any start_station_id has more than one name */
SELECT  
  start_station_id,
  COUNT(DISTINCT start_station_name) as start_station_name_count
FROM `general-432301.wip.tripdata_test` 
GROUP BY
  start_station_id
HAVING 
  start_station_name_count >= 2
ORDER BY 
  start_station_name_count DESC
-- 83 records of stations with 2+ names

/* Check if any start_station_id has more than one latitude and longitude */
SELECT  
  start_station_id,
  COUNT(DISTINCT start_lat) as lat_count
FROM `general-432301.wip.tripdata_test` 
GROUP BY
  start_station_id
HAVING 
  lat_count >= 2
ORDER BY 
  lat_count DESC
-- 1558 records of stations with 2+ latitude and longitude

/* Filter start_station_id */
SELECT  
  DISTINCT start_station_name as station_name,
FROM `general-432301.wip.tripdata_test` 
WHERE
  start_station_id = '647'
ORDER BY
  station_name ASC

/* Check if member_casual is ever non-member or non-casual */
SELECT  *
  FROM `general-432301.wip.tripdata_test` 
  WHERE member_casual <> "casual" AND member_casual <> "member" 
-- 0 records; it's always member or casual

/* Check if rideable type is ever non-classic, non-electric, or non-docked */
SELECT  *
  FROM `general-432301.wip.tripdata_test` 
  WHERE rideable_type <> "classic_bike" AND rideable_type <> "electric_bike" AND rideable_type  <> "docked_bike" 
-- 0 records; it's always classic, electric, or docked

/* Check if started_at or ended_at are ever NULL */
SELECT  *
  FROM `general-432301.wip.tripdata_test` 
  WHERE 
    started_at IS NULL and
    ended_at IS NULL
-- 0 records; never NULL


/* ------- Primary Key Test: Check for uniqueness of ride_id ----------*/
SELECT 
  ride_id
FROM 
  `general-432301.wip.tripdata_test` 
WHERE 
  ride_id IS NULL
-- no NULL values found

SELECT 
  COUNT(DISTINCT ride_id)
FROM 
  `general-432301.wip.tripdata_test` 
-- no duplicate values found

SELECT 
  LENGTH(ride_id) as ride_id_length, 
  COUNT(ride_id) as row_count
FROM 
  `general-432301.wip.tripdata_test` 
GROUP BY 
  ride_id_length;
-- length of ride_ids all the same

SELECT 
  ride_id,
  COUNT(DISTINCT start_station_name) as start_station_name_count /* repeat with other variables */
FROM `general-432301.wip.tripdata_test` 
GROUP BY
  ride_id
HAVING 
  start_station_name_count >= 2
ORDER BY 
  start_station_name_count DESC
-- 0 instances where ride_id is linked to more than 1 start_station_name, end_station_name, start_station_id, end_station_id, start_lat, end_lat, start_lng, and end_lng
