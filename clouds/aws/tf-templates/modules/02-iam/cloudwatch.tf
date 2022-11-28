/*
 * File: cloudwatch.tf
 * Project: 02-iam
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:33:40 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




data "aws_iam_policy_document" "events-invoke-lambda-policy-doc" {
  statement {
    sid       = "AllowEventsToInvokeLambda"
    actions   = [
        "lambda:InvokeFunction"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy" "events-invoke-lambda-role-policy" {
  name   = "${var.env}-iam-group-mod-target-role-policy"
  role   = aws_iam_role.iam-group-mod-target-role.id
  policy = data.aws_iam_policy_document.events-invoke-lambda-policy-doc.json
}

resource "aws_iam_role" "iam-group-mod-target-role" {
  name               = "${var.env}-iam-group-mod-target-role"
  path               = "/"
  description        = "Provides IAM permissions for Cloudwatch events service to invoke lambda under ${var.env} environment"
  assume_role_policy = data.aws_iam_policy_document.events-service-trust-policy-doc.json
}
