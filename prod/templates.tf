resource "confluentcloud_kafka_topic" "orders" {

  for_each      =  { for topic, data in local.data_topics : topic => data }

  topic_name         = each.value.topic
  partitions_count   = try(each.value.data.partitions, 4)
  config = {
    "cleanup.policy"    = try(each.value.data.cleanup_policy, "compact")
  }

  kafka_cluster      = var.cluster_id
  http_endpoint      = var.cluster_http_endpoint
  credentials {
    key    = var.kafka_api_key
    secret = var.kafka_api_secret
  }
}

resource "confluentcloud_kafka_acl" "topic_acls" {

  for_each      =  { for user, data in local.data_topic_acls : user => data }

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

  for_each      =  { for user, data in local.data_cluster_acls : user => data }

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
