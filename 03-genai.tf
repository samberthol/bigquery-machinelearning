# Samuel Berthollier - 2024
#
# Unless required by applicable law or agreed to in writing, software
# distributed is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

 resource "google_bigquery_connection" "connection" {
    connection_id = "thisbison"
    project = module.land-project.project_id
    location = var.location
    cloud_resource {}
}

resource "null_resource" "bqml-model" {
  depends_on = [google_bigquery_connection.connection]
  provisioner "local-exec" {
    command = "bq query --project_id ${module.land-project.project_id} --nouse_legacy_sql 'CREATE OR REPLACE MODEL `${module.land-project.project_id}.${module.thelook-dataset.dataset_id}.bison_model` REMOTE WITH CONNECTION `${google_bigquery_connection.connection.id}` OPTIONS (ENDPOINT = \"text-bison\");'"
  }
}

resource "google_project_iam_member" "custom_service_account" {
  provider = google-beta
  project  = module.land-project.project_id
  member   = format("serviceAccount:%s", google_bigquery_connection.connection.cloud_resource[0].service_account_id)
  role     = "roles/aiplatform.user"
}

resource "null_resource" "genai_product_description" {
  triggers = {
   always_run = "${timestamp()}"
  }
  depends_on = [null_resource.bqml-model]
  provisioner "local-exec" {
    command = "bq query --project_id ${module.land-project.project_id} --nouse_legacy_sql 'CREATE OR REPLACE VIEW ${module.thelook-dataset.dataset_id}._genai_view AS (SELECT * EXCEPT (ml_generate_text_rai_result, ml_generate_text_status) FROM ML.GENERATE_TEXT(MODEL `thelook.bison_model`, (SELECT category, brand, name, CONCAT(\"Create a description for the article that has the following category, brand and name: \", category, brand, name) AS prompt FROM `thelook.products` WHERE brand = \"Calvin Klein\" LIMIT 5), STRUCT(0.2 AS temperature, 1000 AS max_output_tokens, TRUE AS flatten_json_output)));'"
  }
}
