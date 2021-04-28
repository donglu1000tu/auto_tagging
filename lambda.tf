# Function permission to recieve events from Event Rule
resource "aws_lambda_permission" "lambda_permission" {
  function_name = var.function
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.auto-tagging.arn
}

# Lambda Function
resource "aws_lambda_function" "auto_tagging" {
  function_name = var.function
  role          = aws_iam_role.tagging_role.arn # Get permission to tag
  description   = "Auto-tagging function"
  filename      = "${var.function}.zip"
  runtime       = "python3.8"                      # runtime: python3.8
  handler       = "${var.function}.lambda_handler" # Function handle events:
  depends_on = [
    aws_iam_role.tagging_role # creating after the creation of IAM Role
  ]
  publish          = true                                    # version
  source_code_hash = filebase64sha256("${var.function}.zip") # hash code for file
  tags             = var.aws_tags
}