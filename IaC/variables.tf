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