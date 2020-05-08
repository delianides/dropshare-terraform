Dropshare Terraform
=====

Sets up an S3 backup Cloudfront CDN to upload Dropshare files too. It also sets
up Rebrandly for shortlinks.

## How to Use?

- This assumes you already have purchased a [Domain](https://hover.com/7uVsQHvc)
to use.
- Make sure you've installed [Terraform](https://learn.hashicorp.com/terraform/getting-started/install)
- Install and configure the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

1. Create or log in to your AWS account.
2. Create a Route53 hosted zone for your domain and update the nameservers in
   your [domain](https://hover.com/7uVsQHvc). Its important to have the domain
   already setup as it makes generating a ACM certificate automatic during the
   process.
3. Run `terraform init`; This downloads the module and AWS provider.
4. (Optional) You can run `terraform plan` to test and make sure everything
   looks good.
5. Run `terraform apply` and enter the domain you previously setup.
6. The run should end after a few minutes and output the domain and IAM keys to
   use in Dropshare (Do not use root credentials)
7. Use those credentials to create a [connection](https://dropshare.zendesk.com/hc/en-us/articles/115003135729-How-to-set-up-Amazon-S3) in Dropshare.


## Thanks

[CloudPosse](https://github.com/cloudposse/terraform-aws-cloudfront-s3-cdn)

