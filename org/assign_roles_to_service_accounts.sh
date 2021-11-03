#!/bin/sh

ccloud login

make_config()
{
   CFG_ENV=$1
   echo "Generating config for ${CFG_ENV}"

   # TODO: Error checking

   # ${CFG_ENV}uction
   echo "# environment " > ${CFG_ENV}.tfvars
   ccloud environment use `terraform output -raw env_${CFG_ENV}_id`
   echo environment=`terraform output env_${CFG_ENV}_id` >> ${CFG_ENV}.tfvars

   echo "# service account: `terraform output -raw sa_${CFG_ENV}_id`" >> ${CFG_ENV}.tfvars

   echo "# cluster details" >> ${CFG_ENV}.tfvars
   echo cluster_id=`terraform output cluster_${CFG_ENV}_id` >> ${CFG_ENV}.tfvars
   echo cluster_http_endpoint=`terraform output cluster_${CFG_ENV}_http_endpoint` >> ${CFG_ENV}.tfvars

   # create role binding for service account
   ccloud iam rolebinding create --role CloudClusterAdmin --principal User:`terraform output -raw sa_${CFG_ENV}_id` --environment `terraform output -raw env_${CFG_ENV}_id` --cloud-cluster `terraform output -raw cluster_${CFG_ENV}_id`

   # need to loop and wait until cluster is available
   # create kafka cluster acls
   /usr/bin/false
   while [ $? -ne 0 ] ; do
      ccloud kafka acl create --environment `terraform output -raw env_${CFG_ENV}_id` --cluster `terraform output -raw cluster_${CFG_ENV}_id` --allow --service-account `terraform output -raw sa_${CFG_ENV}_id` --cluster-scope  --operation ALTER --operation ALTER-CONFIGS --operation CREATE --operation DELETE --operation DESCRIBE --operation DESCRIBE-CONFIGS --operation READ --operation WRITE
   done
   # create kafka topic acls
   /usr/bin/false
   while [ $? -ne 0 ] ; do
      ccloud kafka acl create --environment `terraform output -raw env_${CFG_ENV}_id` --cluster `terraform output -raw cluster_${CFG_ENV}_id` --allow --service-account `terraform output -raw sa_${CFG_ENV}_id` --topic '*' --operation ALTER --operation ALTER-CONFIGS --operation CREATE --operation DELETE --operation DESCRIBE --operation DESCRIBE-CONFIGS --operation READ --operation WRITE
   done

   # create api keys
   echo "# cloud api-key" >> ${CFG_ENV}.tfvars
   ccloud api-key create --service-account `terraform output -raw sa_${CFG_ENV}_id` --resource "cloud" --description "api-key for ${CFG_ENV} service account" -o yaml | sed s/^/api_/ | sed s/:\ /=\"/ | sed s/$/\"/ >> ${CFG_ENV}.tfvars

   # create kafka api keys
   echo "# kafka api-key" >> ${CFG_ENV}.tfvars
   ccloud api-key create --service-account `terraform output -raw sa_${CFG_ENV}_id` --resource `terraform output -raw cluster_${CFG_ENV}_id` --description "api-key for ${CFG_ENV} service account" -o yaml | sed s/^/kafka_api_/ | sed s/:\ /=\"/ | sed s/$/\"/ >> ${CFG_ENV}.tfvars

   cp ${CFG_ENV}.tfvars ../${CFG_ENV}/terraform.tfvars
}

make_config prod
make_config stag
make_config test
make_config dev
