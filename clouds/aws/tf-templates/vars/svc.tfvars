/*
 * File: svc.tfvars
 * Project: vars
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:25:49 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




aws_region        = "ap-south-1"
aws_backup_region = "us-east-1"

cloudtrail_bucket               = "smarttech-cloudtrail"
deploy_bucket                   = "smartech-deploy"
deploy_artifact_expiration      = "30"
devops_bucket_backup_expiration = "10"
logs_bucket                     = "smartech-alb-logs*"
cloudtrail_log_expiration       = "90"
vpc_cidr                        = "10.75.0.0/16"
availability_zone_index         = 0
flowlog_retention_in_days       = "3"
private_subnet0_cidr            = "10.75.0.0/24"
public_subnet0_cidr             = "10.75.1.0/24"
private_gateway_ip              = "10.75.0.1"
public_gateway_ip               = "10.75.1.1"
customer_gateway_ip             = "59.163.11.66"
internal_domain_name            = "smt.internal"

office_private_cidr         = ["192.168.0.0/16"]
office_public_cidr          = ["0.0.0.0/0"]
tmp_cidr                    = ["0.0.0.0/0"]

asg_startup_cron            = "00 09 * * 1-5" # cron format, weekdays 14:30 in IST
asg_shutdown_cron           = "30 17 * * *"   # cron format, daily 02:30 in IST

nat_base_vol_size                   = 8
nat_min_count                       = 0
nat_desired_count                   = 1
nat_max_count                       = 1
nat_private_ip                      = "10.75.1.15"
nat_keypair                         = "svc-nat"
nat_base_capacity                   = 0
nat_per_above_base_capacity         = 0
nat_scheduled_actions_enabled       = true

openvpn_base_vol_size                   = 8
openvpn_ami_id                          = "ami-0be23bab5e416bce2"
openvpn_min_count                       = 0
openvpn_desired_count                   = 1
openvpn_max_count                       = 1
openvpn_private_ip                      = "10.75.1.20"
openvpn_gateway_ip                      = "10.75.1.1"
openvpn_keypair                         = "svc-openvpn"
openvpn_base_capacity                   = 0
openvpn_per_above_base_capacity         = 0
openvpn_scheduled_actions_enabled       = true

ssh_base_vol_size                   = 8
ssh_min_count                       = 0
ssh_desired_count                   = 1
ssh_max_count                       = 1
ssh_private_ip                      = "10.75.1.25"
ssh_keypair                         = "svc-ssh"
ssh_base_capacity                   = 0
ssh_per_above_base_capacity         = 0
ssh_scheduled_actions_enabled       = true

jenkins_base_vol_size                   = 20
jenkins_ami_id                          = "ami-0b0c776c3ccdd40f3"
jenkins_min_count                       = 0
jenkins_desired_count                   = 0
jenkins_max_count                       = 1
jenkins_keypair                         = "svc-jenkins"
jenkins_base_capacity                   = 0
jenkins_per_above_base_capacity         = 0
jenkins_private_ip                      = "10.75.0.150"
jenkins_scheduled_actions_enabled       = true

worker_default_ami_id                          = "ami-0b39a562dbec36d96"
worker_default_base_vol_size                   = 20
worker_default_keypair                         = "svc-jenkins"
worker_default_sit_env                         = "sit0"
worker_default_min_count                       = 0
worker_default_desired_count                   = 1
worker_default_max_count                       = 1
worker_default_base_capacity                   = 0
worker_default_per_above_base_capacity         = 0
worker_default_home_dir                        = "/home/centos"
worker_default_executor_count                  = "3"
worker_default_credentials_id                  = "worker-ssh-private-key"
worker_default_ssh_user                        = "centos"
worker_default_ssh_group                       = "centos"
worker_default_ssh_port                        = "22"
worker_default_scheduled_actions_enabled       = true

worker_sit_env = {
    sit0 = {
        worker_base_vol_size                   = 20,
        worker_ami_id                          = "ami-0b39a562dbec36d96",
        worker_desired_count                   = "0",
        worker_max_count                       = "1",
        worker_min_count                       = "0",
        worker_base_capacity                   = "0",
        worker_keypair                         = "svc-jenkins",
        worker_per_above_base_capacity         = "0",
        worker_home_dir                        = "/home/centos",
        worker_executor_count                  = "3"
        worker_credentials_id                  = "worker-ssh-private-key",
        worker_ssh_user                        = "centos",
        worker_ssh_group                       = "centos",
        worker_ssh_port                        = "22"
    },
    sit1 = {
        worker_base_vol_size             = 20,
        worker_ami_id                    = "ami-0b39a562dbec36d96",
        worker_desired_count             = "0",
        worker_max_count                 = "1",
        worker_min_count                 = "0",
        worker_base_capacity             = "0",
        worker_keypair                   = "svc-jenkins",
        worker_per_above_base_capacity   = "0",
        worker_home_dir                  = "/home/centos",
        worker_executor_count            = "3"
        worker_credentials_id            = "worker-ssh-private-key",
        worker_ssh_user                  = "centos",
        worker_ssh_group                 = "centos",
        worker_ssh_port                  = "22"
    },
    sit2 = {
        worker_base_vol_size             = 20,
        worker_ami_id                    = "ami-0b39a562dbec36d96",
        worker_desired_count             = "0",
        worker_max_count                 = "1",
        worker_min_count                 = "0",
        worker_base_capacity             = "0",
        worker_keypair                   = "svc-jenkins",
        worker_per_above_base_capacity   = "0",
        worker_home_dir                  = "/home/centos",
        worker_executor_count            = "3"
        worker_credentials_id            = "worker-ssh-private-key",
        worker_ssh_user                  = "centos",
        worker_ssh_group                 = "centos",
        worker_ssh_port                  = "22"
    },
    pit0 = {
        worker_base_vol_size             = 20,
        worker_ami_id                    = "ami-0b39a562dbec36d96",
        worker_desired_count             = "0",
        worker_max_count                 = "1",
        worker_min_count                 = "0",
        worker_base_capacity             = "0",
        worker_keypair                   = "svc-jenkins",
        worker_per_above_base_capacity   = "0",
        worker_home_dir                  = "/home/centos",
        worker_executor_count            = "3"
        worker_credentials_id            = "worker-ssh-private-key",
        worker_ssh_user                  = "centos",
        worker_ssh_group                 = "centos",
        worker_ssh_port                  = "22"
    },
    prodeu = {
        worker_base_vol_size             = 20,
        worker_ami_id                    = "ami-0b39a562dbec36d96",
        worker_desired_count             = "0",
        worker_max_count                 = "1",
        worker_min_count                 = "0",
        worker_base_capacity             = "0",
        worker_keypair                   = "svc-jenkins",
        worker_per_above_base_capacity   = "0",
        worker_home_dir                  = "/home/centos",
        worker_executor_count            = "3"
        worker_credentials_id            = "worker-ssh-private-key",
        worker_ssh_user                  = "centos",
        worker_ssh_group                 = "centos",
        worker_ssh_port                  = "22"
    },
    eu = {
        worker_base_vol_size             = 20,
        worker_ami_id                    = "ami-0b39a562dbec36d96",
        worker_desired_count             = "0",
        worker_max_count                 = "1",
        worker_min_count                 = "0",
        worker_base_capacity             = "0",
        worker_keypair                   = "svc-jenkins",
        worker_per_above_base_capacity   = "0",
        worker_home_dir                  = "/home/centos",
        worker_executor_count            = "3"
        worker_credentials_id            = "worker-ssh-private-key",
        worker_ssh_user                  = "centos",
        worker_ssh_group                 = "centos",
        worker_ssh_port                  = "22"
    }
}