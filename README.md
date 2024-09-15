# Cyclistic Case Study 🚲
<p>Carmen Chow</p> 
<p>August 2024</p>

<h2>Background</h2>
<p>Cyclistic is a successful bike-share company in Chicago. Since 2016, its program has grown to a fleet of 5,824 bicycles that are geotracked and locked into a network of 692 stations across Chicago. Customers who purchase single-ride or full-day passes are referred to as <b>casual riders</b> and those who purchase annual memberships are Cyclistic <b>members</b>. 
  
The director of marketing believes the company's future success depends on maximizing the number of annual memberships by converting casual riders into annual members. In order to do that, the team needs to better understand how casual riders and annual members use Cyclistic bikes differently. To do that, we will be analyzing the Cyclistic historical bike trip data to identify meaningful trends.

<h2>Stakeholders</h2>
<p>*  Lily Moreno: The director of marketing and your manager. </p>
<p>*  Cyclistic marketing analytics team: A team of data analysts who are responsible for
collecting, analyzing, and reporting data that helps guide Cyclistic marketing strategy.</p>
<p>*  Cyclistic executive team: They will decide whether to approve the recommended marketing program.</p>

<h2>1. Ask</h2>
<h3><b>Business Task</b></h3>
Understand how annual members and casual riders use Cyclistic bikes differently in order to convert riders into annual members.

<h2>2. Prepare</h2>

<h3><b>Data Source</b></h3>
I will use the last 12 months (August 2023 - July 2024) of Cyclistic's publically available historical trip data, available at https://divvy-tripdata.s3.amazonaws.com/index.html  The data is structured in wide formats in records and fields with ride-related information about both casual riders and members, types of bikes, and the start and end station information (station id, station name, latitude and longitude coordinates) of each bike trip. The anonymized data is made available by Motivate International Inc. under this license - https://divvybikes.com/data-license-agreement .

The second data source we will be using is the City of Chicago's Data Portal https://data.cityofchicago.org/Transportation/Divvy-Bicycle-Stations/bbyy-e7gq/data which provides a list of bicycle station ids and names.

<h3><b>Data Bias and Credibility. Does it ROCCC?</b></h3>
<p>Reliable - Yes: the dataset is public and unbiased
<p>Original - Yes: data is first-party data, collected by the company itself
<p>Comprehensive - Yes: > 5 million rows of historical trip data from the year 2020 
<p>Current - Yes: data is from the past 12 months
<p>Cited - Yes: data is public, vetted, and available on the company's website

<h3><b>Data Limitations</b></h3>
A number of start_station_id and end_station_id's have NULL values. Due to the limitations of the free-tier version of Google Big Query, we'll be filtering out these values instead of deleting them from the dataset to handle the errors. Since the data ROCCCs, I've determined that it will be be enough for the Business Task. 

<h2>2. Prepare</h2>
Previewing the files in Excel show the the name and format of each column head is identical in structure and have the same columne names which means we will be unioning instead of joining the data sets. I've decided to use Google Big Query for my data cleansing and analysis due to it's ability to handle larger volumes of data.  First, I'll create a table and enter the column header names and their data types. 

![schema](https://github.com/user-attachments/assets/507afc06-7550-4db5-8fde-80341e138b0f)

Next, I will use the Google Cloud CLI to upload the first CSV file to the Big Query. Instructions for installing and running the Google Cloud CLI is available here: https://cloud.google.com/sdk/docs/install-sdk 

and the command for uploading the first data set: 202308-divvy-tripdata.csv  

```bq load - replace - skip_leading_rows=1 general-432301:wip.tripdata_t.est"C:\Users\carmen\Desktop\12_months_csv\202308-divvy-tripdata.csv```

To upload and merge the remaining 11 CSV files to the first one, I will replace the `replace` command with `noreplace` to add the taable to the bottom of the previous table instead of JOINing it. Instead of combinging data into new columns, we'll join them into new rows.

``` bq load - replace - skip_leading_rows=1 general-432301:wip.tripdata_t.est"C:\Users\carmen\Desktop\12_months_csv\202309-divvy-tripdata.csv" ```

We have now imported and merged all 12 datasets giving us 5,715,693 rows. We can move on to the process the raw data.

<h2>3. Process</h2>
<h3><i>Data Exploration</i></h3>

Before cleaning the data, it's beneficial to explore the data and see what we have to work with that will inform our cleansing process. Looking at the dataset, we see columns contain qualitative or descriptive data, also known as dimensions. These dimensions can be grouped into 3 categories: station data, ride data, and time (?) data. Our table has columns for `ride_id`, `start_station_id`, and `end_station_id`. We would reasonably expect each bike trip to start at a single station and end at a single station, and for those stations to have their own station name. In other words, we would expect `start_station_id` to have a 1 to 1 relationship with `start_station_name`, likewise with `end_station_id` and `end _station_name`.

Let's run a query on start_station_id to see if there are instances where start_station_id and start_station_name have a 1 to many relationship:

![start_station_id_2](https://github.com/user-attachments/assets/93d9394a-9996-46b3-b57d-92b700688292)

There are, in fact, 83 records of start_station_ids with more than one start_station_name associated with it.

![station_id_83](https://github.com/user-attachments/assets/b5c304d9-e934-4b06-9b19-12aff3ec8f10)

Let's run a query and filter on the first result, the station with the id '647':

![station_id](https://github.com/user-attachments/assets/f1706f92-3d36-4174-b864-aef8458818ae)

We have three different names. In order to find the correct name, we'll turn to our second data source, the city of Chicago Data Portal's website  https://data.cityofchicago.org/Transportation/Divvy-Bicycle-Stations/bbyy-e7gq/data which gives us the correct station name when we look up '647'

![647](https://github.com/user-attachments/assets/2d246d9c-5299-4d0c-88f2-43d4792cbadc)

We're able to establish that <i>Racine Ave. & 57th St.</i> is the station 647's correct station name. Now, let's see if there are instances of a 1 to many relationship between our station_id and start_lat:

![start_lat2](https://github.com/user-attachments/assets/4adca5e0-98c6-4caf-bd9c-6abb83edb9c7)

We have ....

![start_lat_results](https://github.com/user-attachments/assets/9a2e8f9b-4927-4812-b2eb-b5b5426bf159)

Filtering on a result:

![roundLat](https://github.com/user-attachments/assets/da82099b-8078-4ad9-ae38-52645c7ab0e2)



<h3><i>Data Cleansing</i></h3>
We've discovered that the expected 1:1 relationship between station_id and other qualitative data such as it's name and latitude is not enforced, and performing a lookup for the correct name, although possible, would not be practical or time efficient. To handle the variance of multiple records, we can aggregate the rows and reduce it into a single row to enforce that 1:1 relationship.

We'll create a dimension table with `start_station_id` as the primary key that we will later rejoin to the main table. Since the `SUM()` is only used on numerical values, we'll aggregate data for each `start_station_id` using the `MAX()` function to find the MAX values for `lat`, `lng`, and `station_name`. We'll do the same for end_station. Then we'll combine the results of the two inner queries with the `UNION ALL` operator to put the rows underneath. In doing so, we'll aggregate the combined results to get a single record for each 'start_station_id`. Note that using the `MIN()` function would also work in this case.
For our purposes, we can use Chicago's website to retrieve the correct station name in the latter part of our analyis for the top 10 stations; however for now, we just want SQL to return a single value for for the station's name, latitude, and longitude which an aggregate function will accomplish. We'll also format the lat and lng values by rounding them to 6 decimal places.

We'll treat both `start_station_id` and `end_station_id` as `station_id` which will be the primary key used to join the results of the inner queries.

Create ride_data table:

<b> Joining the cleaned table to main table</b>

<p>Applying the same thinking, we'll use `MAX()` again, this time to aggregate the following columns from our main `tripdata` table: `rideable_type`, `started_at`, `ended_at`, `member_casual`, etc  for each `ride_id`. 
  
<p><i>Note: <b>rideable_type</b> - classic_bike, electric_bike, or docked), </p>
<p><b>member_casual</b> - member or casual</p>

<p>We'll join the results of our aggregate `tripdata` table with the previous dimension table twice, in order to combine the `start_station` and `end_station` details.</p>

![final_join](https://github.com/user-attachments/assets/c2ae5f80-e7a1-49c6-871a-a70f3bfb8270)

Now let's run a query twice: once on our cleaned data and the other on our dirty data to see the difference. We should return a single row for each station_id:


![cleaned_station](https://github.com/user-attachments/assets/e5285795-9ddd-4a2c-9e96-8e13823bc662)

Let's view our new table with the new rows:

![final](https://github.com/user-attachments/assets/5772fec2-5999-4102-8a6d-8e88f4d2a1e5)


<h2>4. Analyze</h2>

For our analysis we'll be filtering out NULL values for <b>start_station_id, end_station_id, start_station_name, and end_station_name</b>. These missing values would indicate that bikes were not properly check out or docked. There are records where the end time was earlier than the start time, resulting in a negative <b>trip_duration</b> value. We will also filter out any rides that were over 24 h long. With these removals we'll be looking at <b>4,178,369 records from the original 5,715,482</b>

I used Tableau to visualize my analysis and return to our original question:

<b><i>How do annual members and casual riders use Cyclistic bikes differently?</i></b>

Let's take a look at how members vs. casual's ride activity differ over the period of a day, a week, and a year. Annual riders are most active on Wednesday. Removing all start_station_ids that have a value of NULL, we can see that casual riders riding activity is pretty consisiten Monday to Friday while logging slightly higher number of rides on the weekend. For annual riders, Wednesday and Saturdays see the highest number of activity. Whereas casual riders are most active on the weekend.

Count:

Rides by member type:
![ridemembers](https://github.com/user-attachments/assets/f7cb498b-5e06-45d2-8f72-b694ecddbd9e)



Hourly Rides: 
![hourly_rides](https://github.com/user-attachments/assets/6c713975-6ccc-4401-b45d-c566ec18a0c6)

Daily Rides:
![ride_day](https://github.com/user-attachments/assets/7350ed00-04a7-4482-94ec-4a0c79c907c3)


Monthyly rides:
![monthly_rides](https://github.com/user-attachments/assets/bd62f6c4-ab37-4ff6-bde8-8cd15651444e)


Distance:

Day: 
![km by day](https://github.com/user-attachments/assets/04361783-4c23-4dbd-94b7-e7ee37301cdf)


Month: ![distance_month](https://github.com/user-attachments/assets/fd17fe7e-87a9-4037-8cd3-95e318dac040)

![distancebymonth](https://github.com/user-attachments/assets/98c62ff4-7005-4867-9834-e81335f4cf73)



Ride Time:
![avg ride time hour](https://github.com/user-attachments/assets/e3cd72eb-351f-42c4-a1ba-c26552cd6cfe)


Speed: 
![bike_type_speed](https://github.com/user-attachments/assets/8a23f2fa-0ea9-42d2-b5f7-8cf395c581f3)
![avg sped type](https://github.com/user-attachments/assets/8ca80245-9192-4fda-a33e-a370df955c61)

Stations:

![top_10_casual_stations](https://github.com/user-attachments/assets/d03735fb-5d3d-42f3-9faa-1346d46c0704)


![casual_station_map](https://github.com/user-attachments/assets/e105abd6-eb7c-47f9-9e2f-ff51efd91a50)

![top_10_members_station](https://github.com/user-attachments/assets/c75687f2-df9d-4a45-ba48-3a6e3287befd)

![member_station_map](https://github.com/user-attachments/assets/510c9e6a-110f-402f-a133-8344fcd3a27a)


<h2>5. Share</h2>

Tableau 
Google Slides

<h2>6. Act</h2>


![avg_spee](https://github.com/user-attachments/assets/479beb74-ad8d-4667-8bc4-3aeb8525e5e9)

<h2> Final Thoughts</h2>
Docked bikes - on average log rides that are over 24 hours long, outliers that brought up the average. Were they mislabelled, either classic or electric bikes?
