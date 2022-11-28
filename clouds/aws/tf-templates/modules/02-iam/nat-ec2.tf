/*
 * File: nat-ec2.tf
 * Project: 02-iam
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:13:36 am
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




data "aws_iam_policy" "nat-ec2-ssm" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "aws_iam_policy_document" "nat-role-policy" {
  statement {
    sid       = "AllowEC2DescribeModifyAttrib"
    actions   = [
        "ec2:AssociateAddress",
        "ec2:DescribeAddresses",
        "ec2:ModifyInstanceAttribute",
        "ec2:AttachNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DetachNetworkInterface",
        "ec2:Describe*",
        "ec2:CreateTags",
        "ec2:ReplaceRoute",
        "ec2:DeleteRoute",
        "ec2:CreateRoute",
        "ec2:ModifyInstanceCreditSpecification"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

}

resource "aws_iam_role" "nat-role" {
  name               = "${var.env}-nat-role"
  path               = "/"
  description        = "Provides IAM permissions for ${var.env} Env NAT instance"
  assume_role_policy = data.aws_iam_policy_document.ec2-service-trust-policy-doc.json
}

resource "aws_iam_instance_profile" "nat-instance-profile" {
  name = "${var.env}-nat-instance-profile"
  role = aws_iam_role.nat-role.name
  path = "/"
}

resource "aws_iam_role_policy" "nat-role-policy" {
  name   = "${var.env}-nat-role-policy"
  role   = aws_iam_role.nat-role.id
  policy = data.aws_iam_policy_document.nat-role-policy.json
}
