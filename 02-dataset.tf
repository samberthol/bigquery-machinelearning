# Samuel Berthollier - 2024
#
# Unless required by applicable law or agreed to in writing, software
# distributed is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Creating a BigQuery dataset to host the sample data set "thelook_ecommerce"
module "thelook-dataset" {
  source         = "../modules/bigquery-dataset"
  project_id     = module.land-project.project_id
  id             = var.thelook_dataset
  location       = var.location
}

# Setting up the transfer of the sample data set "thelook_ecommerce" from the public project "bigquery-public-data" to the Landing project
# Verify if transfer is working in https://console.cloud.google.com/bigquery/transfers
resource "google_bigquery_data_transfer_config" "thelook-transfer" {
  depends_on = [module.land-project, module.land-sa-0, module.thelook-dataset]
  project = module.land-project.project_id
  display_name           = "thelook-transfer"
  location               = var.location
  schedule               = "every day 01:00"
  data_source_id         = "cross_region_copy"
  destination_dataset_id = module.thelook-dataset.dataset_id
  service_account_name   = module.land-sa-0.email
  params = {
    source_dataset_id       = "thelook_ecommerce"
    source_project_id       = "bigquery-public-data"
  }
}

# Creating a simple view on the dataset
resource "null_resource" "dataset-view" {
  triggers = {
   always_run = "${timestamp()}"
  }
  depends_on = [google_bigquery_data_transfer_config.thelook-transfer, module.thelook-dataset]
  provisioner "local-exec" {
    command = "bq query --project_id ${module.land-project.project_id} --nouse_legacy_sql 'CREATE OR REPLACE VIEW `${module.land-project.project_id}.${module.thelook-dataset.dataset_id}._simple_view` AS ( SELECT id, age, email, state, city FROM `${module.land-project.project_id}.${module.thelook-dataset.dataset_id}.users` )';"
  }
}
