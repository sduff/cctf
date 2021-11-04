#
# Environment definitions
#

# Production environment
resource "confluentcloud_environment" "env-prod" {
     display_name = "team"
}
output "env_prod_id" {
   value = confluentcloud_environment.env-prod.id
}

# Staging environment
resource "confluentcloud_environment" "env-stag" {
     display_name = "Stag"
}
output "env_stag_id" {
   value = confluentcloud_environment.env-stag.id
}

# Test environment
resource "confluentcloud_environment" "env-test" {
     display_name = "Test"
}
output "env_test_id" {
   value = confluentcloud_environment.env-test.id
}

# Dev environment
resource "confluentcloud_environment" "env-dev" {
     display_name = "dev"
}
output "env_dev_id" {
   value = confluentcloud_environment.env-dev.id
}


#
# Single Cluster in each environment
#

# Production Cluster
resource "confluentcloud_kafka_cluster" "prod-cluster" {
  display_name = "prod-cluster"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "us-east-2"
  basic {}

  environment {
    id = confluentcloud_environment.env-prod.id
  }
}
output "cluster_prod_id" {
   value = confluentcloud_kafka_cluster.prod-cluster.id
}
output "cluster_prod_http_endpoint" {
   value = confluentcloud_kafka_cluster.prod-cluster.http_endpoint
}

# Staging Cluster
resource "confluentcloud_kafka_cluster" "stag-cluster" {
  display_name = "stag-cluster"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "us-east-2"
  basic {}

  environment {
    id = confluentcloud_environment.env-stag.id
  }
}
output "cluster_stag_id" {
   value = confluentcloud_kafka_cluster.stag-cluster.id
}
output "cluster_stag_http_endpoint" {
   value = confluentcloud_kafka_cluster.stag-cluster.http_endpoint
}

# Testing Cluster
resource "confluentcloud_kafka_cluster" "test-cluster" {
  display_name = "test-cluster"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "us-east-2"
  basic {}

  environment {
    id = confluentcloud_environment.env-test.id
  }
}
output "cluster_test_id" {
   value = confluentcloud_kafka_cluster.test-cluster.id
}
output "cluster_test_http_endpoint" {
   value = confluentcloud_kafka_cluster.test-cluster.http_endpoint
}

# Dev Cluster
resource "confluentcloud_kafka_cluster" "dev-cluster" {
  display_name = "dev-cluster"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "us-east-2"
  basic {}

  environment {
    id = confluentcloud_environment.env-dev.id
  }
}
output "cluster_dev_id" {
   value = confluentcloud_kafka_cluster.dev-cluster.id
}
output "cluster_dev_http_endpoint" {
   value = confluentcloud_kafka_cluster.dev-cluster.http_endpoint
}

#
# Management Service Accounts
#

# Production Service Account
resource "confluentcloud_service_account" "sa-prod" {
     display_name = "sa-prod"
     description = "Service Account for Production environment"
}
output "sa_prod_id" {
   value = confluentcloud_service_account.sa-prod.id
}

# Staging Service Account
resource "confluentcloud_service_account" "sa-stag" {
     display_name = "sa-stag"
     description = "Service Account for staguction environment"
}
output "sa_stag_id" {
   value = confluentcloud_service_account.sa-stag.id
}

# Test Service Account
resource "confluentcloud_service_account" "sa-test" {
     display_name = "sa-test"
     description = "Service Account for testuction environment"
}
output "sa_test_id" {
   value = confluentcloud_service_account.sa-test.id
}

# Dev Service Account
resource "confluentcloud_service_account" "sa-dev" {
     display_name = "sa-dev"
     description = "Service Account for devuction environment"
}
output "sa_dev_id" {
   value = confluentcloud_service_account.sa-dev.id
}

#
# Custom Service Accounts
#

# Client Waldo Service Account
resource "confluentcloud_service_account" "sa-client-test" {
     display_name = "sa-client-test"
     description = "Test Client Service Account"
}

