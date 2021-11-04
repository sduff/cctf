# Topic Definition

resource "confluentcloud_kafka_topic" "orders" {
  kafka_cluster      = var.cluster_id
  topic_name         = "orders"
  partitions_count   = 4
  http_endpoint      = var.cluster_http_endpoint
  config = {
    "cleanup.policy"    = "compact"
    "max.message.bytes" = "12345"
    "retention.ms"      = "67890"
  }
  credentials {
    key    = var.kafka_api_key
    secret = var.kafka_api_secret
  }
}


# ACL definition

locals {

   # All Topic ACLs
   # [ "ALTER", "ALTER_CONFIGS", "CREATE", "DELETE", "DESCRIBE", "DESCRIBE_CONFIGS", "READ", "WRITE" ],

   user_topics = {
      "User:385410" = {
         "orders" : [ "ALTER", "ALTER_CONFIGS", "CREATE", "DELETE", "DESCRIBE", "DESCRIBE_CONFIGS", "READ", "WRITE" ],
         "myorders" : [ "READ", "WRITE" ]
      },
   }

   # All Cluster ACLs
   # [ "ALTER", "ALTER_CONFIGS", "CLUSTER_ACTION", "CREATE", "DESCRIBE", "DESCRIBE_CONFIGS", "IDEMPOTENT_WRITE" ]

   user_cluster = {
      "User:385410": [ "ALTER", "ALTER_CONFIGS", "CLUSTER_ACTION", "CREATE", "DESCRIBE", "DESCRIBE_CONFIGS", "IDEMPOTENT_WRITE" ]
   }


   # Utility functions, don't modify beyond this point
   topic_data = flatten([for user, value in local.user_topics:
      flatten([for topic, operations in value:
         [for op in operations:
            { "user" = user, "topic" = topic, "op" = op }
         ]])
      ])

   cluster_data = flatten([for user, operations in local.user_cluster:
      flatten( [for op in operations:
            { "user" = user, "op" = op }
         ])
      ])

}

resource "confluentcloud_kafka_acl" "topic_acls" {

  for_each      =  { for user, data in local.topic_data : user => data }

  principal     = each.value.user

  pattern_type  = "LITERAL"
  resource_type = "TOPIC"
  resource_name = each.value.topic

  operation     = each.value.op
  permission    = "ALLOW"

  host          = "*"
  kafka_cluster = var.cluster_id
  http_endpoint = var.cluster_http_endpoint
  credentials {
    key    = var.kafka_api_key
    secret = var.kafka_api_secret
  }
}

resource "confluentcloud_kafka_acl" "cluster_acls" {

  for_each      =  { for user, data in local.cluster_data : user => data }

  principal     = each.value.user

  pattern_type  = "LITERAL"
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"

  operation     = each.value.op
  permission    = "ALLOW"

  host          = "*"
  kafka_cluster = var.cluster_id
  http_endpoint = var.cluster_http_endpoint
  credentials {
    key    = var.kafka_api_key
    secret = var.kafka_api_secret
  }
}
