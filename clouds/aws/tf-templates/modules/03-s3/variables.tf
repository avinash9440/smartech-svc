/*
 * File: variables.tf
 * Project: 03-s3
 * Created Date: Wednesday June 26th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Wednesday June 26th 2019 7:46:18 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */


variable "devops_bucket_bkup_region" {}
variable "deploy_bucket" {}
variable "deploy_artifact_expiration" {}
variable "devops_bucket_backup_expiration" {}
variable "devops_bucket" {}
variable "cloudtrail_bucket" {}
variable "cloudtrail_log_expiration" {}
variable "env" {}
variable "tags" {type = map}
