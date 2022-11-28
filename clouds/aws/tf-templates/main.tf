/*
 * File: main.tf
 * Project: svc
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:28:02 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




terraform {
  required_version = "0.12.23"

###########IMPORTANT###############
# Below mentioned resources are manually created.
# S3 Bucket     : smartech-infra-tf, versioning enabled.
# IAM Policy    : arn:aws:iam::XXXXXXXXXXX:policy/terraform-dynamodb-lock-policy,
#                 to be used for any non-admin IAM user/role/group who might want to modify terraform infra.
#                 Can be reused for other infra in same AWS account.
# Dynamodb table: svc-terraform-state-lock with LockID String key
###################################

  backend "s3" {
    region         = "ap-south-1"
    bucket         = "smartech-infra-tf"
    key            = "tfstate/aws/svc/svc.tfstate"
    encrypt        = true
    dynamodb_table = "svc-terraform-state-lock"
  }
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.0"
}

provider "template" {
  version = "~> 2.1"
}

locals {
  owner                = "Ashay Chitnis"
  project              = "smarttech-infra"
  region               = "ap-south-1"
  env                  = "svc"
  devops_bucket        = "smartech-devops"
  backup_devops_bucket = "smartech-devops-bkup"

  common_tags = {
    Project   = local.project
    Env       = local.env
    Region    = local.region
  }
}

module "kms" {
  source = "git::https://corporate.netcore.co.in/gitbucket/git/Iac/smartech-svc.git//clouds/aws/tf-templates/modules/01-kms"
  env    = local.env
  tags   = local.common_tags
}

module "iam" {
  source = "git::https://corporate.netcore.co.in/gitbucket/git/Iac/smartech-svc.git//clouds/aws/tf-templates/modules/02-iam"

  env           = local.env
  devops_bucket = local.devops_bucket
  logs_bucket   = var.logs_bucket
  deploy_bucket = var.deploy_bucket
}

module "s3" {
  source = "git::https://corporate.netcore.co.in/gitbucket/git/Iac/smartech-svc.git//clouds/aws/tf-templates/modules/03-s3"

  env                             = local.env
  devops_bucket_bkup_region       = var.aws_backup_region
  devops_bucket                   = local.devops_bucket
  deploy_bucket                   = var.deploy_bucket
  deploy_artifact_expiration      = var.deploy_artifact_expiration
  devops_bucket_backup_expiration = var.devops_bucket_backup_expiration
  cloudtrail_bucket               = var.cloudtrail_bucket
  cloudtrail_log_expiration       = var.cloudtrail_log_expiration
  tags                            = local.common_tags
}

module "network" {
  source = "git::https://corporate.netcore.co.in/gitbucket/git/Iac/smartech-svc.git//clouds/aws/tf-templates/modules/04-network"

  env                       = local.env
  devops_bucket             = local.devops_bucket
  devops_bucket_region      = local.region
  devops_bucket_bkup        = local.backup_devops_bucket
  devops_bucket_bkup_region = "us-east-1"

  aws_region        = local.region
  tags              = local.common_tags
  
  asg_startup_cron  = var.asg_startup_cron
  asg_shutdown_cron = var.asg_shutdown_cron

  vpc_cidr                    = var.vpc_cidr
  availability_zone_index     = var.availability_zone_index
  cloudtrail_bucket           = var.cloudtrail_bucket
  flowlog_retention_in_days   = var.flowlog_retention_in_days
  iam_flowlog_role            = module.iam.vpc-flowlog-role-arn
  private_subnet0_cidr        = var.private_subnet0_cidr
  public_subnet0_cidr         = var.public_subnet0_cidr
  public_gateway_ip           = var.public_gateway_ip

  internal_domain_name        = var.internal_domain_name
  customer_gateway_ip         = var.customer_gateway_ip
  office_private_cidr         = var.office_private_cidr
  office_public_cidr          = concat(var.office_public_cidr, var.tmp_cidr)

  nat_base_vol_size             = var.nat_base_vol_size
  nat_max_count                 = var.nat_max_count
  nat_min_count                 = var.nat_min_count
  nat_desired_count             = var.nat_desired_count
  nat_private_ip                = var.nat_private_ip
  nat_keypair                   = var.nat_keypair
  nat_base_capacity             = var.nat_base_capacity
  nat_per_above_base_capacity   = var.nat_per_above_base_capacity
  nat_instance_profile          = module.iam.nat-instance-profile-name
  nat_scheduled_actions_enabled = var.nat_scheduled_actions_enabled

  openvpn_base_vol_size             = var.openvpn_base_vol_size
  openvpn_ami_id                    = var.openvpn_ami_id
  openvpn_max_count                 = var.openvpn_max_count
  openvpn_min_count                 = var.openvpn_min_count
  openvpn_desired_count             = var.openvpn_desired_count
  openvpn_private_ip                = var.openvpn_private_ip
  openvpn_gateway_ip                = var.openvpn_gateway_ip
  openvpn_keypair                   = var.openvpn_keypair
  openvpn_base_capacity             = var.openvpn_base_capacity
  openvpn_per_above_base_capacity   = var.openvpn_per_above_base_capacity
  openvpn_instance_profile          = module.iam.openvpn-instance-profile-name
  openvpn_scheduled_actions_enabled = var.openvpn_scheduled_actions_enabled  

  ssh_base_vol_size             = var.ssh_base_vol_size
  ssh_max_count                 = var.ssh_max_count
  ssh_min_count                 = var.ssh_min_count
  ssh_desired_count             = var.ssh_desired_count
  ssh_private_ip                = var.ssh_private_ip
  ssh_keypair                   = var.ssh_keypair
  ssh_base_capacity             = var.ssh_base_capacity
  ssh_per_above_base_capacity   = var.ssh_per_above_base_capacity
  ssh_instance_profile          = module.iam.ssh-jumpbox-instance-profile-name
  ssh_scheduled_actions_enabled = var.ssh_scheduled_actions_enabled
}

module "ssm" {
  source = "git::https://corporate.netcore.co.in/gitbucket/git/Iac/smartech-svc.git//clouds/aws/tf-templates/modules/05-ssm"
}

module "platform" {
  source = "git::https://corporate.netcore.co.in/gitbucket/git/Iac/smartech-svc.git//clouds/aws/tf-templates/modules/06-platform"

  env               = local.env
  devops_bucket     = local.devops_bucket
  aws_region        = local.region
  tags              = local.common_tags
  asg_startup_cron  = var.asg_startup_cron
  asg_shutdown_cron = var.asg_shutdown_cron

  vpc_id             = module.network.svc-vpc-id
  public_subnet0_id  = module.network.svc-public-subnet0-id
  private_subnet0_id = module.network.svc-private-subnet0-id
  igw_id             = module.network.svc-igw-id

  vpc_cidr             = var.vpc_cidr
  private_subnet0_cidr = var.private_subnet0_cidr
  public_subnet0_cidr  = var.public_subnet0_cidr
  private_gateway_ip   = var.private_gateway_ip
  public_gateway_ip    = var.public_gateway_ip
  office_public_cidr   = concat(var.office_public_cidr, var.tmp_cidr)
  internal_zone_id     = module.network.svc-r53-zone
  ssh_sg               = module.network.ssh-sg-id

  jenkins_base_vol_size             = var.jenkins_base_vol_size
  jenkins_ami_id                    = var.jenkins_ami_id
  jenkins_max_count                 = var.jenkins_max_count
  jenkins_min_count                 = var.jenkins_min_count
  jenkins_desired_count             = var.jenkins_desired_count
  jenkins_keypair                   = var.jenkins_keypair
  jenkins_base_capacity             = var.jenkins_base_capacity
  jenkins_per_above_base_capacity   = var.jenkins_per_above_base_capacity
  jenkins_private_ip                = var.jenkins_private_ip
  jenkins_instance_profile          = module.iam.jenkins-instance-profile-name
  jenkins_scheduled_actions_enabled = var.jenkins_scheduled_actions_enabled

  worker_default_base_vol_size             = var.worker_default_base_vol_size
  worker_default_sit_env                   = var.worker_default_sit_env
  worker_default_ami_id                    = var.worker_default_ami_id
  worker_default_max_count                 = var.worker_default_max_count
  worker_default_min_count                 = var.worker_default_min_count
  worker_default_desired_count             = var.worker_default_desired_count
  worker_default_keypair                   = var.worker_default_keypair
  worker_default_base_capacity             = var.worker_default_base_capacity
  worker_default_per_above_base_capacity   = var.worker_default_per_above_base_capacity
  worker_default_home_dir                  = var.worker_default_home_dir
  worker_default_executor_count            = var.worker_default_executor_count
  worker_default_credentials_id            = var.worker_default_credentials_id
  worker_default_ssh_user                  = var.worker_default_ssh_user
  worker_default_ssh_group                 = var.worker_default_ssh_group
  worker_default_ssh_port                  = var.worker_default_ssh_port
  worker_default_scheduled_actions_enabled = var.worker_default_scheduled_actions_enabled

  worker_instance_profile        = module.iam.jenkins-instance-profile-name
  worker_sit_env                 = var.worker_sit_env
  
}

