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
resource "aws_cloudwatch_event_rule" "auto_tagging" {
  name        = var.function
  description = "Auto tagging one or multiple Regions"
  # event_bus_name is default 
  # is_enable is true
  event_pattern = var.evnt_pattern
  tags          = var.aws_tags # need variables
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "Lambda-permission-from-NganTu"
  function_name = var.function
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.auto_tagging.arn
}

module "lambda_function" {
  source        = "terraform-aws-modules/lambda/aws"
  function_name = var.function
  description   = "Auto-tagging function"
  # local_existing_package = "C:/Users/dang.lehai/Desktop/KLTN/terraform/auto_tagging.zip"
  source_path = "${var.function}.py"
  handler     = "${var.function}.lambda_handler"
  runtime     = "python3.8"
  # create_current_version_allowed_triggers = true
  publish = true
  allowed_triggers = {
    EventBridge = {
      principal  = "events.amazonaws.com",
      source_arn = aws_cloudwatch_event_rule.auto_tagging.arn
    }
  }
  tags = var.aws_tags # need variables
}