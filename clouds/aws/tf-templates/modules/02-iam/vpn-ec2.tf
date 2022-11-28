/*
 * File: vpn-ec2.tf
 * Project: 02-iam
 * Created Date: Wednesday June 26th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Wednesday June 26th 2019 7:00:21 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




# ============================
# openvpn access IAM resources
# ============================

data "aws_iam_policy" "openvpn-ec2-ssm" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "aws_iam_policy_document" "openvpn-role-policy" {
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
        "ec2:ModifyInstanceCreditSpecification"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid       = "AllowS3AGetPutList"
    actions   = [
        "s3:GetBucketLocation",
        "s3:GetBucketAcl",
        "s3:GetObject",
        "s3:ListAllMyBuckets",
        "s3:ListBucket",
        "s3:ListBucketVersions",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:DeleteObject"
    ]
    resources = [
        "arn:aws:s3:::${var.devops_bucket}",
        "arn:aws:s3:::${var.devops_bucket}/common/*",
        "arn:aws:s3:::${var.devops_bucket}/aws/common/*",
        "arn:aws:s3:::${var.devops_bucket}/aws/svc/*",
    ]
    effect    = "Allow"
  }

  statement {
    sid       = "AllowKMSDecryptAccess"
    actions   = [
        "kms:List*",
        "kms:Decrypt"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

}

resource "aws_iam_role" "openvpn-role" {
  name               = "${var.env}-openvpn-role"
  path               = "/"
  description        = "Provides IAM permissions for ${var.env} Env Openvpn Access"
  assume_role_policy = data.aws_iam_policy_document.ec2-service-trust-policy-doc.json
}

resource "aws_iam_instance_profile" "openvpn-instance-profile" {
  name = "${var.env}-openvpn-instance-profile"
  role = aws_iam_role.openvpn-role.name
  path = "/"
}

resource "aws_iam_role_policy" "openvpn-role-policy" {
  name   = "${var.env}-openvpn-role-policy"
  role   = aws_iam_role.openvpn-role.id
  policy = data.aws_iam_policy_document.openvpn-role-policy.json
}

resource "aws_iam_role_policy_attachment" "openvpn-role-policy-attach" {
  role = aws_iam_role.openvpn-role.name
  policy_arn = data.aws_iam_policy.openvpn-ec2-ssm.arn
}

