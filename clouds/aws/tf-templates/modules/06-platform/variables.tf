/*
 * File: variables.tf
 * Project: 06-platform
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:29:05 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




variable "env" {}
variable "devops_bucket" {}
variable "aws_region" {}
variable "tags" {}
variable "asg_startup_cron" {}
variable "asg_shutdown_cron" {}

variable "vpc_id" {}
variable "public_subnet0_id" {}
variable "private_subnet0_id" {}
variable "igw_id" {}

variable "vpc_cidr" {}
variable "private_subnet0_cidr" {}
variable "public_subnet0_cidr" {}
variable "office_public_cidr" {}
variable "private_gateway_ip" {}
variable "public_gateway_ip" {}
variable "internal_zone_id" {}
variable "ssh_sg" {}

variable "jenkins_base_vol_size" {}
variable "jenkins_ami_id" {}
variable "jenkins_desired_count" {}
variable "jenkins_max_count" {}
variable "jenkins_min_count" {}
variable "jenkins_keypair" {}
variable "jenkins_base_capacity" {}
variable "jenkins_per_above_base_capacity" {}
variable "jenkins_instance_profile" {}
variable "jenkins_private_ip" {}
variable "jenkins_scheduled_actions_enabled" {type=bool}

variable "worker_default_sit_env" {}
variable "worker_default_base_vol_size" {}
variable "worker_default_ami_id" {}
variable "worker_default_desired_count" {}
variable "worker_default_max_count" {}
variable "worker_default_min_count" {}
variable "worker_default_keypair" {}
variable "worker_default_base_capacity" {}
variable "worker_default_per_above_base_capacity" {}
variable "worker_default_home_dir" {}
variable "worker_default_executor_count" {}
variable "worker_default_credentials_id" {}
variable "worker_default_ssh_user" {}
variable "worker_default_ssh_group" {}
variable "worker_default_ssh_port" {}
variable "worker_default_scheduled_actions_enabled" {type=bool}

variable "worker_instance_profile" {}
variable "worker_sit_env" {
    type = map(object({
        worker_base_vol_size             = string,
        worker_ami_id                    = string,
        worker_desired_count             = string,
        worker_max_count                 = string,
        worker_min_count                 = string,
        worker_base_capacity             = string,
        worker_keypair                   = string,
        worker_per_above_base_capacity   = string,
        worker_home_dir                  = string,
        worker_executor_count            = string,
        worker_credentials_id            = string,
        worker_ssh_user                  = string,
        worker_ssh_group                 = string,
        worker_ssh_port                  = string
    }))
    
    default =  { 
        sit0 = {
            worker_base_vol_size             = "8"
            worker_ami_id                    = "ami-02e60be79e78fef21",
            worker_desired_count             = "1",
            worker_max_count                 = "1",
            worker_min_count                 = "0",
            worker_base_capacity             = "0",
            worker_keypair                   = "svc-jenkins",
            worker_per_above_base_capacity   = "0",
            worker_home_dir                  = "/home/centos",
            worker_executor_count            = "3",
            worker_credentials_id            = "worker-ssh-private-key",
            worker_ssh_user                  = "centos",
            worker_ssh_group                 = "centos",
            worker_ssh_port                  = "22"
       }
    }    
}