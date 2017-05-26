# global variables
variable "cluster_head_ip_address" {}

# aws related variables
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_default_key_pairs_name" {}
variable "aws_default_app_ami_name" {}
variable "aws_default_app_instance_type" {}
variable "aws_primary_region" {
    default  = "us-east-1"
}
