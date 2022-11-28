/*
 * File: outputs.tf
 * Project: 04-network
 * Created Date: Thursday June 20th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Thursday June 20th 2019 3:29:17 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




output "svc-vpc-id"{
    value = aws_vpc.vpc.id
}

output "svc-vpc-cidr"{
    value = aws_vpc.vpc.cidr_block
}

output "svc-log-group-arn" {
    value = aws_cloudwatch_log_group.log-group.arn
}

output "svc-vpc-flowlog" {
    value = aws_flow_log.vpc-flowlog.id
}

output "svc-igw-id" {
    value = aws_internet_gateway.igw.id
}

output "svc-private-subnet0-id" {
    value = aws_subnet.private-subnet0.id
}

output "svc-public-subnet0-id" {
    value = aws_subnet.public-subnet0.id
}

output "svc-private-route-table-id" {
    value = aws_route_table.private-route-table.id
}

output "svc-public-route-table-id" {
    value = aws_route_table.public-route-table.id
}

output "svc-public-subnet0-route-table-association-id" {
    value = aws_route_table_association.public-subnet0-route-table-association.id
}

output "svc-private-subnet0-route-table-association-id" {
    value = aws_route_table_association.private-subnet0-route-table-association.id
}

output "ssh-sg-id" {
    value = aws_security_group.ssh-sg.id
}

output "svc-r53-zone" {
    value = aws_route53_zone.internal-dns-zone.zone_id
}