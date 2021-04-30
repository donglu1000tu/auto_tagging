# Policy for Lambda to Create Log Group and Log Stream, also allow Put Log Events to Group and Stream
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

# Role for Lambda, attach Policy above and generate inline policy 
# Assume role give temporary credentials for access EC2 and Lambda
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
          "lambda.amazonaws.com" # need=to creating lambda
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
        },
      ]
    })
  }
}