# variable "dang_region" {
#   type        = list(string)
#   description = "(optional) describe your variable"
#   default = [

#   ]
# }

variable "aws_tags" {
  type        = map(string)
  description = "Tag for services"
  default = {
    name    = "auto-tagging",
    owner   = "dang.lehai",
    project = "tagging when running"
  }
}

variable "function" {
  type        = string
  description = "Name of function"
  default     = "auto_tagging"
}

variable "evnt_pattern" {
  type        = string
  description = "Event Pattern of EventBridge Rule"
  default     = <<EOF
  {
    "source": ["aws.ec2"],
    "detail-type": ["AWS API Call via CloudTrail"],
    "detail": {
      "eventSource": ["ec2.amazonaws.com"],
      "eventName": ["RunInstances"]
    }
  }
  EOF
}
