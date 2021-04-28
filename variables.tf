# tag resource
variable "aws_tags" {
  type        = map(string)
  description = "Tag for services"
  default = {
    name    = "auto-tagging",
    owner   = "dang.lehai",
    project = "tagging when running"
  }
}

# function name
variable "function" {
  type        = string
  description = "Name of function"
  default     = "auto_tagging"
}

# event pattern of Event Rule
variable "evnt_pattern" {
  type        = string
  description = "Event Pattern of EventBridge Rule"
  default     = <<PATTERN
  {
    "source": ["aws.ec2"],
    "detail-type": ["AWS API Call via CloudTrail"],
    "detail": {
      "eventSource": ["ec2.amazonaws.com"],
      "eventName": ["RunInstances"]
    }
  }
  PATTERN
}

