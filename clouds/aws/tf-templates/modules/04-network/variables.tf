/*
 * File: variables.tf
 * Project: 04-network
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:32:10 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




variable "env" {}
variable "devops_bucket" {}
variable "devops_bucket_region" {}
variable "devops_bucket_bkup" {}
variable "devops_bucket_bkup_region" {}
variable "aws_region" {}
variable "tags" {}
variable "asg_startup_cron" {}
variable "asg_shutdown_cron" {}

variable "vpc_cidr" {}
variable "availability_zone_index" {}
variable "cloudtrail_bucket" {}
variable "flowlog_retention_in_days" {}
variable "iam_flowlog_role" {}
variable "private_subnet0_cidr" {}
variable "public_subnet0_cidr" {}
variable "public_gateway_ip" {}
variable "internal_domain_name" {}

variable "customer_gateway_ip" {}
variable "office_private_cidr" {type=list}
variable "office_public_cidr" {type=list}

variable "nat_base_vol_size" {}
variable "nat_desired_count" {}
variable "nat_max_count" {}
variable "nat_min_count" {}
variable "nat_private_ip" {}
variable "nat_keypair" {}
variable "nat_base_capacity" {}
variable "nat_per_above_base_capacity" {}
variable "nat_instance_profile" {}
variable "nat_scheduled_actions_enabled" {type=bool}

variable "openvpn_base_vol_size" {}
variable "openvpn_desired_count" {}
variable "openvpn_max_count" {}
variable "openvpn_min_count" {}
variable "openvpn_private_ip" {}
variable "openvpn_gateway_ip" {}
variable "openvpn_keypair" {}
variable "openvpn_base_capacity" {}
variable "openvpn_per_above_base_capacity" {}
variable "openvpn_instance_profile" {}
variable "openvpn_ami_id" {}
variable "openvpn_scheduled_actions_enabled" {type=bool}

variable "ssh_base_vol_size" {}
variable "ssh_desired_count" {}
variable "ssh_max_count" {}
variable "ssh_min_count" {}
variable "ssh_private_ip" {}
variable "ssh_keypair" {}
variable "ssh_base_capacity" {}
variable "ssh_per_above_base_capacity" {}
variable "ssh_instance_profile" {}
variable "ssh_scheduled_actions_enabled" {type=bool}