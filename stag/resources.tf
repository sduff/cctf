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
