/*
 * File: jenkins-ec2.tf
 * Project: 02-iam
 * Created Date: Wednesday June 26th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Wednesday June 26th 2019 6:49:59 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




# =========================
# jenkins IAM resources
# =========================

#===============IMPORTANT========================================
# Be extremely careful while giving SSH or other accesses
# to Jenkins server or its Workers as this server has Admin
# level permissions on most of the AWS resources
# which if compromised can give uncontrolled access of AWS account
# to the user
#===============IMPORTANT========================================

data "aws_iam_policy" "jenkins-ec2-ssm" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "aws_iam_policy" "jenkins-ec2-iamreadonly" {
  arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}

data "aws_iam_policy_document" "jenkins-role-policy" {
  statement {
    sid       = "AllowAllEC2"
    actions   = [
        "ec2:*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid       = "AllowAllAutoscaling"
    actions   = [
        "autoscaling:*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid       = "AllowAllS3"
    actions   = [
        "s3:*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid       = "AllowAllACM"
    actions   = [
        "acm:*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid       = "AllowAllALB"
    actions   = [
        "elasticloadbalancing:*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid       = "AllowAllLogs"
    actions   = [
        "logs:*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid       = "AllowAllCloudwatch"
    actions   = [
        "cloudwatch:*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid       = "ECRAuthBuildPush"
    actions   = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
    ]
    resources = ["*"]
    effect    = "Allow"
  }  

  statement {
    sid       = "AllowAllKMS"
    actions   = [
        "kms:*",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  
  statement {
    sid       = "AllowAllDynamodb"
    actions   = [
        "dynamodb:*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid       = "AllowAllIAM"
    actions   = [
        "iam:*",
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid       = "AllowAllRoute53"
    actions   = [
        "route53:*",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role" "jenkins-role" {
  name               = "${var.env}-jenkins-role"
  path               = "/"
  description        = "Provides IAM permissions for ${var.env} Env SSH Jumpbox"
  assume_role_policy = data.aws_iam_policy_document.ec2-service-trust-policy-doc.json
}

resource "aws_iam_instance_profile" "jenkins-instance-profile" {
  name = "${var.env}-jenkins-instance-profile"
  role = aws_iam_role.jenkins-role.name
  path = "/"
}

resource "aws_iam_role_policy" "jenkins-role-policy" {
  name   = "${var.env}-jenkins-role-policy"
  role   = aws_iam_role.jenkins-role.id
  policy = data.aws_iam_policy_document.jenkins-role-policy.json
}

resource "aws_iam_role_policy_attachment" "jenkins-role-policy-attach" {
  role = aws_iam_role.jenkins-role.name
  policy_arn = data.aws_iam_policy.jenkins-ec2-ssm.arn
}

resource "aws_iam_role_policy_attachment" "jenkins-role-policy-iamreadonly-attach" {
  role = aws_iam_role.jenkins-role.name
  policy_arn = data.aws_iam_policy.jenkins-ec2-iamreadonly.arn
}
