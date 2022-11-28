
/*
 * File: DEVOPS.md
 * Project: smartech-infra
 * Created Date: Saturday September 14th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Saturday September 14th 2019 3:45:18 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */


<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents** 

- [Devops Perspective](#devops-perspective)
  - [IaC (Infrastructure-as-Code)](#iac-infrastructure-as-code)
  - [CI/CD](#cicd)
  - [FAQ](#faq)
    - [SIT Environment under infra](#sit-environment-under-infra)
    - [SVC Environment](#svc-environment)
  - [Important links to terraform setup](#important-links-to-terraform-setup)
  - [Configure AWS CLI](#configure-aws-cli)
    - [Install PIP on local machine](#install-pip-on-local-machine)
    - [Install AWS CLI on local machine](#install-aws-cli-on-local-machine)
    - [Configure AWS CLI on local machine](#configure-aws-cli-on-local-machine)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# Devops Perspective

There are two main components that combinine together to make the automation wholesome.

## IaC (Infrastructure-as-Code)

 1. The IaC templates are implemetned using [Terraform](https://www.terraform.io/) (TF).
 2. The TF templates are grouped together in a folder called `tf-templates`.
 3. The IaC is a combination of two sets of Infrastructures.
 
      a. [Service Environment](tf-templates/svc/README.md) aka `svc`.
      
      b. [Infrastructure Environment](tf-templates/infra/README.md) aka `infra`.

## CI/CD

 1. The CI/CD component is implemented with the help of a Jenkins ec2 server.
 2. The Jenkins server is implemented through a [Service Environment](tf-templates/svc/README.md) (`svc`) under IaC.
 3. The Jenkins server implements required resources with help of Jenkins slave nodes.
 4. The Jenkins slave nodes do the actual work to process the requests in order accomplish a task.
 5. The Jenkins groovy scripts populate the required jenkins jobs.
 6. [More information](../common/README.md)
 

## FAQ

### SIT Environment under infra

  Q: What are the common precautions before creating a new `SIT` environment?
  
  A:

  Q: How do I create a new `SIT` environment under `infra`?
  
  A:

  Q: How do I update an existing `SIT` environment under `infra`?
  
  A:

  Q: How do I delete an existing `SIT` environment under `infra`?
  
  A:

  Q: What are the common precautions while deleting an existing `SIT` environment?
  
  A:

  Q: What are common ways to debug issues in `SIT` environment modifications?

  A:

### SVC Environment

  Q: How do I create a new `svc` environment?
  
  A: 

  Q: How do I update a existing `svc` environment?
  
  A:

  Q: How do I delete an existing `svc` environment?
  
  A:

  Q: What are common ways to debug issues in `svc` environment modifications?

  A:

## Important links to terraform setup

   1. [Install Terraform](https://www.terraform.io/intro/getting-started/install.html)
   2. [Configure Provider](https://www.terraform.io/docs/providers/)
   3. [Configure State](https://www.terraform.io/docs/state/index.html)
   4. [Configure Workspace](https://www.terraform.io/docs/state/workspaces.html)
   5. [Configure Backend](https://www.terraform.io/docs/backends/index.html)
   6. [Configure Modules](https://www.terraform.io/docs/modules/index.html)

## Configure AWS CLI

### Install PIP on local machine
   
   [Install Linux](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install-linux.html)
   
   [Install Mac](https://pip.pypa.io/en/stable/installing/)
      `brew install python3`

### Configure AWS CLI on local machine

   1. [Create an IAM user on your AWS Account (if it doesn't exist already)](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)

   2. [Add user to proper IAM group](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_groups_manage_add-remove-users.html)
   
   3. [Add IAM policy to IAM group](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_groups_manage_attach-policy.html)

   4. [Install AWS CLI as mentioned above](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)

   5. [Configure awscli on local machine using awscli profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html)

   6. Test awscli on local machine
      
      `$ aws ec2 describe-instances --profile user2`
  