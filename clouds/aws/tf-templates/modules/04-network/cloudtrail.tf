/*
 * File: cloudtrail.tf
 * Project: 04-network
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:30:50 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




resource "aws_cloudtrail" "all-region-cloudtrail" {
    name                       = "smarttech-cloudtrail"
    s3_key_prefix              = "all-regions"
    s3_bucket_name             = var.cloudtrail_bucket
    is_multi_region_trail      = true

    tags   = merge(
                var.tags,
                map(
                    "Name", "account-cloudtrail-all-regions",
                )
             )
}
