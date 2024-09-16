/* ----------- DATA ANALYSIS ------------ */

SELECT *
FROM `general-432301.wip.final_cyclistic_dataset` 
WHERE
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400
-- returns 4,178,369 records from the original 5,715,482. 

/* NOTE: The free-tier version of Big Query does not permit data deletion, so I will use the WHERE clause to filter out the NULL values and rides that were less than 1min and over 24h  */

/* 1. Total rides by membership type */
SELECT 
  member_casual,
  COUNT(DISTINCT ride_id) as num_rides
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400
GROUP BY
  member_casual
-- CASUAL: 1,469,640 casual rides
-- MEMBER: 2,708,729 member rides 
-- TOTAL: 4,178,369 rides in total

/* 2. Total rides by day of week */
SELECT 
  start_dayofweek,
  COUNT(DISTINCT ride_id) as num_rides
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL
  trip_duration > 60 and trip_duration < 86400
GROUP BY
  start_dayofweek
ORDER BY 
  num_rides DESC
-- Wednesday (644,558) and Saturday (637,324) busiest

/* 3. Total daily rides by membership */
SELECT 
  start_dayofweek,
  COUNT(DISTINCT ride_id) as num_rides
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and 
  trip_duration > 60 and trip_duration < 86400 and
  member_casual = 'casual'
  -- and member_casual = 'member'
GROUP BY
  start_dayofweek
ORDER BY 
  num_rides DESC
-- CASUAL: Saturday (302,899) and Sunday (250,730) 
-- MEMBER: Wednesday (456,583), Tuesday (437,680), and Thursday (426,346) 

/* 4. Total monthly rides */
SELECT  
  COUNT(DISTINCT ride_id) as num_rides
  start_month
FROM `general-432301.wip.final_cyclistic_dataset` 
WHERE
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400
GROUP BY
  start_month
ORDER BY
  count_rides DESC
-- August (574,402), July (537,496), September (498,069)

/* 5. Total monthly rides by membership type */
SELECT  
  COUNT(DISTINCT ride_id) as num_rides
  start_month
FROM `general-432301.wip.final_cyclistic_dataset` 
WHERE
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400 and
  member_casual = 'casual'
  -- member_casual = 'member'
GROUP BY
  start_month
ORDER BY
  count_rides DESC
-- CASUAL: August (230,175), July (230,057) the busiest 
-- MEMBER: August (344,227), July (307,439) the busiest

/* 6. Total rides by hour */
SELECT  
  start_hour,
  COUNT(DISTINCT ride_id) as num_rides
FROM `general-432301.wip.final_cyclistic_dataset` 
WHERE
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and 
  trip_duration > 60 and trip_duration < 86400
GROUP BY
  start_hour
ORDER BY
  count_rides DESC
-- 5pm (439,099) and 4pm (388,154)

/* 7. Total rides by hour by member type*/
SELECT  
  start_hour,
  COUNT(DISTINCT ride_id) as num_rides
FROM `general-432301.wip.final_cyclistic_dataset` 
WHERE
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400 and
  member_casual = 'casual'
  -- member_casual = 'member'
GROUP BY
  start_hour
ORDER BY
  count_rides DESC
-- CASUAL: 5pm (142,998) and 4pm (133,903), all afternoon
-- MEMBER: 5pm (296,101) and 4pm (254,251), 4-6pm and 7-8am


/* 8. Total distance travelled on rides > 1 min and < 24h */
SELECT 
  ROUND(SUM(distance_in_meters)/1000,2) as total_distance_km 
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400 /* these are seconds */
-- 23,306,068.14 kilometers

/* 9. Total distance travelled by member type */ 
SELECT 
  member_casual,
  ROUND(SUM(distance_in_meters)/1000,2) as total_distance_km 
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400 
GROUP BY
  member_casual
-- CASUAL: 8,713,622.16 kilometres
-- MEMBER: 14,592,445.97 kilometres
-- TOTAL: 23,306,068.14 kilometers

/* 10. Average distance by member type */
SELECT 
  member_casual,
  ROUND(AVG(distance_in_meters)/1000,2) as avg_distance_km  
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400 
GROUP BY
  member_casual
-- CASUAL: 5.93 km
-- MEMBER: 5.39 km 

/* 11. Total distance travelled each hour */
SELECT 
  start_hour,
  ROUND(SUM(distance_in_meters)/1000,2) as total_distance_km 
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400 and
  -- member_casual = 'member'
  member_casual = 'casual'
GROUP BY
  start_hour
ORDER BY
  total_distance_km desc
-- CASUAL: 4pm (848,089.94km) most of PM
-- MEMBER: 5pm (1,634,780.88km) 4-6 PM

/* 12. Total distance travelled each day */
SELECT 
  start_dayofweek,
  ROUND(SUM(distance_in_meters)/1000,2) as total_distance_km 
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400 
  member_casual = 'member'
  -- member_casual = 'casual'
GROUP BY
  start_dayofweek
ORDER BY
  total_distance_km desc
-- CASUAL: Sunday (1,775,954.58km) and Saturday (1,752,049.98km)
-- MEMBER: Wednesday (2,368,472.31km) and Thursday (2,353,693.24km)

/* 13. Total distance travelled each month */
SELECT 
  start_month,
  SUM(distance_in_meters)/1000 as total_distance_km 
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400 
  -- member_casual = 'member'
  member_casual = 'casual'
GROUP BY
  start_month
ORDER BY
  total_distance_km desc
-- CASUAL: September (1,436,710.96), then July, Aug, June
-- MEMBER: September (1,783,198.48), then Aug, July, May

/* 14. Average ride time in minutes */
SELECT 
  member_casual,
  ROUND(AVG(trip_duration)/60, 1) as avg_ridetime_min
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400 
GROUP BY
  member_casual
-- CASUAL: 24.3 minutes
-- MEMBER: 12.7 minutes

/* 15. Average ride time by day */
SELECT 
  start_dayofweek,
  ROUND(AVG(trip_duration)/60, 1) as  avg_ridetime_min
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400 and
  member_casual = 'casual'
  -- member_casual = 'member' 
GROUP BY
  start_dayofweek
ORDER BY
  avg_ridetime_min desc
-- CASUAL: Sunday (28.0 min) and Saturday (27.5 min); M-F 21.1 - 23.6 mins.
-- MEMBER: Sunday (14.2 min) and Saturday (14.2 min); M-F 12.0 - 12.5 mins.

/* 16. Avg ride time by hour */
SELECT 
  start_hour,
  ROUND(AVG(trip_duration)/60, 1) as  avg_ridetime_min
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400 and
  -- member_casual = 'casual'
  member_casual = 'member' 
GROUP BY
  start_hour
ORDER BY
  avg_ridetime_min desc
-- CASUAL: 10-11am (29.5 min)
-- MEMBER: 5-6pm (13.5 min)

/* 17. Total trips by bike type */
SELECT 
  rideable_type,
  casual_member,
  COUNT(DISTINCT ride_id) as num_rides
FROM `general-432301.wip.final_cyclistic_dataset` 
WHERE
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400
GROUP BY
  rideable_type,
  casual_member,
-- Electric (1,341,175), Classic (2,821,820), Docked (15,374)

/* 18. Most popular stations */
SELECT 
  start_station_name,
  start_station_id,
  COUNT(DISTINCT ride_id) as num_rides

FROM `general-432301.wip.view_trip_data_report` 

WHERE
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and 
  trip_duration > 60 and trip_duration < 86400 and
  member_casual = 'member'
  -- member_casual = 'casual'
GROUP BY
  start_station_id,
  start_station_name
ORDER BY
  num_rides DESC
LIMIT 10
-- CASUAL: Streeter Dr. & Grand Ave, DuSable Lake Shore & Monroe St.
-- MEMBER: Clinton St & Washington Blvd, Kingsbury St & Kinzie

/* 19. Average ride speed by rider type*/
SELECT 
  member_casual,
  COUNT(DISTINCT ride_id) as num_rides,
  ROUND(AVG(distance_in_meters/trip_duration),2) as avg_speed_metres_per_sec
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400 
GROUP BY
  member_casual
-- CASUAL: 8.67 m/s
-- MEMBER: 12.18 m/s

/* 20. Average ride speed by bike type */
SELECT 
  member_casual,
  rideable_type,
  COUNT(DISTINCT ride_id) as num_rides,
  ROUND(AVG(distance_in_meters/trip_duration),2) as avg_speed_metres_per_sec
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400 
GROUP BY
  member_casual,
  rideable_type
-- CASUAL: 8.17m/s (classic), 9.75m/s (electric)
-- MEMBER: 12.17m/s (classic), 12.21m/s (electric)

/* 21. Total distance (km) by bike type */
SELECT 
  rideable_type,
  COUNT(DISTINCT ride_id) as num_rides,
  ROUND(SUM(distance_in_meters)/1000,2) as total_distance_km
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400 
GROUP BY
  rideable_type
-- classic: 16,224,696.81 km
-- electric: 6,991,816.42 km
-- docked: 89,557.6 km

/* 22. Average ride time (minutes) by bike type */
SELECT 
  rideable_type,
  COUNT(DISTINCT ride_id) as num_rides,
  ROUND(AVG(trip_duration)/60,2) as avg_ride_time_mins
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400 
GROUP BY
  rideable_type
-- docked: 56.15 mins
-- classic: 18.52 mins
-- electric: 12.6 mins

/* without filters */
SELECT 
  rideable_type,
  COUNT(DISTINCT ride_id) as num_rides,
  ROUND(AVG(trip_duration)/60,2) as avg_ride_time_mins
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
GROUP BY
  rideable_type
-- docked: 260.62 mins (!!!)
-- classic: 22.23 mins
-- electric: 12.41 mins

/* 23: Total ride time (minutes) by bike type */
SELECT 
  rideable_type,
  COUNT(DISTINCT ride_id) as num_rides,
  ROUND(SUM(trip_duration)/3600,2) as total_ride_time_hours
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
WHERE 
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400 
GROUP BY
  rideable_type
-- classic: 871,031.16 hours
-- electric: 281,626.97 hours
-- docked: 14,386.79 hours


/* Q: What exactly is a docked_bike and why are members not using them?? */
SELECT *
FROM `general-432301.wip.final_cyclistic_dataset` 
WHERE
  rideable_type = 'docked_bike'and
  start_station_id IS NOT NULL and
  start_station_name IS NOT NULL and
  end_station_id IS NOT NULL and
  end_station_name IS NOT NULL and
  trip_duration > 60 and trip_duration < 86400
  --15,374 rows and only used by casual riders.

/* Q: Why are all the longest rides on docked bikes? */
SELECT *
FROM 
  `general-432301.wip.final_cyclistic_dataset` 
ORDER BY
  trip_duration desc
-- top 274 results had trip_durations > 105,922 seconds = 29.2 hours!!