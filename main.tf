provider "aws" {
  region = var.region
}

data "aws_s3_bucket" "selected" {
  bucket = var.s3_bucket_name
}

data "aws_ecs_task_definition" "etl" {
  task_definition = var.ecs_task_name
}

resource "aws_lambda_function" "lambda_function" {
  filename         = var.lambda_source_package
  function_name    = "tf-${var.app_name}"
  role             = aws_iam_role.lambda_role.arn
  handler          = var.lambda_handler
  source_code_hash = filebase64sha256(var.lambda_source_package)
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout

  environment {
    variables = {
      region                  = var.region
      s3_key_suffix_whitelist = "[\"${var.filtersuffix}\"]"
      IS_STREAM               = var.is_stream
      CLUSTER_NAME            = var.ecs_cluster_name
      TASK_ID                 = "${var.ecs_task_name}:${data.aws_ecs_task_definition.etl.revision}"

    }
  }
}

resource "aws_lambda_permission" "allow_s3_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.selected.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.selected.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.filterprefix
    filter_suffix       = var.filtersuffix
  }
}
