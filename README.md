# Cyclistic Case Study 🚲 

<p>Carmen Chow</p> 
<p>September 2024</p>

<h2>Background</h2>
<p>Cyclistic is a successful bike-share company in Chicago. Since 2016, its program has grown to a fleet of 5,824 bicycles that are geotracked and locked into a network of 692 stations across Chicago. Customers who purchase single-ride or full-day passes are referred to as <b>casual riders</b> and those who purchase annual memberships are Cyclistic <b>members</b>. 
  
The director of marketing believes the company's future success depends on maximizing the number of annual memberships by converting casual riders into annual members. In order to do that, the team needs to better understand how casual riders and annual members use Cyclistic bikes differently by analyzing historical bike trip data to identify trends.

<h2>Stakeholders</h2>

*  Lily Moreno: The director of marketing and your manager. </p>

*  Cyclistic marketing analytics team: A team of data analysts who are responsible for
collecting, analyzing, and reporting data that helps guide Cyclistic marketing strategy.</p>

*  Cyclistic executive team: They will decide whether to approve the recommended marketing program.</p>

<h2>1. Ask</h2>
<h3><b>Business Task</b></h3>
Understand how annual members and casual riders use Cyclistic bikes differently in order to convert casual riders into annual members.

<h2>2. Prepare</h2>

<h3><b>Data Source</b></h3>
We will look at 12 months of Cyclistic's publicly available historical trip data (August 2023 - July 2024), which contains information such as bike type, station names and IDs, and their respective latitudes and longitudes. The anonymized data is made available by Motivate International Inc. We will use data from the City of Chicago's Data Portal, which provides a list of bicycle station IDs and station names.

<p>

<p>Cyclistic historical trip data: https://divvy-tripdata.s3.amazonaws.com/index.html
<p>Motivate International Inc. license: https://divvybikes.com/data-license-agreement.
<p>Chicago's Data Portal: https://data.cityofchicago.org/Transportation/Divvy-Bicycle-Stations/bbyy-e7gq/data   

<h3><b>Data Bias and Credibility. Does it ROCCC?</b></h3>
<p><b>R</b>eliable - Yes, the dataset is public and unbiased.
<p><b>O</b>riginal - Yes, the data is first-party data, collected by the company itself.
<p><b>C</b>omprehensive - Yes, there are over 5 million rows of historical trip data from the year 2020 to now. 
<p><b>C</b>urrent - Yes, the data is from the past 12 months.
<p><b>C</b>ited - Yes, the data is public, vetted, and available on the company's website.

<h3><b>Data Limitations</b></h3>

The dataset contains over 5.7 million records, with more than 1.5 million entries having NULL or negative values in the  `start_station_name`, `start_station_id`, `end_station_name`, and `end_station_id` columns. We'll use Google Big Query instead of Excel for data cleansing and analysis. The free-tier version of Big Query does not handle data deletion, so I will filter out the NULL and negative values. 

<p>Previewing the CSV files in Excel shows that the column names are identical across all fields, which means we will not be adding new columns. Instead we will be unioning the tables by adding them to them bottom of the previous table. 
  
We'll create a table and specifiy the column header names and their data types before using the Google Cloud CLI to upload the first CSV file to Big Query.
  
<p>

![schema](https://github.com/user-attachments/assets/507afc06-7550-4db5-8fde-80341e138b0f)

Instructions for installing and running the Google Cloud CLI are available here: https://cloud.google.com/sdk/docs/install-sdk . We'll use the following `bq` command to load the first file, <i>202308-divvy-tripdata.csv</i> to BigQuery: 

```bq load - replace - skip_leading_rows=1 general-432301:wip.tripdata_t.est"C:\Users\carmen\Desktop\12_months_csv\202308-divvy-tripdata.csv```

The remaining 11 CSV files will be loaded and unioned to the bottom of our new table with the `noreplace` command, which will create new rows instead of columns of data. Here's the complete command:

``` bq load - replace - skip_leading_rows=1 general-432301:wip.tripdata_t.est"C:\Users\carmen\Desktop\12_months_csv\202309-divvy-tripdata.csv" ```

We have now imported and merged all 12 datasets giving us 5,715,482 rows of data. Let's go ahead and process the data.

<h2>3. Process</h2>
<h3>Data Exploration</h3>

Before cleaning the data, it's beneficial to explore it and see what exactly we're working with. Looking at our table,  we can group our columns into three categories of qualitative data: data about stations, data about rides, and data related to start and end times. Here's the schema showing each field name and data type.

![schema1](https://github.com/user-attachments/assets/a0e1a99e-6277-4ee5-86cd-b50a9a7eb768)
![schema2](https://github.com/user-attachments/assets/8c034d55-782b-43bc-bffc-2095c9c6cac6)

Let's explore the relationships between some of our columns and see whether they are one-to-one or one-to-many relationships. We'll start with a bike station, which we would expect to have only one station name associated with it. In other words, `start_station_id` should have a one-to-one relationship with `start_station_name`. Let's see if that is the case. We'll run a query on `start_station_id` to check for instances where a `start_station_id` has multiple `start_station_names`. 

![start_station_id_2](https://github.com/user-attachments/assets/93d9394a-9996-46b3-b57d-92b700688292)

We see that there are, in fact, 83 records of `start_station_id`s linked to more than one `start_station_name`. 

![station_id_83](https://github.com/user-attachments/assets/b5c304d9-e934-4b06-9b19-12aff3ec8f10)

Let's examine the first result: the station with the ID `647`.

![station_id](https://github.com/user-attachments/assets/f1706f92-3d36-4174-b864-aef8458818ae)

This returns three different station names. To find the correct name, we'll refer to our second data source - the City of Chicago Data Portal's website (link provided above) - and look up station_id `647` in its database.

![647](https://github.com/user-attachments/assets/2d246d9c-5299-4d0c-88f2-43d4792cbadc)

It looks like <i>Racine Ave. & 57th</i> is the station's actual station name. Our lookup solved the problem of finding the correct station name, however with 83 records of `start_station_id`s having more than one name, we'll need to clean our data to ensure that each `station_id` has a unique and consistent name.

Let's examine the relationship between `start_station_id` and `start_lat`:

![start_lat2](https://github.com/user-attachments/assets/4adca5e0-98c6-4caf-bd9c-6abb83edb9c7)

Our query returns 1,588 records where a single `start_station_id` is associated with multiple `start_lat` values. 

![start_lat_results](https://github.com/user-attachments/assets/9a2e8f9b-4927-4812-b2eb-b5b5426bf159)

Let's filter on the first result: station <i>WL-012</i>:

![roundLat](https://github.com/user-attachments/assets/da82099b-8078-4ad9-ae38-52645c7ab0e2)

We see that the 7,232 different latitudes are the result of inconsistent number formatting. 

We now have an idea of the types of data cleansing and data transformation processes needed to prevent duplicates and one-to-many relationships that can lead to inaccuracies in our analysis. 


<h3>Data Cleansing</h3>

Through our data exploration, we discovered that the expected one-to-one relationship between `start_station_id` and other dimensions such as `start_station_name` and `start_lat` has not been enforced. Performing a lookup for each of the 83 station name, while possible, would not be practical or time-efficient. Instead, what we'll do is aggregate the rows into a single entry to create a one-to-one relationship between `start_station_id` and the station-related data.

To do this, we'll create a new table with `start_station_id` as the primary key, and we will bring in only station-related data. After cleaning this data, we will rejoin it with the original main table. 

<b>Why aggregate our data?</b>

<p>Aggregating will allow us to consolidate multiple rows of data into a single row. Common aggregation functions include SUM(), MIN(), MAX() and AVG(). Since SUM() and AVG() only work with numeric values, we will use MAX() instead to handle our  `start_station_id` and `start_station_name` string types. We will also perform the same aggregation on the `end_station` data, and we'll also format the latitude and longitude values by rounding them to 6 decimal places. Finally, we'll use `station_id` as the primary key to union the aggregated `start_station` and `end_station` data. 
  
Creating the new `station_data` table:

![station_data](https://github.com/user-attachments/assets/1fb42ae3-0d62-4e61-b3d0-9a2f101d84b1)

Now let's run the query we ran before that filtered on `station_id 647`. This time, we will execute it twice: once on our cleaned data and once on the original dataset to see the differences. On the left, we've returned the original results, while the right shows that we've cleaned up rows with multiple records. 

![cleaned_station](https://github.com/user-attachments/assets/e5285795-9ddd-4a2c-9e96-8e13823bc662)

<b>Ride data table</b>
<p>Let's create a separate table for our ride-related fields. We'll apply the same thinking and use MAX() to aggregate the ride-related fields from our main table. 

![ride_data](https://github.com/user-attachments/assets/ce608c9b-2fee-4f3b-8fa5-55d9c717596f)

We can now join the two cleaned tables together on the start and end station ids.

![finaljoin](https://github.com/user-attachments/assets/41ac54ed-394a-4f45-a0fe-bdf1f3f3947e)

<p>
We've also created new columns which will help us analzye other metrics such as the duration, speed and distance of each group's bike rides. These new column are:

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

The pie chart shows that <b>4,178,369</b> (or 4.18) unique rides were recorded from June 2023 to August 2024. Of these, rides by annual members made up 64.8% (or <b>2,708,729</b>) of the total number, and casual riders accounted for 35.2% or <b>1,469,640 rides</b>.

![ridemembers](https://github.com/user-attachments/assets/f7cb498b-5e06-45d2-8f72-b694ecddbd9e)

<b>Bike Preferences</b>

![member_bike](https://github.com/user-attachments/assets/aeaf044a-c0cd-44e5-b9a9-bae98d96c09d)

![casual_bike](https://github.com/user-attachments/assets/153a551e-ff0c-43fe-98a2-2f27759d9059)

Both casual and annual members prefer classic bikes over electric bikes. For casual riders, <b>65.73%</b> or 966,128 out of 1,469,640 rides were on classic bikes, while annual members used classic bikes for <b>68.50%</b> of their rides, which comes to 1,855,692 out of the 2,708,729 rides. Curiously, docked bikes were used only used by casual riders, and half of these docked bikes were used on rides lasting more than 24 hours or less than one minute. A followup with Cyclistic's team is needed to explain what a docked bike is and <i><b>why they are not being used by annual members</b></i>.

<h3><b> Daily Trends </b></h3>

We can see that the number of bike rides by annual members was fairly consistent from Monday to Friday, with a decrease on weekends and the highest number on Wednesday.  For casual riders, the ride count was highest on weekends.

![ride_day](https://github.com/user-attachments/assets/7350ed00-04a7-4482-94ec-4a0c79c907c3)

<b> Duration</b>
<p>
In addition to an uptick in the number of casual riders on weekends, casual riders tend to take <i><b>longer</b></i> rides. The average ride time from Monday to Friday was <b>22.18 minutes</b> while on weekends it increased to <b>27.75 minutes</b>. For member riders, ride times remained fairly consistent from Monday to Friday, averaging 12.19 minutes per ride. On weekends, there was only a slight increase, with an average ride time of 14.23 minutes. Over 12 months, casual riders logged 11,896.32 more hours than their member counterparts on Sundays, the day with the longest average ride time for both groups.

![ride_time (1)](https://github.com/user-attachments/assets/838d5c30-ed62-40e8-96c4-25eb51858f63)

<b> Distance</b>

We know that casual riders take longer rides on weekends, but are they are travelling greater distances? This line graph shows casual riders are indeed travelling longer distances on weekends compared to weekdays. Over the course of a year, casual riders increased their distance travelled from <b>1,150,194</b> on Fridays to <b>1,775,955 kilometres</b> on Sundays. In contrast, annual member's distance decreased from Thursday to Sunday before picking up again at the start of the work week on Monday.


![km by day](https://github.com/user-attachments/assets/04361783-4c23-4dbd-94b7-e7ee37301cdf)

Let's take a look both groups' activity over a 24-hour period:

![hourly_rides](https://github.com/user-attachments/assets/6c713975-6ccc-4401-b45d-c566ec18a0c6)

We see two peaks of high activity for annual members between 6-8am and 4-6pm, with the most active hours being 8am and 5pm. These peaks likely reflect when member are commuting to and from work. In contrast, the majority of casual bike rides take place between 8am and 7pm, showing a steady increase in activity from 8am to 5pm.

Do peak hours correspond with longer ride times for casual riders and annual members?

![ride_time_hour](https://github.com/user-attachments/assets/fca57136-c070-4896-a4e9-61230390db3d)

For annual members, there is no significant change in ride time throughout the day, including the peak hours of 8am and 5pm. This supports the idea that annual members are using Cyclistic bicycles for commuting. For casual members, the longest rides occur between 8am and 5pm, which supports the hypothesis that casual riders use bikes for recreational purposes, perhaps they have flexible work schedules, or they are tourists using the bikes to explore the city during the day. 


<b>Speed</b>

Let's see if the average ride speed confirms our hypothesis.   We'll calculate average speed of each ride by taking the distance and dividing it by the trip duration. 

![bike_type_speed](https://github.com/user-attachments/assets/8a23f2fa-0ea9-42d2-b5f7-8cf395c581f3)
![avg sped type](https://github.com/user-attachments/assets/8ca80245-9192-4fda-a33e-a370df955c61)

We'll compare the average speed of both groups on classic bikes, which are the favoured by both groups of riders. A casual rider's average speed on a classic bike is 8.17m/s compared to an annual member's average speed of 12.17 m/s on the same bike. Casual rides bike at more leisurely speeds which make sense if they are mainly using bikes for sightseeing and exploring.


<h3><b>Seasonal Trends</b></h3>

<p>Let's see if there are seasonal trends in bike usage across different months.

![monthly_rides](https://github.com/user-attachments/assets/bd62f6c4-ab37-4ff6-bde8-8cd15651444e)
  
  the number of casual rides begins to increase in the Spring and continues into the Summer months. From April to May, the number of rides increased by an impressive <b>79.4%</b>, rising from <b>92,111 to 164,316</b> rides, whereas the ride count for annual members only increased by <b>34.8%</b> from 200,293 to 270,000 during the same period. From October to November, casual members saw a <b>44% </b> decrease from <b>128,289 to 71,053</b>. Conversely, annual members had a smaller <b>25.9%</b> decrease with the number of rides dropping from 268,598 to 199,086. 



<b>Distance</b>

![distance_month](https://github.com/user-attachments/assets/fd17fe7e-87a9-4037-8cd3-95e318dac040)


<b><i>Location</i></b>

I used the Chicago Data Portal website to map the start stations most frequented by both groups of riders: 

For casual riders, the most popular bike station was Streeter Dr. & Grand Ave with  DuSable Lake Shore & Monroe St.

![top_10_casual_station](https://github.com/user-attachments/assets/c69c372f-defd-430f-a006-aa245601bb7e)

And the locations of these stations are near attractions like the planetarium and aquarium. 

![casual_station_map](https://github.com/user-attachments/assets/e105abd6-eb7c-47f9-9e2f-ff51efd91a50)

Annual members' top stations was Clinton St & Washington Blvd, Kingsbury St & Kinzie.

![top_10_members_station](https://github.com/user-attachments/assets/530efb66-a505-4e70-84f3-344b4a23edf9)

The locations are more ... Near North Side
![member_station_map](https://github.com/user-attachments/assets/510c9e6a-110f-402f-a133-8344fcd3a27a)


<h2>5. Share</h2>

We can now summarize our findings:

<b>Casual Rider</b>
* Most active time:
* Busiest day of the week: Saturday and Sundays
* Busiest months: July and August
* Preferred start stations: near tourist attractions
* Average ride time on weekdays: 22.16 minutes
* Average ride time on weekend: 27.8 minutes
* Average distance: 5.93 kilometres
* Average speed on a classic bike: 8.17m/s

<b>Member Riders</b>
* Most active time:
* Busiest day of the week: Monday to Thursday (check) 6-8am and 4-6pm
* Busiest months: July and August
* Preferred start stations away fro tourist attractions spread across - 
* Average ride time on weekdays: 12.22 minutes
* Average ride time on weekend: 14.2 minutes 
* Average distance: 5.39 kilometres
* Average speed on a classic bike: 12.17m/s

Based on our findings, it seems like would appear that annual members use Cyclistic's bikes for commuting, and casual riders for leisure. 

Tableau 
Google Slides

<h2>6. Act</h2>

Based on these conclusion I'll meka the following recommndatsion to Moreno and the marketing team.

<i>Suggestion #1:</i>
<p><b>Seasonality/Short-term options</b>   
To prepare for an uptick in casual rides in Spring and Summer, Cyclistic should prepare and plan their marketing campaign in March/April. Their ads should focus on the cost-saving and health benefits of upgrading to an annual membership in time with the summer months. Since casual riders are the most active during the summer months, launch campaigns ahead of the summer months that and introduce a monthly pass


<i>Suggestion #2</i>
<p><b>Pricing Structure</b></p>
Cyclistic can consider implementing a new pricing structure to increase enrollment in their annual membership. This could include a tiered membership, such as a monthly membership at a fixed price that could assist in eventually transferring riders to full members. To further incentive the annual memberhips, Cyclistic could introduce a cost to casual riders by either increasing the rental fee after a certain distance quota is reached. Another idea could be to offer a two-tiered annual plan where members have the option to pay up front or month to month in installments may be more feasibale to increase and retain enrollment.

<i>Suggestion #3 </i>
<p><b>Membership Perks</b></p>
Cyclistic can incentivize their annual membership by offering sign-up perks to existing casual riders such as ticket / discounts to local attractions, restaurants, shops. They can partner with brands and businesss within the vicinity of the 10 most frequented bike stations. These happen to be near tourist and sightseeing attractions, so bundling admissions passes with a membership. Exclusive deals for members, perhaps a chance to win prizes at local restaurants, businesses. entertainment venues.

<b>Suggestion #4: </b>
Emphasize Cyclistic's role in contributing to a healthier lifestyle by expanding their network of bikes to locations such as gyms, fitness centres or community centres. Cyclistic should also relocate stations from leas popular areas, for example to areas that see more traffic and could benefit from more presence.

![underused_stations](https://github.com/user-attachments/assets/cc461526-1bef-49d1-9216-36f66113491d)
 
<h2> Final Thoughts</h2>

Since the dataset only contained anonymized information, we don't have a complete picture of casual riders ... Examples of how Cyclistics could use this additional ifnormation: 
  
  * Youth/low-income: Offering a subsized program
  * Family members: Offering family discounts bundles
  * University students: Opening new bike stations on university campuses for to provide greater access for students 
  * Workers: Partnering with the city's largest employers to offer discounted member passes to employees

Based on the ride patterns and seasonal trends, by following these recommendations will help Cyclistic boost their conversion rate while continuing to provide an affordable, sustainable service that their riders can enjoy. 
