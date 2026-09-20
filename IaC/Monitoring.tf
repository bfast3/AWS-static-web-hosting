resource "aws_cloudwatch_dashboard" "site" {
  dashboard_name = "${var.bucket_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "CloudFront Requests"
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          period  = 300
          stat    = "Sum"
          metrics = [
            [
              "AWS/CloudFront",
              "Requests",
              "DistributionId",
              aws_cloudfront_distribution.site.id,
              "Region",
              "Global"
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "S3 AllRequests"
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          period  = 300
          stat    = "Sum"
          metrics = [
            [
              "AWS/S3",
              "AllRequests",
              "BucketName",
              var.bucket_name,
              "FilterId",
              aws_s3_bucket_metric.site.name
            ]
          ]
        }
      }
    ]
  })
}

data "aws_region" "current" {}

output "dashboard_url" {
  value = "https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=${aws_cloudwatch_dashboard.site.dashboard_name}"
}
