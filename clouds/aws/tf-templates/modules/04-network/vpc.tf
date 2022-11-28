/*
 * File: vpc.tf
 * Project: 04-network
 * Created Date: Thursday June 27th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Thursday June 27th 2019 12:57:18 am
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr  
    enable_dns_support = true
    enable_dns_hostnames = true
    tags       = merge(
                    var.tags,
                    map(
                        "Name", "${var.env}-vpc",
                    )
                 )
}

resource "aws_flow_log" "vpc-flowlog" {
    log_destination = aws_cloudwatch_log_group.log-group.arn
    iam_role_arn    = var.iam_flowlog_role
    vpc_id          = aws_vpc.vpc.id
    traffic_type    = "ALL"
}

resource "aws_cloudwatch_log_group" "log-group" {
    name                 = "${var.env}-log-group"
    retention_in_days    = var.flowlog_retention_in_days
    tags                 = merge(
                                var.tags,
                                map(
                                    "Name","${var.env}-log-group",
                                )
                            )
}
