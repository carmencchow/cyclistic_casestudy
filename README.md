# Cyclistic Case Study 🚲 

<p>Carmen Chow</p> 
<p>September 2024</p>

<h2>Background</h2>
<p>Cyclistic is a successful bike-share company in Chicago. Since 2016, its program has grown to a fleet of 5,824 bicycles that are geotracked and locked into a network of 692 stations across Chicago. Customers who purchase single-ride or full-day passes are referred to as <b>casual riders</b> and those who purchase annual memberships are Cyclistic <b>members</b>. 
  
The director of marketing believes the company's future success depends on maximizing the number of annual memberships by converting casual riders into annual members. In order to do that, the team needs to better understand how casual riders and annual members use Cyclistic bikes differently. To do this, we will be analyzing historical bike trip data to identify cycling trends. 

<h2>Stakeholders</h2>

*  <b>Lily Moreno</b>: The director of marketing and your manager. </p>

*  <b>Cyclistic marketing analytics team</b>: A team of data analysts who are responsible for collecting, analyzing, and reporting data that helps guide Cyclistic marketing strategy.</p>

*  <b>Cyclistic executive team</b>: They will decide whether to approve the recommended marketing program.</p>

<h2>1. Ask</h2>
<h3><b>Business Task</b></h3>
Understand how <b>annual members and casual riders use Cyclistic bikes differently</b> in order to convert casual riders into annual members.

<h2>2. Prepare</h2>

<h3><b>Data Source</b></h3>
We will look at 12 months of Cyclistic's publicly available historical ride data (August 2023 - July 2024), which is available at https://divvy-tripdata.s3.amazonaws.com/index.html . This anonymized trip data includes information such as bike type, station names, station IDs, station latitudes and station longitudes. It is provided by Motivate International Inc. and available at https://divvybikes.com/data-license-agreement. We will also use the City of Chicago's Data Portal, available at https://data.cityofchicago.org/Transportation/Divvy-Bicycle-Stations/bbyy-e7gq/data to plot the latitudes and longitudes of of the most visited stations. 

<h3><b>Data Bias and Credibility. Does it ROCCC?</b></h3>
<p><b>R</b>eliable - Yes, the dataset is public and unbiased.
<p><b>O</b>riginal - Yes, the data is first-party data, collected by the company itself.
<p><b>C</b>omprehensive - Yes, there are over 5 million rows of historical trip data from the year 2020 to now. 
<p><b>C</b>urrent - Yes, the data is from the past 12 months.
<p><b>C</b>ited - Yes, the data is public, vetted, and available on the company's website.

<h3><b>Data Limitations</b></h3>

The dataset contains over 5.7 million records, with more than 1.5 million entries having NULL or negative values in the  `start_station_name`, `start_station_id`, `end_station_name`, and `end_station_id` columns. We'll use Google Big Query instead of Excel for data cleansing and analysis. Since the free-tier version of Big Query does not support data deletion, I will filter out the NULL and negative values in the analysis.  

<p>Previewing the CSV files in Excel shows that the column names are identical across all the files, which means we will not need to join the tables to add new columns. Instead we can union the tables by appending them to the bottom of the previous table. 
  
We'll create a table and specify the column header names and their data types before using the Google Cloud CLI to upload the first CSV file to Big Query.
  
<p>

![schema](https://github.com/user-attachments/assets/507afc06-7550-4db5-8fde-80341e138b0f)

Instructions for installing and running the Google Cloud CLI are available here: https://cloud.google.com/sdk/docs/install-sdk . We'll use the following `bq` command to load the first file, <i>202308-divvy-tripdata.csv</i> to BigQuery: 

```bq load - replace - skip_leading_rows=1 general-432301:wip.tripdata_t.est"C:\Users\carmen\Desktop\12_months_csv\202308-divvy-tripdata.csv```

The remaining 11 CSV files will be loaded and unioned to the bottom of our new table with the `noreplace` command, which will create new rows instead of columns of data. Here's the complete command:

``` bq load - replace - skip_leading_rows=1 general-432301:wip.tripdata_t.est"C:\Users\carmen\Desktop\12_months_csv\202309-divvy-tripdata.csv" ```

We have now imported and merged all 12 datasets giving us 5,715,482 rows of data. Let's go ahead and process the data.

<h2>3. Process</h2>
<h3>Data Exploration</h3>

Before cleaning the data, it's beneficial to explore what we are working with. Looking at our table,  we can group our columns into three categories of qualitative data: data about stations, data about rides, and data related to start and end times. Here's the schema showing each field name and data type.

![schema1](https://github.com/user-attachments/assets/a0e1a99e-6277-4ee5-86cd-b50a9a7eb768)
![schema2](https://github.com/user-attachments/assets/8c034d55-782b-43bc-bffc-2095c9c6cac6)

Let's explore the relationships between some of our columns and see whether they are one-to-one or one-to-many relationships. We'll start with a bike station, which we would expect to have only one station name associated with it. We'll run a query on `start_station_id` to check for instances where a `start_station_id` has multiple `start_station_names`. 

![start_station_id_2](https://github.com/user-attachments/assets/93d9394a-9996-46b3-b57d-92b700688292)

We see that there are, in fact, <b>83 records of `start_station_id`s linked to more than one `start_station_name`</b>. 

![station_id_83](https://github.com/user-attachments/assets/b5c304d9-e934-4b06-9b19-12aff3ec8f10)

Let's examine the first result: station `647`.

![station_id](https://github.com/user-attachments/assets/f1706f92-3d36-4174-b864-aef8458818ae)

This returns three different station names for station `647`. To find the correct name, we will have to use our secondary data source - the City of Chicago Data Portal's website (link provided above) - and look up the station id in its database.

![647](https://github.com/user-attachments/assets/2d246d9c-5299-4d0c-88f2-43d4792cbadc)

It looks like <i>Racine Ave. & 57th</i> is the station's actual name. While we were able to retrieve the correct name with this lookup, this would not be an efficient method to repeat with 82 other `start_station_id`s. Let's see if `start_lat` also yields multiple results for any single `start_station_id`:

![start_lat2](https://github.com/user-attachments/assets/4adca5e0-98c6-4caf-bd9c-6abb83edb9c7)

There are 1,588 records where a single `start_station_id` is associated with multiple `start_lat` values. 

![start_lat_results](https://github.com/user-attachments/assets/9a2e8f9b-4927-4812-b2eb-b5b5426bf159)

Let's filter on the first row: station <i>WL-012</i>:

![roundLat](https://github.com/user-attachments/assets/da82099b-8078-4ad9-ae38-52645c7ab0e2)

We see that the 7,232 different latitudes are the result of inconsistent number formatting. We'll need to clean our data to ensure that each `start_station_id` has only one `start_station_name`, one `start_lat`, and one `start_lng` associated with it.


<h3>Data Cleansing</h3>

Through our data exploration, we discovered that the expected one-to-one relationship between `start_station_id` and other dimensions such as `start_station_name` and `start_lat` was not been enforced. As mentioned, performing a lookup for each of the 83 station names, while possible, would not be practical. Instead, we'll aggregate the multiple results for each `start_station_id` into a single entry to create a one-to-one relationship between `start_station_id` and other station-related data points.

To do this, we'll create a new table with `start_station_id` as the primary key, and we will bring in only station-related data. After cleaning this data, we will rejoin it with the original main table. 

<b>Why aggregate our data?</b>

<p>Aggregating will allow us to consolidate multiple rows of data into a single row. Common aggregation functions include SUM(), MIN(), MAX() and AVG(). Since SUM() and AVG() only work with numeric values, we will use MAX() instead to handle our  `start_station_id` and `start_station_name` string types. We will also aggregate
the `end_station` data to ensure all related station data is clean. Then we will use `station_id` as the primary key to union the cleaned `start_station` and `end_station` data into a clean `station_data` table.
  
Let's create the new `station_data` table:

![station_data](https://github.com/user-attachments/assets/1fb42ae3-0d62-4e61-b3d0-9a2f101d84b1)

We'll run the query we ran before that filtered on `station_id 647`. This time, we will execute it twice: once on our cleaned data and once on the original dataset to see the difference. On the left, we've returned the original result, showing examples of one-to-many relationship between `start_station_id` and `start_station_name`. On the right, our cleaned data shows that each `start_station_id` has a single `start_station_name.`

![cleaned_station](https://github.com/user-attachments/assets/e5285795-9ddd-4a2c-9e96-8e13823bc662)

<b>Ride data table</b>

<p>Let's create a separate table for our ride-related fields. We'll apply the same thinking and use MAX() to aggregate the ride-related fields from our main table. 

![ride_data](https://github.com/user-attachments/assets/ce608c9b-2fee-4f3b-8fa5-55d9c717596f)

We can now join the two cleaned `station_data` and `ride_data` tables together:

![finaljoin](https://github.com/user-attachments/assets/41ac54ed-394a-4f45-a0fe-bdf1f3f3947e)

<p>
We will also create the following new columns:

```
start_dayofweek,
start_month,
start_hour,
trip_duration,
distance_in_meters
```

![final](https://github.com/user-attachments/assets/6c2fcd2c-816f-48e3-89e6-418f2898b43a)

Our data cleansing is done. Let's see what trends and patterns our analysis will reveal.

<h2>4. Analyze</h2>

After connecting a new Tableau workbook to our Google Big Query server, we can begin visualizing the relationships between different fields. Let's revisit the original question:

<b><i>How do annual members and casual riders use Cyclistic bikes differently?</i></b>

<b>Number of Rides</b>

The pie chart shows that a combined <b>4,178,369</b> (or 4.18 million) unique rides were taken by both groups from June 2023 to August 2024. Of these, rides by annual members made up <b>64.8%</b> (or 2.71 million) of the total number, and casual riders accounted for <b>35.2%</b> or 1.47 million rides.

![ridemembers](https://github.com/user-attachments/assets/f7cb498b-5e06-45d2-8f72-b694ecddbd9e)

<b>Bike Preference</b>
<p>Do casual riders and annual members favor different types of bikes?

![member_bike](https://github.com/user-attachments/assets/aeaf044a-c0cd-44e5-b9a9-bae98d96c09d)

![casual_bike](https://github.com/user-attachments/assets/153a551e-ff0c-43fe-98a2-2f27759d9059)

Both casual and annual members prefer classic bikes over electric bikes. For casual riders, <b>65.73%</b> or 966,128 out of 1,469,640 rides were on classic bikes, while annual members used classic bikes for <b>68.50%</b> of their rides, which comes to 1,855,692 out of the 2,708,729 rides. Interestingly, docked bikes were used only used by casual riders, and half of these docked bikes were used on rides lasting either more than 24 hours or less than one minute. It might be worthwhile to ask Cyclistic to explain what a docked bike is and <i><b>why they are not being used by annual members</b></i>.

<p>
<h3><b> Daily Trends </b></h3>

We can see that the number of bike rides by annual members was fairly consistent from Monday to Friday, with a decrease on weekends and the highest number on Wednesday.  For casual riders, the ride count was highest on weekends.

![ride_day](https://github.com/user-attachments/assets/7350ed00-04a7-4482-94ec-4a0c79c907c3)

<b> Duration</b>
<p>
In addition to an uptick in the number of casual riders on weekends, weekend rides also tend to be <i><b>longer</b></i> rides. The average ride time from Monday to Friday was <b>22.18 minutes</b> while on weekends it increased to <b>27.75 minutes</b>. For annual members, ride times remained fairly consistent from Monday to Friday, averaging 12.19 minutes per ride. On weekends, there was only a slight increase, with an average ride time of 14.23 minutes. Zooming out, over the course of 12 months, casual riders logged 11,896.32 more hours than their member counterparts on Sundays, the day with the longest average ride time for both groups.

![ride_time (1)](https://github.com/user-attachments/assets/838d5c30-ed62-40e8-96c4-25eb51858f63)

<b> Distance</b>

We know that casual riders take longer rides on weekends, but are they also travelling greater distances? This line graph shows that casual riders are indeed travelling longer distances on weekends compared to weekdays. Over the course of a year, casual riders increased their distance travelled from <b>1,150,194</b> on Fridays to <b>1,775,955 kilometres</b> on Sundays. In contrast, annual members' distance decreased from Thursday to Sunday before picking up again at the start of the work week on Monday.


![km by day](https://github.com/user-attachments/assets/04361783-4c23-4dbd-94b7-e7ee37301cdf)

Let's take a look at both groups' activity over a 24-hour period:

![hourly_rides](https://github.com/user-attachments/assets/6c713975-6ccc-4401-b45d-c566ec18a0c6)

We see two peaks of high activity for annual members between 6-8am and 4-6pm, with the most active hours being 8am and 5pm. These peaks likely reflect when annual members are commuting to and from work. For casual riders, the chart shows a steady increase in ridership from 8am to 5pm, suggesting steady bike usage throughout the day.

Do peak hours correspond to longer ride times for casual riders and annual members?

![ride_time_hour](https://github.com/user-attachments/assets/fca57136-c070-4896-a4e9-61230390db3d)

For annual members, there is no significant change in time duration throughout the day, including at the peak hours of 8am and 5pm. This supports the idea that annual members are using Cyclistic bicycles for commuting. For casual members, the longest rides occur between 8am and 5pm, which supports the hypothesis that casual riders use bikes for recreational purposes, perhaps they have flexible work schedules, or they are tourists using the bikes to explore the city during the day. 

<b>Speed</b>

Let's see if the each group's average ride speed offers insights into how bike usage differs. We'll calculate the average speed of each ride by taking the distance and dividing it by the trip duration. 

![bike_type_speed](https://github.com/user-attachments/assets/8a23f2fa-0ea9-42d2-b5f7-8cf395c581f3)

![avg sped type](https://github.com/user-attachments/assets/8ca80245-9192-4fda-a33e-a370df955c61)

Let's compare the average speed of bike rides on classic bikes, the preferred bike for both groups of riders.  A casual rider's average speed on a classic bike is <b>8.17m/s</b> compared to an annual member's average speed of <b>12.17 m/s</b>. It appears that casual riders bike at a more leisurely pace, which make sense if they are mainly using bikes for sightseeing and exploration. 

<h3><b>Seasonal Trends</b></h3>

<p>Let's see if there are seasonal trends in bike usage across different months.

![monthly_rides](https://github.com/user-attachments/assets/bd62f6c4-ab37-4ff6-bde8-8cd15651444e)
  
The bar chart above shows that the number of rides by casual riders begins to increase in the spring and continues into the summer months, with June, July, and August having the highest number of rides. In fact, <b>from April 2024 to May 2024, the number of rides increased significantly by 79.4%</b>, rising from 92,111 to 164,316 rides, while the number of rides by annual members only increased by <b>34.8%</b>, from 200,293 to 270,000 during the same period. From October 2023 to November 2023, <b>casual riders saw a 44% decrease in rides, </b> dropping from 128,289 to 71,053, while annual members experienced a smaller 25.9% decrease, with the number of rides dropping from 268,598 to 199,086. 

April is when both groups start biking longer distances, with this trend continuing through spring and summer. Bike distances peak in September before dropping off again in the fall and winter months.

![distance_month](https://github.com/user-attachments/assets/fd17fe7e-87a9-4037-8cd3-95e318dac040)

<h3><b>Location</b></h3>

Do casual riders and annual members start their bike trips in the same part of the city? To find out, we'll use the Chicago Data Portal website to plot the latitudes and longitudes of the ten most frequented stations where casual riders and annual members began their trips. We'll start with casual riders: 

![top_10_casual_station](https://github.com/user-attachments/assets/c69c372f-defd-430f-a006-aa245601bb7e)

For casual riders, the most popular bike station was <b>Streeter Dr. & Grand Ave</b> with 46,993 rides, accounting for <b>32% of the total rides</b>. 

![casual_station_map](https://github.com/user-attachments/assets/e105abd6-eb7c-47f9-9e2f-ff51efd91a50)

Looking at the map, the 10 most popular stations are located close to Chicago's shoreline near tourist and sightseeing attractions like Adler Planetarium and Shedd Aquarium. 

For annual members, the most popular station was <b>Clinton St & Washington Blvd</b>, followed by <i>Kingsbury St & Kinzie.</i>

![top_10_members_station](https://github.com/user-attachments/assets/530efb66-a505-4e70-84f3-344b4a23edf9)

Annual Members tended to pick up bikes at stations located away from the shoreline and spread out across Near North Side, Magnificent Mile, and the Loop, Chicago's central business district.

![member_station_map](https://github.com/user-attachments/assets/510c9e6a-110f-402f-a133-8344fcd3a27a)


<h2>5. Share</h2>

Let's summarize our findings of the key differences in cycling trends between casual riders and annual members.

<b>Casual Riders</b>
* Most active time: 8am -7pm
* Most active day: Saturday and Sunday
* Most active month: July, July, and August
* Preferred start stations: near tourist attractions on the shoreline
* Average ride time on weekdays: 22.2 minutes
* Average ride time on weekend: 27.8 minutes
* Average distance: 5.93 kilometres
* Average speed on a classic bike: 8.17m/s

<b>Annual Members</b>
* Most active time: 8am and 5pm
* Most active day: Monday to Friday 
* Busiest months: July, August, and September
* Preferred start stations: spread out across commercial and financial areas
* Average ride time on weekdays: 12.2 minutes
* Average ride time on weekend: 14.2 minutes 
* Average distance: 5.39 kilometres
* Average speed on a classic bike: 12.17m/s

Based on these notable differences, we can conclude that annual members are people who use Cyclistic bikes to travel to and from work, while casual riders tend to use Cyclistic bikes for sightseeing and exploring the city.

Tableau 
Google Slides

<h2>6. Act</h2>

After looking at the trends in how casual rides use Cyclistic bikes, we'll propose the following recommendations which are aimed at boosting Cyclistic's annnual membership enrollment among casual riders. Extend reach and attract more riders

<b>1. Seasonal Ad Campaigns</b>   
<p>Cyclistic's future growth depends on growing annual ridership by converting casual members into long-term members. To do this, Cyclistic will need to time the launch of future enrollment and advertising campaigns before in March and April to raise awareness of Cyclistics annual membership program and genearte interest among more riders before the signficant 79.4% increase in ride count occurs from April to May. Cyclistic's ads should focus on the benefits of switching to a long-term membership, including savings costs, convenience and unlimited access to Cyclistic's fleet of bikes. 

<b>2. New/Flexible Pricing Model</b>
<p> Cyclistic can remove any perceived costs as barriers to a
  Cyclistic should implement a new pricing structure to increase enrollment in their annual membership. This could To further incentive annual memberhips, Cyclistic could include the following:
  
  * tiered membership, such as a monthly plan at a fixed price that could eventually encourage casual riders to become full members.
    
  *  Overcharge fee for casual riders if they reach for every additional 10 or 20 minutes, or kilometres cycled.
    
  *  Annual membership at a lower price point than casual rides.
    
  *  Two-tiered annual plan, where members have the option to pay up front or in monthly installments, which may be more feasible to increase and retain membership.
    
  *  Offering a reduced fair program for youth, low-income users, and seniors.
    
  *   Providing family discounts bundles for household members.
    
  *   Partnering with the city's largest employers to offer employee corporate passes.
  

<b>3. Attractive Member's Benefits</b>
<p>Cyclistic can incentivize their annual membership by offering sign-up perks to casual riders who are interested in trasnferring to an annual membership. These could be in the form of tickets or discounts to local attractions, restaurants, and shops. Cyclistic can partner with brands and businesss in the vicinity of the 10 most frequented bike stations. Bundling admission passes with
a membership, as well as offering exclusive deals for members - like chances to win prizes at local restaurants, businesses, or entertainment venues - could be an attractive way to boost membership while partnering with and supporting local businesses. Recognizing that people shop by bike in the tourist and attraction sites

<b>4. Expansion & Accessibility</b>
<p>To promote a healthier lifestyle particularly in underserved areas,  Cyclistic should expand their network of bikes to locations such as popular gyms and community recreation centres. Below is a list of 10 of the 60? stations that had less than 10 bikes rentals in the past 12 months. Cyclistic should relocate these underused bike stations to more frequented areas, thereby driving more usage. Most importantly, Cyclistic can grow their number of annual riders by expanidng network and offering more accessible bike stations across the city. Opening new bike stations on university campuses to facilitate student commutes.
  
![underused_stations](https://github.com/user-attachments/assets/cc461526-1bef-49d1-9216-36f66113491d)
 
<h2> Final Thoughts</h2>

Collecting a wider spread of demographic data would help Cyclistic better understand their customer base, especially the casual riders that they aim to convert. In the future, Cyclistic could strive to collect a wider range of key demographic and occupational data that could inform future marketing strategies in different ways.

Ultimately, Cyclistic's continued success depends on their ability to stay aware of the needs of its evolving customer base. By considering the occupational and socioecononmic backgrounds of different segments of their ridership, Cyclistic can adapt their pay structure and expansion to serve the needs of their riders. These adjustments, along with recommendations outlined above will help Cyclistic boost conversion rates while continuing to provide affordable, convenient and sustainable mobility option. 
