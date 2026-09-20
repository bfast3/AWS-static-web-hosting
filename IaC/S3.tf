resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name
}


resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = var.index_document
  }
}

# The S3 *website endpoint* is HTTP-only and does not support OAC, so the bucket
# must be readable to serve through CloudFront as a custom origin.
# If you'd rather keep the bucket fully private, see the OAC note further down.
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "site_public_read" {
  statement {
    sid     = "PublicReadGetObject"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = ["${aws_s3_bucket.site.arn}/*"]

    # Tighten this: only allow requests carrying the shared secret header that
    # CloudFront injects, so the website endpoint isn't hit directly.
    # condition {
    #   test     = "StringEquals"
    #   variable = "aws:UserAgent"
    #   values   = [random_password.origin_secret.result]
    # }
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site_public_read.json

  depends_on = [aws_s3_bucket_public_access_block.site]
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