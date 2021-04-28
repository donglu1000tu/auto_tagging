# Event Bridge in Terraform is called "AWS CloudWatch Event"
# Create Event Rule to catch "RunInstances" events
resource "aws_cloudwatch_event_rule" "auto-tagging" {
  name        = var.function # see this variable in variable.tf
  description = "Auto tagging one or multiple Regions"
  # event_bus_name is default if dont declare 
  # is_enable is true
  event_pattern = var.evnt_pattern # see this variable in variable.tf
  tags          = var.aws_tags     # see this variable in variable.tf
}

# Make sure Target of Event Rule is your Lambda function
# @param: depends_on show order of creation 
resource "aws_cloudwatch_event_target" "target-lambda" {
  target_id = "auto-tagging"
  rule      = aws_cloudwatch_event_rule.auto-tagging.id # id of Event Rule
  arn       = aws_lambda_function.auto_tagging.arn      # ARN of Event Rule
  depends_on = [
    aws_lambda_function.auto_tagging
  ]
}