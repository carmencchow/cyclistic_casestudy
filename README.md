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

Let's see if this is the case:

![start_station_id_count](https://github.com/user-attachments/assets/08d14de9-67ba-451e-8958-69005b6f85ac)

```
SELECT  
  start_station_id,
  COUNT(DISTINCT start_station_name) as start_station_name_count
FROM `general-432301.wip.tripdata_test` 
GROUP BY
  start_station_id
ORDER BY 
  start_station_name_count DESC
```
![count_start_station_id](https://github.com/user-attachments/assets/4495390a-37cd-438a-8a23-36842a4a04ef)


![station_id](https://github.com/user-attachments/assets/e57ad941-90ad-437e-858c-aec4eddc6c8c)

<h2>4. Analyze</h2>
<h2>5. Share</h2>
<h2>6. Act</h2>


![avg_spee](https://github.com/user-attachments/assets/479beb74-ad8d-4667-8bc4-3aeb8525e5e9)
