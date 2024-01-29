# Samuel Berthollier - 2024
#
# Unless required by applicable law or agreed to in writing, software
# distributed is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

variable "super_admin" {
  description = "For creating primary assets"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Prevent Terraform from destroying data storage resources (storage buckets, GKE clusters, CloudSQL instances) in this blueprint. When this field is set in Terraform state, a terraform destroy or terraform apply that would delete data storage resources will fail."
  type        = bool
  default     = false
  nullable    = false
}

variable "delete_contents_on_destroy" {
  description = "If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present."
  type        = bool
  default     = false
}

variable "enable_services" {
  description = "Flag to enable or disable services in the Data Platform."
  type = object({
    composer                = optional(bool, true)
    dataproc_history_server = optional(bool, true)
  })
  default = {}
}

variable "location" {
  description = "Location used for multi-regional resources."
  type        = string
  default     = "eu"
}

variable "organization_domain" {
  description = "Organization domain."
  type        = string
}

variable "prefix" {
  description = "Prefix used for resource names."
  type        = string
  validation {
    condition     = var.prefix != ""
    error_message = "Prefix cannot be empty."
  }
}

variable "project_config" {
  description = "Provide 'billing_account_id' value if project creation is needed, uses existing 'project_ids' if null. Parent is in 'folders/nnn' or 'organizations/nnn' format."
  type = object({
    billing_account_id = optional(string, null)
    parent             = string
    project_ids = optional(object({
      landing    = string
      }), {
      landing    = "lnd"
      }
    )
  })
  validation {
    condition     = var.project_config.billing_account_id != null || var.project_config.project_ids != null
    error_message = "At least one of project_config.billing_account_id or var.project_config.project_ids should be set."
  }
}

variable "project_suffix" {
  description = "Suffix used only for project ids."
  type        = string
  default     = null
}

variable "region" {
  description = "Region used for regional resources."
  type        = string
  default     = null
}


variable "thelook_dataset" {
  description = "Dataset copied from thelook_ecommerce"
  type        = string
  default     = null
}
