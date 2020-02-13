variable "region" {
  description = "The AWS region we want this bucket to live in."
  default     = "ap-southeast-2"
}

variable "app_name" {
  default = "s3-ecs-task"
}

variable "lambda_runtime" {
  default = "nodejs10.x"
}

variable "filtersuffix" {
  default = ".ipynb"
}

variable "filterprefix" {
  default = "arcjupyter/job"
}

variable "lambda_timeout" {
  default = "60"
}

variable "lambda_handler" {
  default = "index.handler"
}

variable "lambda_source_package" {
  default = "lambda_func.js.zip"
}

variable "s3_bucket_name" {
  description = "The S3 bucket name to have an event trigger setup"
  default     = "testtestmelody"
}

variable "ecs_cluster_name" {
  default = "arc-cluster"
}

variable "ecs_task_name" {
  default = "arc-etl-task"
}

variable "ecs_container_name" {
  default = "arc-etl"
}

variable "is_stream" {
  description = "true or false to decide if the ecs task going to be a streaming process or batch process"
  default     = "false"
}

