# Samuel Berthollier - 2024
#
# Unless required by applicable law or agreed to in writing, software
# distributed is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

output "projects" {
  description = "GCP Projects information."
  value = {
    projects = {
      landing_project_number    = module.land-project.number,
      landing_project_id         = module.land-project.project_id
    }
  }
}

output "accounts" {
  description = "Service account created."
  value = {
    Landing_SA    = module.land-sa-0.email,
    Billing_account   = var.project_config.billing_account_id,
    Super_admin       = var.super_admin    
  }
}

output "bigquery-datasets" {
  description = "BigQuery datasets."
  value = {
    thelook_dataset        = module.thelook-dataset.dataset_id
  }
}

output "sa" {
  description = "sa"
  value = {
    sa_bq_con        = google_bigquery_connection.connection.cloud_resource[0]
  }
}


      