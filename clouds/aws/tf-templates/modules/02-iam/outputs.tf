/*
 * File: outputs.tf
 * Project: 02-iam
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:16:09 am
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




output "ssh-jumpbox-role-arn" {
    value = aws_iam_role.ssh-jumpbox-role.arn
}

output "ssh-jumpbox-role-name" {
    value = aws_iam_role.ssh-jumpbox-role.name
}

output "ssh-jumpbox-instance-profile-arn" {
    value = aws_iam_instance_profile.ssh-jumpbox-instance-profile.arn
}

output "ssh-jumpbox-instance-profile-id" {
    value = aws_iam_instance_profile.ssh-jumpbox-instance-profile.id
}

output "ssh-jumpbox-instance-profile-name" {
    value = aws_iam_instance_profile.ssh-jumpbox-instance-profile.name
}

output "vpc-flowlog-role-arn" {
    value = aws_iam_role.vpc-flowlog-role.arn
}

output "vpc-flowlog-role-name" {
    value = aws_iam_role.vpc-flowlog-role.name
}

output "cloudtrail-role-arn" {
    value = aws_iam_role.cloudtrail-role.arn
}

output "cloudtrail-role-name" {
    value = aws_iam_role.cloudtrail-role.name
}

output "iam-group-mod-target-role-arn" {
    value = aws_iam_role.iam-group-mod-target-role.arn
}

output "iam-group-mod-target-role-name" {
    value = aws_iam_role.iam-group-mod-target-role.name
}

output "openvpn-role-arn" {
    value = aws_iam_role.openvpn-role.arn
}

output "openvpn-role-name" {
    value = aws_iam_role.openvpn-role.name
}

output "openvpn-instance-profile-arn" {
    value = aws_iam_instance_profile.openvpn-instance-profile.arn
}

output "openvpn-instance-profile-id" {
    value = aws_iam_instance_profile.openvpn-instance-profile.id
}

output "openvpn-instance-profile-name" {
    value = aws_iam_instance_profile.openvpn-instance-profile.name
}

output "nat-role-arn" {
    value = aws_iam_role.nat-role.arn
}

output "nat-role-name" {
    value = aws_iam_role.nat-role.name
}

output "nat-instance-profile-arn" {
    value = aws_iam_instance_profile.nat-instance-profile.arn
}

output "nat-instance-profile-id" {
    value = aws_iam_instance_profile.nat-instance-profile.id
}

output "nat-instance-profile-name" {
    value = aws_iam_instance_profile.nat-instance-profile.name
}

output "jenkins-role-arn" {
    value = aws_iam_role.jenkins-role.arn
}

output "jenkins-role-name" {
    value = aws_iam_role.jenkins-role.name
}

output "jenkins-instance-profile-arn" {
    value = aws_iam_instance_profile.jenkins-instance-profile.arn
}

output "jenkins-instance-profile-id" {
    value = aws_iam_instance_profile.jenkins-instance-profile.id
}

output "jenkins-instance-profile-name" {
    value = aws_iam_instance_profile.jenkins-instance-profile.name
}