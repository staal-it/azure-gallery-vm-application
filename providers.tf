terraform {
  required_version = "~> 1.1, <= 1.8.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
  }
}

provider "azurerm" {
  features {}
}

