/*
 * File: ssh-jumpbox-ec2.tf
 * Project: 02-iam
 * Created Date: Wednesday June 26th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Wednesday June 26th 2019 6:50:11 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




# =========================
# ssh jumpbox IAM resources
# =========================

data "aws_iam_policy" "ssh-jumpbox-ec2-ssm" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "aws_iam_policy" "ssh-jumpbox-ec2-iamreadonly" {
  arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}

data "aws_iam_policy_document" "ssh-jumpbox-role-policy" {
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
        "s3:PutObjectAcl"
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
    sid       = "AllowLogGroupCreateAndPut"
    actions   = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
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

resource "aws_iam_role" "ssh-jumpbox-role" {
  name               = "${var.env}-ssh-jumpbox-role"
  path               = "/${var.env}/"
  description        = "Provides IAM permissions for ${var.env} Env SSH Jumpbox"
  assume_role_policy = data.aws_iam_policy_document.ec2-service-trust-policy-doc.json
}

resource "aws_iam_instance_profile" "ssh-jumpbox-instance-profile" {
  name = "${var.env}-ssh-jumpbox-instance-profile"
  role = aws_iam_role.ssh-jumpbox-role.name
  path = "/${var.env}/"
}

resource "aws_iam_role_policy" "ssh-jumpbox-role-policy" {
  name   = "${var.env}-ssh-jumpbox-role-policy"
  role   = aws_iam_role.ssh-jumpbox-role.id
  policy = data.aws_iam_policy_document.ssh-jumpbox-role-policy.json
}

resource "aws_iam_role_policy_attachment" "ssh-jumpbox-role-policy-attach" {
  role = aws_iam_role.ssh-jumpbox-role.name
  policy_arn = data.aws_iam_policy.ssh-jumpbox-ec2-ssm.arn
}

resource "aws_iam_role_policy_attachment" "ssh-jumpbox-role-policy-iamreadonly-attach" {
  role = aws_iam_role.ssh-jumpbox-role.name
  policy_arn = data.aws_iam_policy.ssh-jumpbox-ec2-iamreadonly.arn
}
