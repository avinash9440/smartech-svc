/*
 * File: vpc-flowlogs.tf
 * Project: 02-iam
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:34:47 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




# =====================
# Vpc flowlog resources
# =====================

data "aws_iam_policy_document" "vpc-flowlog-role-policy-doc" {
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

resource "aws_iam_role" "vpc-flowlog-role" {
  name               = "${var.env}-vpc-flowlog-role"
  path               = "/${var.env}/"
  description        = "Provides IAM permissions for ${var.env} Flowlog role"
  assume_role_policy = data.aws_iam_policy_document.flowlog-service-trust-policy-doc.json
}

resource "aws_iam_role_policy" "vpc-flowlog-role-policy" {
  name   = "${var.env}-vpc-flowlog-role-policy"
  role   = aws_iam_role.vpc-flowlog-role.id
  policy = data.aws_iam_policy_document.vpc-flowlog-role-policy-doc.json
}