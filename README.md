# SQLDWinaDayWorkshop
Repository for DW in a Day workshop

# Intro-Databricks-Workshop

The content contained in this repository suppors the Introduction to Databicks workshop.  Content for students used in the Intro to Databricks workshop

## Agenda:

| Time | Topic | Description | Materials |
| --- | --- | --- | --- |
| 10:00am -10:15am |  Brief Intros to the team and getting settled in (15min) | Get settled in | N/A |
| 10:00am -10:15am |  Brief Intros to the team and getting settled in (15min) | Get settled in | N/A |
| 10:00am -10:15am |  Brief Intros to the team and getting settled in (15min) | Get settled in | N/A |
| 10:00am -10:15am |  Brief Intros to the team and getting settled in (15min) | Get settled in | N/A |
| 10:00am -10:15am |  Brief Intros to the team and getting settled in (15min) | Get settled in | N/A |
| 10:00am -10:15am |  Brief Intros to the team and getting settled in (15min) | Get settled in | N/A |
| 10:15am - 10:45am | Overview of options for Machine Learning on Azure (30min) |   | Slides/Hand-On Lab Docs |
| 10:45am - 11:30am  | Apache Spark on Databricks (45min) |   |   |
|11:30am - 11:45pm   | Break (15min)  | Please take a break | N/A |
| 11:45am - 12:30pm |   Train a Machine Learning Pipeline, model training and interpretation (45min)  | This is a complex topic with many moving parts. Follow along type of Demo/Labs | Hand-On Labs, Azure Databricks cluster |
| 12:30pm -12:45pm | End-to-End Walkthrough: Detecting Financial Fraud at Scale with Decision Trees and ML flow on Databricks (15min) |   | N/A|
| 12:45pm - 01:00pm | Close out and final remarks or takeaways/next steps (15min) |  |   |

Steve's GitHub Source https://github.com/steveyoungca/Intro-Databricks-Workshop


## Apache Spark on Databricks

In this session we are going to reviwe the following items:

* Getting started on Databricks (Create a notebook and a Spark cluster)
* Importing data, Exploratory analysis and Visualizing data
  * Creating Data frames
  * Using built-in Spark functions to aggregate data in various ways
  * Querying Data Lakes with Data Frames

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

Read and Write Data Using Azure Databricks - https://github.com/MicrosoftDocs/mslearn-read-and-write-data-using-azure-databricks 

Train and deploy machine learning models - https://docs.microsoft.com/en-gb/azure/devops/pipelines/targets/azure-machine-learning?view=azure-devops 


Azure Machine Learning service example notebooks - https://github.com/Azure/MachineLearningNotebooks/

Azure Machine Learning Pipeline - https://github.com/Azure/MachineLearningNotebooks/tree/master/how-to-use-azureml/machine-learning-pipelines 


