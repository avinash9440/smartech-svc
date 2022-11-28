/*
 * File: README.md
 * Project: smartech-infra
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:37:17 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
  
 */




<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [smartech-infra](#smartech-infra)
  - [Documentation Perspective](#documentation-perspective)
    - [Devops Perspective](#devops-perspective)
    - [Developer Perspective](#developer-perspective)
  - [Repository folder structure](#repository-folder-structure)
    - [Clouds](#clouds)
      - [AWS](#aws)
    - [Jenkins Automation](#jenkins-automation)
      - [Jenkins AWS Automation](#jenkins-aws-automation)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# smartech-infra 

This repository contains the Cloud infra structure for Netcore's smartech

## Documentation Perspective

### Devops Perspective

   [Devops Perspective](aws/DEVOPS.md)

### Developer Perspective

   [Developers Perspective](aws/DEVELOPERS.md)


## Repository folder structure

            ```
            .
            ├── alibaba
            │   ├── common
            │   ├── README.md
            │   └── tf-templates
            │       ├── common
            │       └── infra
            ├── aws
            │   ├── README.md
            │   └── tf-templates
            │       ├── common
            │       ├── infra
            │       └── svc
            ├── common
            │   └── jenkins
            │       └── aws
            ├── gce
            │   ├── common
            │   ├── README.md
            │   └── tf-templates
            │       ├── common
            │       └── infra
            └── README.md

            ```
   
   View of `smartech-infra` folder structure

### Clouds

The repository is created to incorporate Infrastructure-as-Code (IaC) for multiple clouds.

#### AWS

        ```
        aws
        ├── README.md
        └── tf-templates
            ├── common
            ├── infra
            │   ├── components.md
            │   ├── crash.log
            │   ├── main.tf
            │   ├── modules
            │   ├── outputs.tf
            │   ├── png
            │   ├── variables-database.tf
            │   ├── variables-generic.tf
            │   ├── variables-platform.tf
            │   ├── variables.tf
            │   └── vars
            └── svc
                ├── main.tf
                ├── modules
                ├── outputs.tf
                ├── README.md
                ├── variables.tf
                └── vars
        ```

   View of `aws` folder structure

   1. The [Terraform](https://www.terraform.io/) (TF) IaC code is stored in above folder structure.
   2. It contains `tf-templates` folder that contains two or more (svc, infra) TF infrastructures.
   3. TF infrastrcutures such as svc or infra maintain their own TF state configuration.

### Jenkins Automation


        ```
        common/
        └── jenkins
            └── aws

        ```
       
   View of `common` folder structure containing per cloud (aws) Jenkins jobs' code-base

#### Jenkins AWS Automation

        ```
        aws
        └── seed-job
            ├── cleanup_nodes.groovy
            ├── config
            │   ├── sit0.yaml
            │   ├── sit1.yaml
            │   └── sit2.yaml
            ├── job.groovy
            ├── pipeline
            │   ├── app.jenkinsfile
            │   └── infra.jenkinsfile
            └── view.groovy
        ```
   View of `aws` folder structure containing aws specific jenkins jobs' code-base 

   1. The seed-job has three main jobs (job,view and cleanup_nodes) groovy scripts that bootstrap jenkins jobs.
   2. `config` folder contains configuration based on which Jenkins jobs are populated.
   3. `pipeline` folder contains all the scripted [jenkinsfile](https://jenkins.io/doc/book/pipeline/jenkinsfile/) pipelines.

