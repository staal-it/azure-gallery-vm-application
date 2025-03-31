# global
location       = "westeurope"
location_short = "we"
environment    = "prod"
workload       = "azuregallery"
workload_short = "azga"

tags = {
  WorkloadName          = "azuregallery"
  Environment           = "prod"
  Owner                 = "Azure Cloud Platform Team"
  Location              = "WestEurope"
  BusinessUnit          = "Core IT"
  BusinessUnitOwnerName = "Azure Cloud Platform Team"
  BusinessUnitOwnerTeam = "Azure Cloud Platform Team"
  ITApplicationContact  = "Azure Cloud Platform Team"
  Confidentiality       = "1"
  Integrity             = "1"
  Availability          = "1"
  PrivacyClassification = "1"
  LandingZone           = "V2"
  CostCenter            = "CCOE"
}

java = {
  supported_os_type = "Windows"
  location          = "westeurope"
  target_regions = {
    westeurope = {
      exclude_from_latest    = false
      location               = "westeurope"
      regional_replica_count = 1
      storage_account_type   = "Standard_LRS"
    }
    northeurope = {
      exclude_from_latest    = false
      location               = "northeurope"
      regional_replica_count = 1
      storage_account_type   = "Standard_LRS"
    }
  }
}
