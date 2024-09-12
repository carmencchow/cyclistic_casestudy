
/* --------------------- Data Analysis ---------------------*/

SELECT  *
FROM `general-432301.wip.view_trip_data_report` 
WHERE
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL
-- returns 4,241,241 records from the original 5,715,693 records


/* Number of rides by day of week */
SELECT 
  start_dayofweek,
  COUNT(DISTINCT ride_id) as num_rides
FROM 
  `general-432301.wip.view_trip_data_report` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL
GROUP BY
  start_dayofweek
ORDER BY 
  num_rides DESC

/* Number of rides each month */
SELECT  
  COUNT(ride_id) as count_rides,
  start_month
FROM `general-432301.wip.view_trip_data_report` 
GROUP BY
  start_month
ORDER BY
  count_rides DESC

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








  
===================================================



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


===================================================

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
