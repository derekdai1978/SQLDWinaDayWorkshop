# SQLDWinaDayWorkshop
Repository for DW in a Day workshop

Montreal: September 16, 2019 | 9AM - 5PM (EST)
Ottawa: September 18, 2019 | 9AM - 5PM (EST)


# Intro-Databricks-Workshop

The content contained in this repository suppors the Introduction to Databicks workshop.  Content for students used in the Intro to Databricks workshop

## Agenda:

| Time | Topic | Description | Materials |
| --- | --- | --- | --- |
| 09:00am - 09:15am |  Brief Intros of the team (15min) | Welcome | N/A |
| 09:15am - 10:00am |  Datawarehouse Patterns in Azure & SQL DW Overview (45min) | Slide Deck 01 | N/A |
| 10:00am - 10:45am |  SQL DW Gen2 New Features & Functionality (45min) | Slide Deck 02 | N/A |
|10:45am - 11:00pm   | Break (15min)  | Please take a break | N/A |
| 11:00am -12:00pm |  Demo & Lab 01  (60 Min) | Setting up the LAB environment | Lab 01 |
| 12:00pm -1:00pm |  Lunch  (60 Min) | Lunch and complete lab 01 | N/A |
| 01:00pm -1:30pm |  SQLDW Loading Best Practices (30 Min) | Lecture | N/A |
| 01:30pm -02:15pm |  Lab 02/03: User IDs & Data loading scenarios and best practices (45min) |  Loading different scenarios | Lab 02/03 |
| 02:15am - 2:30pm   | Break (15min)  | Please take a break | N/A |
| 02:30pm -3:00pm |  SQLDW Operational Best Practices (30 Min) | Lecture | N/A |
| 03:00pm -03:45pm | Lab 04: Performance Tuning best practices (45min) |   | Lab 04 |
| 03:45pm -4:15pm |  Lab 05: Lab 3: Monitoring, Maintenance and Security (30min) |   | Lab 05 |
| 4:15pm -5:00pm |  Q&A and Wrap-up (45min)  | final remarks or takeaways/next steps  | Survey |   

Steve's GitHub Source https://github.com/steveyoungca/SQLDWinaDayWorkshop


## Apache Spark on Databricks

<<< Need to update with the objectives of the class>>>

In this session we are going to reviwe the following items:

* Getting started on Databricks (Create a notebook and a Spark cluster)
* Importing data, Exploratory analysis and Visualizing data
  * Creating Data frames
  * Using built-in Spark functions to aggregate data in various ways
  * Querying Data Lakes with Data Frames

<<<<Update with the datasets we are using and their souce >>>>

The dataset we are using for the initial demo is from Kaggle and is the [Chicago Transit Authority CTA Data#cta-ridership-bus-routes-daily-totals-by-route.csv](https://www.kaggle.com/chicago/chicago-transit-authority-cta-data#cta-ridership-bus-routes-daily-totals-by-route.csv)

The following Databricks workbooks are used during the session.
[04-Read and Write Data Using Azure Databricks](https://github.com/MicrosoftDocs/mslearn-read-and-write-data-using-azure-databricks/blob/master/DBC/04-Reading-Writing-Data.dbc?raw=true) 

### Intro

The following steps are located in the [Lab Manual](https://github.com/steveyoungca/Intro-Databricks-Workshop/blob/master/Labs%20Files/Steve%20Young%20-%20Walk%20Through%20Labs.docx).

So, before we get into it, we can import a file.  There are a couple of ways to do this, first, we can create a table in the DataBricks cluster by importing the file, **cta-ridership-bus-routes-daily-totals-by-route.csv**  provided in the **Data Files** directory.


Once the table is created , follow along with the Juypter notebook.  **Add in Link**

*ADB = Azure Databricks



## References and Other Resources

PLEASE NOTE: I am not the owner/creator of any of the notebooks in this repo. Please see below for a list of the source repos containing the notebooks:



