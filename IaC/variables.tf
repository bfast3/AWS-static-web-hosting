variable "bucket_name" {
  description = "Globally unique name for the static site bucket."
  type        = string
}

variable "assets_dir" {
  description = "Path to the local directory holding the site assets."
  type        = string
}

variable "index_document" {
  type    = string
  default = "index.html"
}

variable "aws_region" {
  description = "This is the region used in the providers.tf file in which the AWS resources are deployed."
  type        = string
}