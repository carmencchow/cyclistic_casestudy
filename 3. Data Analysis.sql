SELECT  *
FROM `general-432301.wip.view_trip_data_report` 
WHERE
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL
-- returns 4,241,241 records from the original 5,715,693 records

/* NOTE: The free-tier version of Big Query does not permit data deletion, so I will use the WHERE clause to filter out NULL values */

/* 1. Total rides by membership type */
SELECT 
  member_casual,
  COUNT(DISTINCT ride_id) as num_rides
FROM 
  `general-432301.wip.view_trip_data_report` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL
GROUP BY
  member_casual
-- 1,490,342 casual rides
-- 2,750,899 member rides

/* 2. Total rides by day of week */
SELECT 
  start_dayofweek,
  COUNT(DISTINCT ride_id) as num_rides
FROM 
  `general-432301.wip.view_trip_data_report` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL
GROUP BY
  start_dayofweek
ORDER BY 
  num_rides DESC

/* 3. Total daily rides by membership */
SELECT 
  start_dayofweek,
  COUNT(DISTINCT ride_id) as num_rides
FROM 
  `general-432301.wip.view_trip_data_report` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and 
  member_casual = 'casual'
  -- and member_casual = 'member'

GROUP BY
  start_dayofweek
ORDER BY 
  num_rides DESC
-- CASUAL: Saturday (307,441) and Sunday (254,483) 
-- MEMBER: Wednesday (463,411), Tuesday (444,178), and Thursday (432,910) 

/* 4. Total monthly rides */
SELECT  
  COUNT(ride_id) as count_rides,
  start_month
FROM `general-432301.wip.view_trip_data_report` 
WHERE
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL 
GROUP BY
  start_month
ORDER BY
  count_rides DESC
-- August (584,960), July (540,794), September (506,635)

/* 5. Total monthly rides by membership type */
SELECT  
  COUNT(ride_id) as count_rides,
  start_month
FROM `general-432301.wip.view_trip_data_report` 
WHERE
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  member_casual = 'casual'
  -- member_casual = 'member'
GROUP BY
  start_month
ORDER BY
  count_rides DESC
-- CASUAL: August (233,897), July (231,879) the busiest 
-- MEMBER: August (351,063), September (309,671) the busiest
-- CASUAL: January (17,713)
-- MEMBER: January (96,095) 

/* 6. Total rides by hour */
SELECT  
  start_hour,
  COUNT(ride_id) as count_rides,
FROM `general-432301.wip.view_trip_data_report` 
WHERE
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL 
GROUP BY
  start_hour
ORDER BY
  count_rides DESC
-- 5pm (445,479) and 4pm (393,901)

/* 7. Total rides by hour by member type*/
SELECT  
  start_hour,
  COUNT(ride_id) as count_rides,
FROM `general-432301.wip.view_trip_data_report` 
WHERE
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  member_casual = 'casual'
  -- member_casual = 'member'
GROUP BY
  start_hour
ORDER BY
  count_rides DESC
-- CASUAL: 5pm (144,957) and 4pm (135,739), all pm
-- MEMBER: 5pm (300,522) and 4pm (258,162), 3-7pm and 7-9am

/* 8. Trip duration by day of week */
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
