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
    actions   = ["iam:PassRole"]
    resources = ["*"]
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
  name               = "${var.app_name}-lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

# ------------------------------------------------------------------------------------------------
# Create Policies for above Roles
# ------------------------------------------------------------------------------------------------

resource "aws_iam_policy" "lambda_logging" {
  name = "lambda_logging"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/tf-${var.app_name}:*"
            ]
        }
  ]
}
EOF
}


# ------------------------------------------------------------------------------------------------
# Attach Policies to Role
# ------------------------------------------------------------------------------------------------
# resource "aws_iam_role_policy_attachment" "ecs_pol" {
#   name = "${var.app_name}-ecs"
#   role = aws_iam_role.lambda_role.name
#   policy_arn = data.aws_iam_policy_document.ecs.json
# }

# resource "aws_iam_role_policy_attachment" "lambdalog_pol" {
#   name = "${var.app_name}-lambdalog"
#   role = aws_iam_role.lambda_role.name
#   policy_arn = aws_iam_policy.lambda_logging.arn
# }
