terraform {
  # required_version = "0.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.37.0"
    }
  }
}

data "aws_regions" "all_regions" {
  all_regions = true
  #   filter {
  #     name = "OptInStatus"
  #     values = [ "opt" ]
  #   }
}
provider "aws" {
  profile = "default"
  #   region  = data.aws_regions.current
  region = "us-east-1"
}

# module "eb_rule" {
#   source = "terraform-aws-modules/eventbridge/aws"

# }

resource "aws_iam_policy" "execPolicy" {
  name        = "ExecutionLambdaFunctionPolicyByNganTu"
  description = "Execution Policy of Lambda function"
  path        = "/service-role/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "logs:CreateLogGroup",
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:555516925462:*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:*:555516925462:log-group:/aws/lambda/${var.function}:*"
        ]
      }
    ]
  })
  tags = var.aws_tags
}

resource "aws_iam_role" "tagging_role" {
  name                = "auto-tagging-role"
  path                = "/service-role/"
  managed_policy_arns = [aws_iam_policy.execPolicy.arn]
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRole",
      Principal = {
        Service = [
          "ec2.amazonaws.com",
          "lambda.amazonaws.com"
        ]
      }
    }]
  })
  inline_policy {
    name = "inlineExcutePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = "ec2:CreateTags",
          Effect = "Allow",
          Resource = [
            "arn:aws:ec2:*:*:instance/*",
            "arn:aws:ec2:*:*:volume/*"
          ]
        },
        {
          Action = [
            "ec2:DescribeInstances",
            "ec2:DescribeVolumes"
          ],
          Effect   = "Allow",
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_cloudwatch_event_rule" "auto-tagging" {
  name        = var.function
  description = "Auto tagging one or multiple Regions"
  # event_bus_name is default if dont declare 
  # is_enable is true
  event_pattern = var.evnt_pattern
  tags          = var.aws_tags # need variables
}

resource "aws_cloudwatch_event_target" "target-lambda" {
  target_id = "auto-tagging"
  rule      = aws_cloudwatch_event_rule.auto-tagging.id
  arn       = module.lambda_function.lambda_function_arn
  depends_on = [
    module.lambda_function
  ]
}
resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "Lambda-permission-from-NganTu"
  function_name = var.function
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.auto-tagging.arn
}

module "lambda_function" {
  source        = "terraform-aws-modules/lambda/aws"
  function_name = var.function
  description   = "Auto-tagging function"
  # attach_policy = true
  # policy        = aws_iam_policy.execPolicy.arn
  # local_existing_package = "C:/Users/dang.lehai/Desktop/KLTN/terraform/auto_tagging.zip"
  source_path = "${var.function}.py"
  handler     = "${var.function}.lambda_handler"
  runtime     = "python3.8"
  # create_current_version_allowed_triggers = true
  publish = true
  allowed_triggers = {
    EventBridge = {
      principal  = "events.amazonaws.com",
      source_arn = aws_cloudwatch_event_rule.auto-tagging.arn
    }
  }
  tags = var.aws_tags # need variables
}