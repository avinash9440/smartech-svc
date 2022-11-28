/*
 * File: outputs.tf
 * Project: 03-s3
 * Created Date: Wednesday June 26th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Wednesday June 26th 2019 8:13:30 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




output "devops-bucket-name" {
    value = aws_s3_bucket.devops-bucket.id
}

output "backup-devops-bucket-name" {
    value = aws_s3_bucket.devops-bucket-backup.id
}

output "cloudtrail-bucket-name" {
    value = aws_s3_bucket.cloudtrail-bucket.id
}

output "deploy-bucket-name" {
    value = aws_s3_bucket.deploy-bucket.id
}