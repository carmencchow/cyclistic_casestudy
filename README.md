# Cyclistic Case Study 🚲 

<p>Carmen Chow</p> 
<p>August 2024</p>

<h2>Background</h2>
<p>Cyclistic is a successful bike-share company in Chicago. Since 2016, its program has grown to a fleet of 5,824 bicycles that are geotracked and locked into a network of 692 stations across Chicago. Customers who purchase single-ride or full-day passes are referred to as <b>casual riders</b> and those who purchase annual memberships are Cyclistic <b>members</b>. 
  
The director of marketing believes the company's future success depends on maximizing the number of annual memberships by converting casual riders into annual members. In order to do that, the team needs to better understand how casual riders and annual members use Cyclistic bikes differently by analyzing historical bike trip data to identify trends.

<h2>Stakeholders</h2>
<p>*  Lily Moreno: The director of marketing and your manager. </p>
<p>*  Cyclistic marketing analytics team: A team of data analysts who are responsible for
collecting, analyzing, and reporting data that helps guide Cyclistic marketing strategy.</p>
<p>*  Cyclistic executive team: They will decide whether to approve the recommended marketing program.</p>

<h2>1. Ask</h2>
<h3><b>Business Task</b></h3>
Understand how annual members and casual riders use Cyclistic bikes differently in order to convert casual riders into annual members.

<h2>2. Prepare</h2>

<h3><b>Data Source</b></h3>
We will look at 12 months of Cyclistic's publicly available historical trip data (August 2023 - July 2024), which contains information such as bike type, station names and IDs, and their respective latitudes and longitudes. The anonymized data is made available by Motivate International Inc. Additionally, we will use data from the City of Chicago's Data Portal, which provides a list of bicycle station IDs and station names.

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
The dataset contains over 5.7 million records, with more than 1.5 million entries having NULL or negative values in the `start_station_name`, `start_station_id`, `end_station_name`, and `end_station_id` columns. The free-tier version of Google Big Query does not allow data deletion, so I will be filtering out these values to avoid drawing any inaccurate conclusions from the data. Since the data still meets ROCCC standards, the filtered data will be enough for completing the Business Task. 

<p>Previewing the CSV files in Excel shows that the column names are identical across all fields, which means we will be unioning the tables instead of joining them. We'll be using Google Big Query for data cleansing and analysis due to its ability to handle larger volumes of data.  First, I'll create a table and enter the column header names and their data types before using the Google Cloud CLI to upload the first CSV file to Big Query.
  
<p>

![schema](https://github.com/user-attachments/assets/507afc06-7550-4db5-8fde-80341e138b0f)

Instructions for installing and running the Google Cloud CLI are available here: https://cloud.google.com/sdk/docs/install-sdk . We'll use the following `bq` command to load the first file, <i>202308-divvy-tripdata.csv</i> to BigQuery: 

```bq load - replace - skip_leading_rows=1 general-432301:wip.tripdata_t.est"C:\Users\carmen\Desktop\12_months_csv\202308-divvy-tripdata.csv```

The remaining 11 CSV files will be loaded and unioned to the bottom of our new table with the `noreplace` command, which will create new rows instead of columns of data. Here's the complete command:

``` bq load - replace - skip_leading_rows=1 general-432301:wip.tripdata_t.est"C:\Users\carmen\Desktop\12_months_csv\202309-divvy-tripdata.csv" ```

We have now imported and merged all 12 datasets giving us <i>5,715,482</i> rows of data. Let's go ahead and process the data.

<h2>3. Process</h2>
<h3>Data Exploration</h3>

Before cleaning the data, it's beneficial to explore the data and see what exactly we're working with. Looking at our data, we can group our columns into three categories of qualitative or descriptive data: data about station information, data about ride information, and data related to start and end times. Here's an overview of our columns:

![schema1](https://github.com/user-attachments/assets/a0e1a99e-6277-4ee5-86cd-b50a9a7eb768)
![schema2](https://github.com/user-attachments/assets/8c034d55-782b-43bc-bffc-2095c9c6cac6)

Let's explore the relationships between some of our columns and see if they are one-to-one or one-to-many relationships. For example, it would be reasonable to expect a bike station to have only one station name associated with it, in other words `start_station_id` should have a one-to-one relationship with `start_station_name`. Let's see if that is the case. We'll run a query on `start_station_id` to see if there are instances when a `start_station_id` has more than one `start_station_name` associated with it. 

![start_station_id_2](https://github.com/user-attachments/assets/93d9394a-9996-46b3-b57d-92b700688292)

We see there are, in fact, 83 records of `start_station_id`s with more than one `start_station_name`. 

![station_id_83](https://github.com/user-attachments/assets/b5c304d9-e934-4b06-9b19-12aff3ec8f10)

Let's examine the first result, the station with the id `647`:

![station_id](https://github.com/user-attachments/assets/f1706f92-3d36-4174-b864-aef8458818ae)

This returns three different station names. In order to find the correct name, we'll turn to our second data source, the city of Chicago Data Portal's website (link provided above) and look up station id 647 in its database:

![647](https://github.com/user-attachments/assets/2d246d9c-5299-4d0c-88f2-43d4792cbadc)

It looks like Racine Ave. & 57th is the station's actual station name. Our lookup solved the problem of finding the correct station name, however with 83 records of `start_station_id`s having more than one name, we'll need to clean our data to ensure a more effective way of ensuring a single name for each station_id.

Out of curiosity, let's see if there is are any one-to-many relationships between `start_station_id` and `start_lat` (latitude):

![start_lat2](https://github.com/user-attachments/assets/4adca5e0-98c6-4caf-bd9c-6abb83edb9c7)

Our query returns 1588 records, with the first row showing station WL-012 with 7,232 different latitudes. 

![start_lat_results](https://github.com/user-attachments/assets/9a2e8f9b-4927-4812-b2eb-b5b5426bf159)

Let's filter on the first restuls, WL-012:

![roundLat](https://github.com/user-attachments/assets/da82099b-8078-4ad9-ae38-52645c7ab0e2)

We see that the 7,232 different latitudes are a results of inconsistent decimal formatting. 

Our short exploration of the data gives us an idea of the types of data cleansing and data transformation processes we will need to ensure that we don't have one-to-many relationships that cause duplicates and inaccurate analysis. 


<h3>Data Cleansing</h3>

We've discovered that the expected 1:1 relationship between station_id and other qualitative data such as it's name and latitude is not enforced, and performing a lookup for the correct name, although possible, would not be practical or time efficient. To handle the variance of multiple records, we can aggregate the rows and reduce it into a single row to enforce that 1:1 relationship.

To do this, we'll create a new table with `start_station_id` as the primary key and we will bring in only station-related data. After processing this data, we will rejoin the cleaned data with the origin main table. 

<i>Why aggregate our data?</i>
Aggregating will allow us to consolidate multiple rows of data into one and enforce that one-to-one relationship that makes our records unique. Common aggregation functions are `SUM(), MIN(), MAX()` and `AVG()`, however `SUM()` and `AVG()` only work with numeric values, we will aggregate data for each `start_station_id` string type using the `MAX()` function. We'll apply the same function to all other station-related fields:

We will do the same for `end_station` information before combining the results of the . We'll also format the lat and lng values by rounding them to 6 decimal places. We'll treat both `start_station_id` and `end_station_id` as `station_id` which will be the primary key used to join the results of the inner queries.

Create station_data table by unioning our aggregated start and end_station data:

![station_data](https://github.com/user-attachments/assets/1fb42ae3-0d62-4e61-b3d0-9a2f101d84b1)

Now let's run the earlier query that filtered on station_id '647' again. However, this time we will run it twice: once on our cleaned data and the other on our original dataset  to see the difference. On the left, we've returned the original results, while the right we've cleaned up rows with multiple records. 

![cleaned_station](https://github.com/user-attachments/assets/e5285795-9ddd-4a2c-9e96-8e13823bc662)

<b>Ride data table</b>
<p>Now, let's create a separate table for our ride-related fields, we'll apply the same thinking and use MAX() to aggregate the ride-related fields from our main table. 

![ride_data](https://github.com/user-attachments/assets/ce608c9b-2fee-4f3b-8fa5-55d9c717596f)

With both table removed of duplicates and ensuring uniqueness, we can rejoin them both. 

![finaljoin](https://github.com/user-attachments/assets/41ac54ed-394a-4f45-a0fe-bdf1f3f3947e)

<p>We've also created new columns which will help us gain deeper insights into the duration, speed and distance of each group's bike rides, as well as hours and days of most and active rides. These new columsn will be `start_dayofweek`, `start_month`, `start_hour`, `trip_duratio`, and `distance_in_meters` that will help us in our analysis.

![final](https://github.com/user-attachments/assets/6c2fcd2c-816f-48e3-89e6-418f2898b43a)

<h2>4. Analyze</h2>

After connecting a new Tableau workbook to our Google Big Query server, we can start to 
visualize the relationship between different dimensions. Let's return to the origin question:

<b><i>How do annual members and casual riders use Cyclistic bikes differently?</i></b>

<b> Ride Count: Casual Riders vs. Annual Members</b>

![ridemembers](https://github.com/user-attachments/assets/f7cb498b-5e06-45d2-8f72-b694ecddbd9e)

<b>4,178,369 rides</b> were recorded from June 2023 to August 2024. Out of that number, rides by annual members made up 64.8% (or <b>2,708,729</b>) and casual riders accounted for 35.2% or <b>1,469,640 rides</b>.


<b>Bike Preferences</b>

Both casual and annual members prefer the classic bikes over the electric bikes. For casual riders 966,128 out of 1,469,640 rides were on classic bikes (65.73%) and for annual members, 68.50% or 1,855,692 out of the 2,708,729 rides. Regarding docked bikes, not only were they only used by casual customers, but several of them logged multiday trips, had missing end station ids and names. Thi..

<b> Daily Trends </b>

We can see that the number of annual member bike rides was fairly consistent from Monday to Friday, with a decrease on the weekends and the highest number on Wednesday.  For casual riders, they took the most number of rides on the weekend.

![ride_day](https://github.com/user-attachments/assets/7350ed00-04a7-4482-94ec-4a0c79c907c3)

<i>---need chart for 'Average Ride Time by Day' ---</i>






We can see that casual riders also take longer rides on weekends compared to member riders. In fact casual riders logged 11,896.32 hours more on Sunday than their member counterparts.

<i> Distance by Day </i>
![km by day](https://github.com/user-attachments/assets/04361783-4c23-4dbd-94b7-e7ee37301cdf)

This chart shows that casual riders take longer rides on the weekend, covering 1,775,955 kilometres on Sundays, where as member rider's kilometres start decreasing from Thursday to Sunday before pickup again on from Monday to Thursday. 

Let's take a look at the ride activity over a 24 hour period.

![hourly_rides](https://github.com/user-attachments/assets/6c713975-6ccc-4401-b45d-c566ec18a0c6)

The chart above shows two peaks of high activity for annual members: between 6-8am and 4-6pm, with the most active hour being 8am and 5pm, which could indicate when members are heading to and from work. On the other hand, the majority of casual bike rides take place between 8am and 7pm, beginning with a steady increase from 8am to 5pm.

![monthly_rides](https://github.com/user-attachments/assets/bd62f6c4-ab37-4ff6-bde8-8cd15651444e)

Looking at the monthly ride patterns, the number of casual rides begin to increase in Spring and continues into the Summer months. From April to May, the number of rides increase by a whopping <b>79.4%</b> from <b>92,111 to 164,316</b>, whereas the ride count for annual members only increase by <b>34.8%</b> from 200,293 to 270,000 for the same period. Casual members - October to November a <b>44.6%</b> decrease from 128,289 to 71,053. whereas for annual members 268,598 to 199,086 it's only a 25.9% decrease. 

<b><i>Distance</i></b>

![distance_month](https://github.com/user-attachments/assets/fd17fe7e-87a9-4037-8cd3-95e318dac040)

<b><i>Ride Time</i></b>

![avg ride time hour](https://github.com/user-attachments/assets/e3cd72eb-351f-42c4-a1ba-c26552cd6cfe)

<b><i>Speed</i></b>

We'll calculate average speed of each ride by taking the distance and dividing it by the trip duration. 
![bike_type_speed](https://github.com/user-attachments/assets/8a23f2fa-0ea9-42d2-b5f7-8cf395c581f3)
![avg sped type](https://github.com/user-attachments/assets/8ca80245-9192-4fda-a33e-a370df955c61)

A casual rider's average speed on a classic bike is 8.17m/s and 9.75m/s on an electric bike. These speeds are slower than member rider's whose average speed on a classic bike was 12.17 m/s and 12.21 on an electric bike. 

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
