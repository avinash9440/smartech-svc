/*
 * File: generic-trust-policy.tf
 * Project: 02-iam
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:33:52 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




// Generic AWS Service Trust policy documents

data "aws_iam_policy_document" "flowlog-service-trust-policy-doc" {
  statement {
    effect        = "Allow"    
    actions       = [
        "sts:AssumeRole"
    ]
    principals    {
      type        = "Service"
      identifiers = [
        "vpc-flow-logs.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "ec2-service-trust-policy-doc" {
  statement {
    effect        = "Allow"    
    actions       = [
        "sts:AssumeRole"
    ]
    principals    {
      type        = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "lambda-service-trust-policy-doc" {
  statement {
    effect        = "Allow"    
    actions       = [
        "sts:AssumeRole"
    ]
    principals    {
      type        = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "events-service-trust-policy-doc" {
  statement {
    effect        = "Allow"    
    actions       = [
        "sts:AssumeRole"
    ]
    principals    {
      type        = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail-service-trust-policy-doc" {
  statement {
    effect        = "Allow"    
    actions       = [
        "sts:AssumeRole"
    ]
    principals    {
      type        = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
  }
}