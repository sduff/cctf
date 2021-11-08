locals {

   topics = {
      "orders" = {"cleanup_policy" = "delete"},
      "myorders" = {"partitions" = 10}
   }

   # All Topic ACLs
   # [ "ALTER", "ALTER_CONFIGS", "CREATE", "DELETE", "DESCRIBE", "DESCRIBE_CONFIGS", "READ", "WRITE" ],

   user_topics = {
      "sa-client-waldo" = {
         #"orders" : [ "ALTER", "ALTER_CONFIGS", "CREATE", "DELETE", "DESCRIBE", "DESCRIBE_CONFIGS", "READ", "WRITE" ]
         "orders" : [ "READ" ]
      },
   }

   # All Cluster ACLs
   # [ "ALTER", "ALTER_CONFIGS", "CLUSTER_ACTION", "CREATE", "DESCRIBE", "DESCRIBE_CONFIGS", "IDEMPOTENT_WRITE" ]

   user_cluster = {
      #"sa-client-waldo": [ "ALTER", "ALTER_CONFIGS", "CLUSTER_ACTION", "CREATE", "DESCRIBE", "DESCRIBE_CONFIGS", "IDEMPOTENT_WRITE" ]
      "sa-client-waldo": [ "ALTER" ]
   }

   # --------------------------------------------------------------------------
   # Utility functions, don't modify beyond this point

   # read in ccloud's service_account list json output as a map for terraform
   service_accounts_json = jsondecode(file("service_accounts.json"))
   service_accounts = { for sa in local.service_accounts_json: sa.name => "User:${sa.id}" }

   # flatten local objects for multiple resources
   data_topics = flatten([for topic, data  in local.topics:
      {
         "topic" = topic,
         "data" = data
      }
   ])

   data_topic_acls = flatten([for user, value in local.user_topics:
      flatten([for topic, operations in value:
         [for op in operations:
            {
               "user" = lookup(local.service_accounts, user, user),
               "topic" = topic,
               "op" = op 
            }
         ]])
      ])

   data_cluster_acls = flatten([for user, operations in local.user_cluster:
      flatten( [for op in operations:
            {
               "user" = lookup(local.service_accounts, user, user),
               "op" = op
            }
         ])
      ])

}
