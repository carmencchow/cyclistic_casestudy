/* Cyclistic Case Study (Google Big Query + Tableau) */
SELECT 
  COUNT(*)
FROM 
  `general-432301.wip.tripdata_test` 
-- return 5,715,693 records

/*  Find stations with 2 or more station names */
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

/* Data Exploration: Find startions with 2 or more latitude and longitude coordinations */
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


/* Filter start_station_id by */
SELECT  
  DISTINCT start_station_name as station_name,
FROM `general-432301.wip.tripdata_test` 
WHERE
  start_station_id = '647'
ORDER BY
  station_name ASC




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


-- SELECT ride_id
-- COUNT(ride_id) as count_ride_id
-- FROM `general-432301.wip.tripdata_test`
-- GROUP BY ride_id
-- ORDER BY count_ride_id desc


/* Instead of deleting rows, which the free version of Big Query does not handle, I opted to use filters on my queries */

SELECT *
FROM 
  `general-432301.wip.tripdata_test` 
WHERE 
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1 OR
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1440;

/* Check that all members are either 'member' or 'casual' */
SELECT 
  DISTINCT 
    member_casual
  FROM 
    `general-432301.wip.tripdata_test` 

/* Rides per day */
SELECT 
start_station_id, 
start_station_name, 
start_dayofweek,
COUNT(ride_id) as num_rides

FROM `general-432301.wip.view_trip_data_report` 
WHERE
  start_station_id = '13022'
GROUP BY
  start_station_id, 
  start_station_name, 
  start_dayofweek
ORDER BY 
  num_rides DESC


/* Ride count */
SELECT  
  start_station_id,  
  MAX(start_station_name) as start_station_name,
  COUNT(DISTINCT ride_id) as ride_count,  
FROM 
  `general-432301.wip.view_trip_data_report` 
WHERE 
  start_station_id IS NOT NULL 
GROUP BY
  start_station_id


/* Rideable type */ 

SELECT  
  ride_id,
  rideable_type,
  count(rideable_type) as count_types
FROM 
  `general-432301.wip.tripdata_test` 
WHERE 
  member_casual <> "casual" AND member_casual <> "member" 
GROUP BY
  ride_id,
  rideable_type
ORDER BY
  count_types DESC

SELECT 
  rideable_type,
  COUNT(DISTINCT ride_id) as num_rides
FROM 
  `general-432301.wip.view_trip_data_report` 
GROUP BY
  rideable_type



/* 1. Station Data Table - Create a dimension table that contains aggregated start and end station data with station_id as the primary key */
SELECT 
  station_id,
  ROUND(MAX(lat), 6) as lat,
  ROUND(MAX(lng), 6) as lng,
  MAX(station_name) as station_name 
FROM
(
  SELECT /* aggregate start_station data */
    start_station_id as station_id,
    MAX(start_lat) as lat,
    MAX(start_lng) as lng,
    MAX(start_station_name) as station_name
  FROM
    `general-432301.wip.tripdata_test`
  GROUP BY
    station_id

  UNION ALL

  SELECT /* aggregate end_station data */
    end_station_id as station_id,
    MAX(end_lat) as lat,
    MAX(end_lng) as lng,
    MAX(end_station_name) as station_name
  FROM
    `general-432301.wip.tripdata_test`
  GROUP BY
    station_id
)
GROUP BY 
  station_id


/* 2. Ride Data Table - Create a dimension table that contains aggregated ride_data with ride_id as the primary key */

SELECT
  ride_id,
  MAX(rideable_type) as rideable_type,
  MAX(started_at) as started_at,
  MAX(ended_at) as ended_at,
  MAX(start_station_id) as start_station_id,
  MAX(end_station_id) as end_station_id,
  MAX(member_casual) as member_casual,
FROM
  `general-432301.wip.tripdata_test`
GROUP BY
  ride_id


/* 3. Merge ride_data with start_station and end_station data on start_station_id with two left joins */

SELECT  
  ride_id,
  rideable_type,
  member_casual,
  started_at,
  ended_at,
  start_station_id,
  end_station_id,
  start_data.station_name as start_station_name,
  end_data.station_name as end_station_name,
  start_data.lat as start_lat,
  start_data.lng as start_lng,
  end_data.lat as end_lat,
  end_data.lng as end_lng
FROM
  `general-432301.wip.ride_data`
LEFT JOIN
  `general-432301.wip.dim_station` as start_data
  ON start_station_id = start_data.station_id
LEFT JOIN
  `general-432301.wip.dim_station` as end_data
  ON end_station_id =  end_data.station_id

/* Final table with 6 new columns: start_dayofweek, start_month, start_am_pm, start_hour, trip_duration, and distance_in_meters; connect to Tableau for data viz*/

SELECT  
  ride_id, 
  rideable_type, 
  member_casual,
  started_at, 
  ended_at, 
  CONCAT(FORMAT_DATETIME('%u', started_at),"-",FORMAT_DATETIME('%a', started_at)) as      
  start_dayofweek,
  FORMAT_DATETIME('%G', started_at) as start_year_id,
  CONCAT(FORMAT_DATETIME('%m', started_at),"-",FORMAT_DATETIME('%h', started_at)) as start_month,
  FORMAT_DATETIME('%P', started_at) as start_am_pm,
  EXTRACT(HOUR FROM started_at) as start_hour,
  start_station_id, 
  start_station_name, 
  end_station_id, 
  end_station_name, 
  start_lat, 
  start_lng,
  end_lat, 
  end_lng, 
  DATETIME_DIFF(ended_at, started_at, second) as trip_duration,
  ST_DISTANCE(ST_GEOGPOINT(start_lng, start_lat), ST_GEOGPOINT(end_lng, end_lat)) as    
  distance_in_meters

FROM `general-432301.wip.trip_data_clean` 


/* ------ Part 3: Analysis ----------- */

/* Number of rides by month */
SELECT  
  COUNT(ride_id) as count_rides,
  start_month
FROM `general-432301.wip.view_trip_data_report` 
GROUP BY
  start_month
ORDER BY
  count_rides DESC

/* Number of rides by day of week */
SELECT 
  start_dayofweek,
  COUNT(DISTINCT ride_id) as num_rides
FROM 
  `general-432301.wip.view_trip_data_report` 
WHERE 
  start_station_id IS NOT NULL
GROUP BY
  start_dayofweek
ORDER BY 
  num_rides DESC

/* Trip duration by day of week */
SELECT 
  member_casual,
  start_dayofweek,
  ROUND(SUM(trip_duration)/60,2) as total_tripduration_mins
FROM 
  `general-432301.wip.view_trip_data_report` 
WHERE
  member_casual = 'casual' and
  trip_duration < 1440
GROUP BY
  member_casual,
  start_dayofweek
ORDER BY
  total_tripduration_mins desc


/* Total distance travelled each month */
SELECT 
  member_casual,
  start_month,
  SUM(distance_in_meters) as total_distance 
FROM 
  `general-432301.wip.view_trip_data_report` 
WHERE 
  member_casual = 'member'
-- WHERE member_casual = 'casual'
  and start_station_id IS NOT NULL
  and trip_duration > 60 and trip_duration < 1440
GROUP BY
  member_casual,
  start_month 
ORDER BY
  start_month asc


/* 10 most popular start_stations */
SELECT 
  start_station_name,
  start_lat,
  start_lng,
  COUNT(DISTINCT ride_id) as num_rides
FROM 
  `general-432301.wip.view_trip_data_report` 
WHERE
  -- member_casual = 'member' 
  member_casual = 'casual'
GROUP BY
  start_station_id,
  start_station_name,
  start_lat,
  start_lng
ORDER BY
  num_rides DESC
LIMIT 10

/* Find least popular start_station */
SELECT 
  start_station_id,
  MIN(start_station_name),
  COUNT(ride_id) as num_rides
FROM `general-432301.wip.view_trip_data_report` 
GROUP BY
  start_station_id,
  start_station_name
HAVING
  COUNT(ride_id) = 1
ORDER BY
  start_station_name asc