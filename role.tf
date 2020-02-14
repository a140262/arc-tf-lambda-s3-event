data "aws_caller_identity" "current" {}

# Trust relationship policy document for AWS Service.
data "aws_iam_policy_document" "lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs" {

  statement {
    actions = [
      "ecs:RunTask"
    ]
    resources = [
      "arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:task-definition/${var.ecs_task_name}:*"
    ]
    condition {
      test     = "ArnLike"
      variable = "ecs:cluster"
      values = [
        "arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.ecs_cluster_name}"
      ]
    }
  }
  statement {
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
    ]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}


# ------------------------------------------------------------------------------------------------
# Create Roles
# ------------------------------------------------------------------------------------------------

resource "aws_iam_role" "lambda_role" {
  name               = "s3-ecs-task-lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda.json

  tags = {
    Name = "arcdemo-lambda-role"
  }
}


# ------------------------------------------------------------------------------------------------
# Attach Policies to Role
# ------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "lamba_exec_role_eni" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "ecs_lambda" {
  name   = "lambda_run_ecs"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.ecs.json
}
