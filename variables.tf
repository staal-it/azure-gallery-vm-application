# global
variable "location" {
  description = "Specified the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}

variable "tags" {
  description = "A mapping of tags which should be assigned to all resources."
  type        = map(string)
  default     = null
}

variable "workload" {
  description = "Name of the workload"
  default     = "azuregallery"
  type        = string
}

variable "workload_short" {
  description = "Name of the workload"
  default     = "azga"
  type        = string
}

variable "location_short" {
  description = "Short name of the location"
  default     = "we"
  type        = string
}

variable "environment" {
  description = "Name of the environment"
  default     = "prod"
  type        = string
}

variable "java" {
  type = object({
    supported_os_type = string
    location          = string
    target_regions = map(object({
      exclude_from_latest    = bool
      location               = string
      regional_replica_count = number
      storage_account_type   = string
    }))
  })
}
