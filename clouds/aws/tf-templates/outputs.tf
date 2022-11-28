/*
 * File: outputs.tf
 * Project: svc
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:27:47 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




output "svc-vpc-id"{
    value = module.network.svc-vpc-id
}

output "svc-vpc-cidr"{
    value = module.network.svc-vpc-cidr
}

output "devops-bucket-name" {
    value = module.s3.devops-bucket-name
}

output "devops-bucket-region" {
    value = var.aws_region
}

output "backup-devops-bucket-name" {
    value = module.s3.backup-devops-bucket-name
}

output "cloudtrail-bucket-name" {
    value = module.s3.cloudtrail-bucket-name
}

output "deploy-bucket-name" {
    value = module.s3.deploy-bucket-name
}