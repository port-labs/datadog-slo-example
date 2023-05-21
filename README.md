# Ingesting Datadog Service Dependencies


## Getting started

In this example you will create a blueprint for `service` entity that ingests all services and their dependencies in your Datadog APM. 


### Gitlab CI yaml
Place this example `.gitlab-ci.yml` file in your project's root folder

### Gitlab CI Variables
To interact with Port using Gitlab CI Pipeline, you will first need to define your Port credentials [as variables for your pipeline](https://docs.gitlab.com/ee/ci/variables/index.html#define-a-cicd-variable-in-the-ui). Then, pass the defined variables to your ci pipeline script. Ensure to add your Datadog API key, Application key and Evnironment as well to the variables.

The list of the required variables to run this pipeline are
- `PORT_CLIENT_ID`
- `PORT_CLIENT_SECRET`
- `DATADOG_API_KEY`
- `DATADOG_APPLICATION_KEY`
- `DATADOG_ENVIRONMENT`
- `DATADOG_API_URL`

### Schedule the script
1. Go to your Gitlab project and select CI/CD
2. Click on **Schedules** and create new schedule
3. Enter the necessary information into the form: the Description, Interval Pattern, Timezone, Target branch and other variables specifically for the schedule.
4. Click on **Save pipeline schedule** 

#### Screenshot - Schedule
![screenshot image](./assets/schedule.PNG "Oncall Schedule Trigger in Gitlab")

#### Screenshot - Pipeline Success
![screenshot image](./assets/pipeline.PNG "Successful Gitlab Pipeline Scheduled")
