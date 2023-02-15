variable "user" {
  type    = string
  default = ""
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "tags" {
  type        = map(string)
  default     = { "Project" = "Platform Engineering" }
  description = "Resource tags"
}

variable "owner" {
  type    = string
  default = "platform-engineering-org-test"
}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}
