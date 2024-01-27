
# Using Bigquery ML for Advertising
This project provides a Terraform deployment to create a new Google Cloud project that hosts a copy of the `thelook_ecommerce` dataset and applies different [Bigquery Machine Learning](https://cloud.google.com/bigquery/docs/bqml-introduction) technics for advertising purposes.

Disclaimer : This is not supported code by Google and is provided as is, without warranties of any kind.

This terraform deployment uses the `thelook_ecommerce` dataset to do the following :
- Generate a product description based on the product Brand, Name and Category using GenAI
- Create segments on sales per brand, product categories and location
- Predict sales for the top trending products
- Recommend products based on the previous purchases and most sold products

## Architecture Design

We will be choosing our training models as per the recommended [Selection guide](https://cloud.google.com/bigquery/docs/bqml-introduction#model_selection_guide) proposed by Google Cloud
![diagram](https://cloud.google.com/static/bigquery/images/ml-model-cheatsheet.svg)


## Components
This project mainly relies on Google Cloud [BigQuery](https://cloud.google.com/bigquery/docs/introduction). It uses a copy of `bigquery-public-data.thelook_ecommerce` locally in the newly created project to host views and models.

We also use Vertex AI for Generative AI and use the `text-bison` model as an LLM to generate article descriptions.

## Setup

### Prerequisites
You will need to have a working installation of [terraform](https://developer.hashicorp.com/terraform/install). The working version at the time writing this deployment is [Version 1.6.6](https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip). Upon initialization, the latest Terraform Google Cloud Provider will be downloaded (currently v5.11.0).

Since not all is implemented in the Google Cloud Terraform Provider or through the API, you will need to install the following tools to use this deployment :
- [gcloud](https://cloud.google.com/sdk/docs/install) official Google Cloud cli
- `bq` included with the gcloud installer

You will also need to have a power user with sufficient rights to create projects, administrate BigQuery and Vertex AI.

### Dependencies
This deployment uses modules from the [Cloud Foundation Fabric](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric) provided by Google Cloud. Hence the easiest way to install is to put the content of this repo in a folder that is in the root of you cloud foundation fabric folder to access the modules.

### Set variables
All the variables that need to be set are instructed in the `terraform.tfvars` file.

### Running the deployment
Once you are in the folder of this repo you can issue the `terraform init` command such as :
```
user@penguin:~/bigquery-datacleanroom-main$ terraform init 
```
Then do a `terraform plan` to verify all dependencies and environment variables have been met :
```
user@penguin:~/bigquery-datacleanroom-main$ terraform plan 
```
You can then launch the actual deployment using the `terraform apply` command
```
user@penguin:~/bigquery-datacleanroom-main$ terraform apply -auto-approve 
```

# Using the models

## Generative AI
Once deployed, you should have in your Bigquery Studio environment a view in `thelook` dataset (depending on the name you gave in your variables) called `_genai_product_description`.

You can then execute a SQL query against this view such as :
```sql
SELECT
  *
FROM
  `thelook._genai_product_description`
```
This will display a table in the Query Results section with a column named `ml_generate_text_llm_result` with the description generated by the LLM, based ont the product's Brand, Category and Name.
You can also observe that this section has deployed an external connection to VertexAI as well as a Model called `bison_model` in your dataset.

## Segmentation
You should have a in the Models section of your dataset a model called `sales_segments`. When Navigating in the model's Evaluation section you should see your features with the Country, Brand and Category such as :
![country](./assets/country.png)![category](./assets/category.png)
.

## Product recommendation

# Troubleshooting & know issues
You will probably notice a failure upon initial deployment with setting IAM permissions for the public dataset to be copied to your project. This is because the IAM API from Google Cloud is async and "eventually consistent". The best way to fix this is to wait a couple minutes and launch the `terraform apply` command again. You can also view the logs of the [transfer page](https://console.cloud.google.com/bigquery/transfers) in the Run History tab. Once the transfer is finished, you should run the `terraform apply` command again in order for the deployment to continue.

When running `terraform destroy` you will notice that the datasets in BigQuery prevent you from cleaning the projects. You can delete the datasets from the cloud console and launch the `terraform destroy` command again.