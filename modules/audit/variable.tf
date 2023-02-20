variable "aws_region" {
  type    = string
  default = "eu-west-2"
}
variable "user" {
  type    = string
  default = ""
}

variable "tags" {
  type        = map(string)
  default     = { "Project" = "Project Engineering" }
  description = "Resource tags"
}
