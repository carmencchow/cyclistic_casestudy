/* ------- Data Cleansing: Create separate tables -----------*/

/* 1. Station Data Table - Create a dimension table that contains aggregated start and end station data that we will union with station_id as the primary key */

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


/* 2. Ride Data Table - Create a dimension table that contains aggregated ride_data */

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

/* 3. Merge ride_data with start_station and end_station data on station_id with two left joins */

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

/* 4. Clean up final table: format dates and add 6 new columns: start_dayofweek, start_month, start_am_pm, start_hour, trip_duration, and distance_in_meters; connect to Tableau for data viz*/

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

