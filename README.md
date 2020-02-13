# Terraform Lambda Function Module


## Overview

Terraform lambda module to run an ECS task that triggered by a S3 event.

This module in main.tf file contains the necessary parameters:


## Variables

**region** (String) The region where you want to deploy the application

**filterprefix** (String) Lambda function invoke prefix for S3 Objecy Create or put

**filtersuffix** (String) A file extension name as a Lambda function invoke suffix

**lambda_source_package** (String) Lambda function source file name with location

**s3_bucket_name** (String) S3 bucket name where you want to create notification event

**ecs_cluster_name** (String) ECS cluster name that hosts the ARC ETL task

**ecs_task_name** (String) An ECS task definition name

**ecs_container_name** (String) Container name in an ECS task


## Outputs

**lambda_function_name**: Lambda Function name

**lambda_role_name**: The name of an IAM role created for the Lambda Function access


