/*
 * File: misc.tf
 * Project: 03-s3
 * Created Date: Saturday August 10th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Saturday August 10th 2019 12:04:41 am
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




provider "aws" {
  alias   = "ue1"
#  profile = "smartech"
  region  = var.devops_bucket_bkup_region
  version = "~> 2.0"
}

resource "aws_s3_bucket" "devops-bucket" {
    bucket    = var.devops_bucket
    acl       = "private"
    
    # Prevent devops bucket from accidental "terraform destroy"

    lifecycle {
        prevent_destroy = true
    }

    tags      = merge(
                    var.tags,
                    map(
                        "Name", var.devops_bucket,
                    )
                )
}

resource "aws_s3_bucket" "devops-bucket-backup" {
    provider  = aws.ue1
    bucket    = "${var.devops_bucket}-bkup"
    acl       = "private"
    
    # Prevent devops bucket from accidental "terraform destroy"

    lifecycle {
        prevent_destroy = true
    }

    lifecycle_rule {
        id      = "${var.devops_bucket}-bkup-lifecycle-expiration"
        enabled = true
        expiration {
             days = var.devops_bucket_backup_expiration
        }
    }

    tags      = merge(
                    var.tags,
                    map(
                        "Name", "${var.devops_bucket}-bkup",
                    )
                )
}

resource "aws_s3_bucket" "cloudtrail-bucket" {
    bucket    = var.cloudtrail_bucket
    tags      = merge(
                    var.tags,
                    map(
                        "Name", var.cloudtrail_bucket,
                    )
                )

    lifecycle     {
        prevent_destroy = true
    }
    lifecycle_rule {
        id      = "${var.cloudtrail_bucket}-logging-lifecycle-expiration"
        enabled = true
        expiration {
             days = var.cloudtrail_log_expiration
        }
    }
    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.cloudtrail_bucket}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.cloudtrail_bucket}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_s3_bucket" "deploy-bucket" {
    bucket    = var.deploy_bucket
    acl       = "private"
    
    # Prevent devops bucket from accidental "terraform destroy"

    lifecycle {
        prevent_destroy = true
    }
    
    lifecycle_rule {
        id      = "${var.deploy_bucket}-artifact-lifecycle-expiration"
        enabled = true
        expiration {
             days = var.deploy_artifact_expiration
        }
    }

    tags      = merge(
                    var.tags,
                    map(
                        "Name", var.deploy_bucket,
                    )
                )
}

resource "aws_s3_bucket_public_access_block" "block-public-access-devops-bucket" {
  bucket              = aws_s3_bucket.devops-bucket.id
  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_public_access_block" "block-public-access-devops-backup-bucket" {
  provider            = aws.ue1  
  bucket              = aws_s3_bucket.devops-bucket-backup.id
  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_public_access_block" "block-public-access-cloudtrail-bucket" {
  bucket              = aws_s3_bucket.cloudtrail-bucket.id
  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_public_access_block" "block-public-access-deploy-bucket" {
  bucket              = aws_s3_bucket.deploy-bucket.id
  block_public_acls   = true
  block_public_policy = true
}