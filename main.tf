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
  # profile = "default"
  #   region  = data.aws_regions.current
  region = "us-east-1"
}

resource "aws_lambda_permission" "lambda_permission" {
  # statement_id  = "Lambda-permission-from-NganTu"
  function_name = var.function
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.auto-tagging.arn
}

resource "aws_lambda_function" "auto_tagging" {
  function_name = var.function
  role          = aws_iam_role.tagging_role.arn
  description   = "Auto-tagging function"
  filename      = "${var.function}.zip"
  runtime       = "python3.8"
  handler       = "${var.function}.lambda_handler"
  depends_on = [
    aws_iam_role.tagging_role
  ]
  publish          = true
  source_code_hash = filebase64sha256("${var.function}.zip")
  tags             = var.aws_tags
}