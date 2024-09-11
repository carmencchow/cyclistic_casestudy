# Cyclistic Case Study 🚲
<p>Carmen Chow</p> 
<p>September 2024</p>
Medium: https://medium.com/p/2a1755a8b4e7/edit

<h2>Background</h2>
<p>Cyclistic is a bike-share company in Chicago. In 2016, Cyclistic launched a successful bike-share offering. Since then, the program has grown to a fleet of 5,824 bicycles that are geotracked and locked into a network of 692 stations across Chicago. Customers who purchase single-ride or full-day passes are referred to as <b>casual riders</b>. Customers who purchase annual memberships are Cyclistic <b>members</b>. 
  
The director of marketing believes the company's future success depends on maximizing the number of annual memberships. Therefore, your team wants to understand how casual riders and annual members use Cyclistic bikes differently. Moreno has set a clear goal: Design marketing strategies aimed at converting casual riders into annual members. In order to do that, however, the team needs to better understand how annual members and casual riders differ, why casual riders would buy a membership, and how digital media could affect their marketing tactics. Moreno and her team are interested in analyzing the Cyclistic historical bike trip data to identify trends.

<h2>Stakeholders</h2>
<p>*  Lily Moreno: The director of marketing and your manager. </p>
<p>*  Cyclistic marketing analytics team: A team of data analysts who are responsible for
collecting, analyzing, and reporting data that helps guide Cyclistic marketing strategy.</p>
<p>*  Cyclistic executive team: They will decide whether to approve the recommended marketing program.</p>

<h2>1. Ask</h2>
<h3><b>Business Task</b></h3>
<b>Learn how annual members and casual riders use Cyclistic bikes differently to convert riders into annual members .</b>

<h2>2. Prepare</h2>

<h3><b>Data Source</b></h3>
I'll be focusing on the last 12 months (August 2023 - July 2024) of Cyclistic's publically available historical data: https://divvy-tripdata.s3.amazonaws.com/index.html  The data is structured in wide formats in records and fields with ride-related information about the rider (casual or member), bike (classic, electric or docked), and the start and end station information (station id, station name, latitude and longitude coordinates). The data is made available by Motivate International Inc. under this license - https://divvybikes.com/data-license-agreement . It is accessible to the public and it does not include any personal identifiable information (PII). 

<h3><b>Data Bias and Credibility. Does it ROCCC?</b></h3>
<p>Reliable - the dataset is public and unbiased
<p>Original -data is considered first-party data because as it was collected by the company itself
<p>Comprehensive - there's millions of rows or records of monthly data beginning in the year 2020 to the current month
<p>Current - the data is up to date and includes the current month
<p>Cited - the data is public, vetted, and available on the company's website, found here.

<h3><b>Data Limitations</b></h3>
There are a number of NULL values related to some start and end station records. These will need to be cleaned. Despite the errors, because the data ROCCCs, the data will be enough for data analyse and uncovering trends and insights that will enable me to answer the business question.

<h2>2. Prepare</h2>

```gcloud auth login```
```gcloud config set project your-project-id```

```bq load - replace - skip_leading_rows=1 general-432301:wip.tripdata_t.est "C:\Users\carmen\Desktop\12_months_csv\202308-divvy-tripdata.csv```

After the first file is uploaded to BigQuery, we will replace the replace command with `noreplace` in order to append or UNION the next 2023–09 (and all subsequent files)to the existing table to aggregate the next 11 data files (2023–09 to 2024–07) into one giant table. Essentially we are add new tables to the bottom of the first table instead of using a JOIN which creates columns side by side. The complete command looks like this:

``` bq load - replace - skip_leading_rows=1 general-432301:wip.tripdata_t.est "C:\Users\carmen\Desktop\12_months_csv\202309-divvy-tripdata.csv" ```





![schema](https://github.com/user-attachments/assets/806f756c-55b1-4160-8d0d-425fdd4bc78b)


![storage](https://github.com/user-attachments/assets/033f3527-bca0-4ed5-b3fc-0ac0f1cc5852)

![avg_spee](https://github.com/user-attachments/assets/479beb74-ad8d-4667-8bc4-3aeb8525e5e9)
