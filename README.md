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
  
<p><i>Note: <b>rideable_type</b> - classic_bike, electric_bike, or docked), </i></p>
<p><b>member_casual</b> - member or casual</p>

<p>We'll join the results of our aggregate `tripdata` table with the previous dimension table twice, in order to combine the `start_station` and `end_station` details.</p>

![final_join](https://github.com/user-attachments/assets/c2ae5f80-e7a1-49c6-871a-a70f3bfb8270)

Now let's run a query twice: once on our cleaned data and the other on our dirty data to see the difference. We should return a single row for each station_id:


![cleaned_station](https://github.com/user-attachments/assets/e5285795-9ddd-4a2c-9e96-8e13823bc662)

Let's view our new table with the new rows:

![final](https://github.com/user-attachments/assets/5772fec2-5999-4102-8a6d-8e88f4d2a1e5)


<h2>4. Analyze</h2>

For our analysis we'll be filtering out NULL values for <b>start_station_id, end_station_id, start_station_name, and end_station_name</b>. These missing values would indicate that bikes were not properly check out or docked. There are records where the end time was earlier than the start time, resulting in a negative <b>trip_duration</b> value. We will also filter out any rides that were over 24 h long. With these removals we'll be looking at <b>4,178,369 records from the original 5,715,482</b> 

** <i>I'm using the free tier version of BigQuery which doesn't permit data deletion; for this reason I'll be handling errors by filtering out NULL and negative results</i>

I used Tableau to visualize my analysis and return to our original question:

<b><i>How do annual members and casual riders use Cyclistic bikes differently?</i></b>

Let's take a look at how members vs. casual's ride activity differ over the period of a day, a week, and a year. Annual riders are most active on Wednesday. Removing all start_station_ids that have a value of NULL, we can see that casual riders riding activity is pretty consisiten Monday to Friday while logging slightly higher number of rides on the weekend. For annual riders, Wednesday and Saturdays see the highest number of activity. Whereas casual riders are most active on the weekend.

Count:

Rides by member type:
![ridemembers](https://github.com/user-attachments/assets/f7cb498b-5e06-45d2-8f72-b694ecddbd9e)

We also see that annual riders log <b>2,708,729</b> total rides in the last 12 months versus casual riders who logged <b>1,469,640 rides</b>. Rides totalled <b>4,178,369 rides</b> in totalwith annual rides comprising 64.83%of rides and casual riders making up 35.17% of rides.

Daily Rides:
![ride_day](https://github.com/user-attachments/assets/7350ed00-04a7-4482-94ec-4a0c79c907c3)

Weekends buiest for casuals members. Casual riders take longer rides on weekends compared to member riders. In fact casual riders logged 11,896.32 hours more on Sunday than their member counterparts.

![total_daily_rides](https://github.com/user-attachments/assets/5a2c8aa6-7116-4baf-bd25-c2dbdbdb7319) (check for accuracy with newest track)

To get a closer analyze of our rider profile and what might be influencing their riding patterns let's drill down into the chart and look at their hourly at their riding activity spread through a single day. Let's take a look at the ride activity for member over a 24 hour period.

Hourly Rides: 
![hourly_rides](https://github.com/user-attachments/assets/6c713975-6ccc-4401-b45d-c566ec18a0c6)

Comparing casual and member riders, we can see that activity increases from 6–9 amd peaking at 8am. The times from 4pm to 7pm we see a similar heightened activity peaking am and 5pm throughout a given day. This could coincide with tms when riders leave for work and return home at the end of the day. This could lead support to the argument that our member riders primarly use the bike for to commute to work whereas casual members could be using it for leisure or sightseeing. Ride activities on weekend show the same periods of inactivity




Monthyly rides:
![monthly_rides](https://github.com/user-attachments/assets/bd62f6c4-ab37-4ff6-bde8-8cd15651444e)

For annual riders most trips occrs ......

Distance:

Day: 
![km by day](https://github.com/user-attachments/assets/04361783-4c23-4dbd-94b7-e7ee37301cdf)


Month: ![distance_month](https://github.com/user-attachments/assets/fd17fe7e-87a9-4037-8cd3-95e318dac040)

Ride Time:
![avg ride time hour](https://github.com/user-attachments/assets/e3cd72eb-351f-42c4-a1ba-c26552cd6cfe)

Seasonality changes, casual ridership increase from April to May (Summer months). In April the total distance was _________ and it went up to _________ in  _________, an increase of  _________ and drops from _________ metres to  _________ metres from S _________. 
Compared to annual ridership which has a wider spread but also peask in August and September.


<b>Speed:</b> 

We'll calculate average speed of each ride by taking the distance and dividing it by the trip duration. 
![bike_type_speed](https://github.com/user-attachments/assets/8a23f2fa-0ea9-42d2-b5f7-8cf395c581f3)
![avg sped type](https://github.com/user-attachments/assets/8ca80245-9192-4fda-a33e-a370df955c61)

<b>Bike Preferences:</b>

Both casual and annual members prefer the classic bikes over the electric bikes: Casual riders 966,128 out of 1,469,640 rides were on classic bikes (65.73%) and for annual members, 68.50% or 1,855,692 out of the 2,708,729 rides. 


<b>Stations:</b>

I used the Chicago Data Portal website to plot the start stations most frequented by both groups of riders: 

For casual riders, the most popular bike station was Streeter Dr. & Grand Ave with  DuSable Lake Shore & Monroe St.


![top_10_casual_station](https://github.com/user-attachments/assets/c69c372f-defd-430f-a006-aa245601bb7e)


![casual_station_map](https://github.com/user-attachments/assets/e105abd6-eb7c-47f9-9e2f-ff51efd91a50)

Annual members top station was Clinton St & Washington Blvd, Kingsbury St & Kinzie

![top_10_members_station](https://github.com/user-attachments/assets/530efb66-a505-4e70-84f3-344b4a23edf9)


![member_station_map](https://github.com/user-attachments/assets/510c9e6a-110f-402f-a133-8344fcd3a27a)


<h2>5. Share</h2>

Tableau 
Google Slides

Based on our findings, it would appear that casual riders could be tourists, leisure riders.

<h2>6. Act</h2>

My analysis shows key differences in how casual riders and member riders use Cyclistic's bikes. Namely, casual riders primarily use the bikes for leisure or sightseeing purposes. I determined 

<b>Casual Rider</b>
* Most active on weekends from 12–5pm
* Preferred start stations near tourist attractions
* Average ride time m/s
* Average speed 

<b>Member Riders</b>
* Most active day of the week and hour:
* Preferred start stations away fro tourist attractions spread across - 
* Average ride time m/s
* Average speed 

Based on these conclusion I'll meka the following recommndatsion to Moreno and the marketing team.

<i>Suggestion #1:</i>
<p><b>Seasonality/Short-term options</b>  - Campaigns target at causal member advertisting upgrades to annual memberships that highlight cost of savings, distance et. A discounted rate or other attractivee offers such advertisements at specific hotspots (See the top 10 visited stations) .

Introducing a new pricing structure that would logically move people from causal to annual memberhipsj. Offering sign-up discounts or incentives to incentive causal membership to purchase annual memberships to increase enrollment.

Tiered Membership and Pricing Structure 

For riders who are not ready to make the leap from a casual member to an annual member, a monthly program at a fixed, reduced price can be successful in eventually transitioning this demographic to an annual membership. Running campaigns that highlight the dollar cost money saved, something along the lines of "1 Divvy bike trip is equal to 1 ride" 

To further incentive the annual memberhips, introduce a cost to casual riders by either increase after a certain distance quota is reached. For omparison sake - introduce a new rate structure, let's take a look at Chicago's Divvy Bike structure: Since casual riders are the most active during the summer months, launch campaigns ahead of the summer months that and introduce a monthly pass
Although Cyclistiic is a fictional company, we can draw comparisons to Chicgago's DIvvy bikeshare program whose pay structure is posted ont heir website: 
https://divvybikes.com/pricing 
Other groups (particually students or low-income would be encouraged a a monthly membership or quarterly.

Offer a two-teired annual plan where members have teh option to pay up front or month to month in installments may be more feasibale to increase and retain enrollment.
Offering member-only perks such as community events, longer ride times etc.



<b>Suggestion #2:</b>
<p><b>Partner with Entertainment </b></p>
Partner with local business to offer discounts on admissions to local attractions that casual members are known to frequent . If we had data regarding the income/employment of our causal readers arntering ewith university to offer students and staff discounts. Opening and installing bike share stations on campuses or expanding to area where the core of riders work and live to connect to their riders convenience. Partnering with businesses along routes with the most traffic and offering discounts at those businesses (exclusive deals for Cyclistic annual members).
Partnering iwth local restaurants and businesses contribute to the local economy while supporting local retailers. These businesses could be where people shop, run errands
Location Expansion

<b>Suggestion #3: </b>
Opening stations around gyms/fitness centres to promote a healthier alternative / replace car trips
This could be done by removing bikes from least popular areas (a total of 67 stations only logged 1 ride in the last 12 months for example from July 2023 - August 2024) and building to ensure people in underserviced areas can find a ike. Ensure equity is met by providing bikes to underserved communities?

![underused_stations](https://github.com/user-attachments/assets/cc461526-1bef-49d1-9216-36f66113491d)


Partnering with Offering a youth pilot program with schools. Many primary and high schools also have walkathons/ lunch and afterschool walking clubs that would go hand in hand with the bike program. 

<h2> Final Thoughts</h2>

More information needs to be gathered about docked bikes - on average log rides that are over 24 hours long, outliers that brought up the average. Were they mislabelled, either classic or electric bikes? Classic bikes are the preferred bikes by both member and casual riders, and only casual members use docked bikes. Of the rides taken on docked bikes, several were multiday trips that didn't have end_stations. These outliers will be removed.

Since the dataset containes only anonymized data. In addition to sensitive PII, the dataset also excludes any non-sensitive PII such as riders' gender, date of birth, educational and work background which would have provided a more granular user profile that could lead to potentially impactful targeted advertisements specific to our riders' needs.
Examples of how Cyclistics could use this additional ifnormation: 
  
  * Offering a subsized program for and youths low-income 
  * Offering family discounts
  * Opening new bike stations on university campuses for to provide greater access for students 
  * Partnering with some of Chicago's largest employers to offer discounted member passes to employees

In conclusion, focusing on marketing camaptings that highlight the savings and the helath and environen benefits. casual members will make when switching to a full membership
partnering with local businesses by providing dicscounts on attractions etc, and restructing their pricing plan will incentive casual members to take the lead to full membership. 

These insights will help Cyclistic boost their conversion rate while continuing to provide an affordable, sustainable green alaterative. 
