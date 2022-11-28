/*
 * File: cloudtrail.tf
 * Project: 02-iam
 * Created Date: Wednesday June 26th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Wednesday June 26th 2019 6:46:17 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




data "aws_iam_policy_document" "cloudtrail-role-policy" {
  statement {
    sid       = "AllowCloutrailToLogIntoCloudwatchLogGroup"
    actions   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}


resource "aws_iam_role" "cloudtrail-role" {
  name               = "${var.env}-cloudtrail-role"
  path               = "/${var.env}/"
  description        = "Provides IAM permissions for ${var.env} For Cloudtrail to put logs to Cloudwatch"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail-service-trust-policy-doc.json
}

resource "aws_iam_role_policy" "cloudtrail-role-policy" {
  name   = "${var.env}-cloudtrail-role-policy"
  role   = aws_iam_role.cloudtrail-role.id
  policy = data.aws_iam_policy_document.cloudtrail-role-policy.json
}


data "aws_iam_policy_document" "cloudtrail-role-policy-doc" {
  statement {
    sid       = "AllowLogGroupCreate"
    actions   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}