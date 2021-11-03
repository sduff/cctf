terraform {
  required_providers {
    confluentcloud = {
      source  = "confluentinc/confluentcloud"
      version = "0.1.0"
    }
  }
}

# Code
provider "confluentcloud" {
   api_key=var.api_key
   api_secret=var.api_secret
}
