# Samuel Berthollier - 2024
#
# Unless required by applicable law or agreed to in writing, software
# distributed is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

resource "null_resource" "segmentation" {
  depends_on = [google_bigquery_connection.connection]
  provisioner "local-exec" {
    command = "bq query --project_id ${module.land-project.project_id} --nouse_legacy_sql 'CREATE OR REPLACE MODEL `${module.land-project.project_id}.${module.thelook-dataset.dataset_id}.sales_segments` OPTIONS (MODEL_TYPE=\"KMEANS\", NUM_CLUSTERS=4) AS SELECT u.country, p.brand, p.category, SUM(i.sale_price*o.num_of_item) AS sales_sum FROM `${module.land-project.project_id}.${module.thelook-dataset.dataset_id}.order_items` AS i JOIN `${module.land-project.project_id}.${module.thelook-dataset.dataset_id}.orders` AS o ON i.order_id = o.order_id JOIN `${module.land-project.project_id}.${module.thelook-dataset.dataset_id}.products` AS p ON i.product_id = p.id JOIN `${module.land-project.project_id}.${module.thelook-dataset.dataset_id}.users` AS u ON u.id = i.user_id GROUP BY 1,2,3;'"
  }
}

