provider "aws" {
  version = "~> 2.60.0"
  region  = "us-east-1"
}

resource "aws_acm_certificate" "certificate" {
  domain_name       = var.primary_domain
  validation_method = "DNS"

  tags = {
    Environment = "dropshare"
  }

  lifecycle {
    create_before_destroy = true
  }

  subject_alternative_names = [
    "*.${var.primary_domain}"
  ]
}

data "aws_route53_zone" "primary" {
  name         = "${var.primary_domain}."
  private_zone = false
}

resource "aws_route53_record" "rebrandly" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.primary_domain
  type    = "A"
  ttl     = "300"
  records = ["52.72.49.79"]
}

resource "aws_route53_record" "cert_verification" {
  name    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.primary.zone_id
  records = ["${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = ["${aws_route53_record.cert_verification.fqdn}"]
}


module "cloudfront-s3-cdn" {
  name                     = "${replace(var.primary_domain, ".", "-")}"
  source                   = "cloudposse/cloudfront-s3-cdn/aws"
  version                  = "0.23.1"
  aliases                  = ["share.${var.primary_domain}"]
  parent_zone_name         = var.primary_domain
  logging_enabled          = false
  price_class              = "PriceClass_All"
  minimum_protocol_version = "TLSv1.2_2018"
  acm_certificate_arn      = "${aws_acm_certificate_validation.validation.certificate_arn}"
}


resource "aws_iam_user" "dropshare_user" {
  name = "dropshare"

  tags = {
    Environment = "dropshare"
  }
}

resource "aws_iam_user_policy" "dropshare_origin_access" {
  name = "test"
  user = aws_iam_user.dropshare_user.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${module.cloudfront-s3-cdn.s3_bucket}/*",
                "arn:aws:s3:::${module.cloudfront-s3-cdn.s3_bucket}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_access_key" "dropshare_user" {
  user = aws_iam_user.dropshare_user.name
}

output "bucket_name" {
  value = module.cloudfront-s3-cdn.s3_bucket
}

output "aws_access_key_id" {
  value = aws_iam_access_key.dropshare_user.id
}

output "aws_secret_access_key" {
  value = aws_iam_access_key.dropshare_user.secret
}

output "region" {
  value = "us-east-1 (N. Virginia)"
}

output "domain_alias" {
  value = module.cloudfront-s3-cdn.aliases.0
}

