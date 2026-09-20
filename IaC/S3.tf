resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name
}


# All public access blocked. The bucket is only reachable through CloudFront,
# via the OAC-scoped bucket policy defined in CloudFront.tf.
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# ################################################################################
# # Upload assets from ../assets
# ################################################################################

resource "aws_s3_object" "assets" {
  for_each = fileset(var.assets_dir, "**")

  bucket = aws_s3_bucket.site.id
  key    = each.value
  source = "${var.assets_dir}/${each.value}"
  etag   = filemd5("${var.assets_dir}/${each.value}")

  content_type = lookup(
    {
      html = "text/html"
      css  = "text/css"
      js   = "application/javascript"
    },
    split(".", each.value)[length(split(".", each.value)) - 1],
    "application/octet-stream"
  )
}