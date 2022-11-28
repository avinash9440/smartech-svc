/*
 * File: route.tf
 * Project: 04-network
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 12:12:09 am
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




# route tables

resource "aws_route_table" "public-route-table" {
    vpc_id = aws_vpc.vpc.id
    tags   = merge(
                var.tags,
                map(
                    "Name", "${var.env}-public-route-table",
                )
             )
}

resource "aws_route_table" "private-route-table" {
    vpc_id = aws_vpc.vpc.id
    tags   = merge(
                var.tags,
                map(
                    "Name", "${var.env}-private-route-table",
                )
             )
}

# internet routes

resource "aws_route" "igw-route" {
    route_table_id         = aws_route_table.public-route-table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.igw.id
}

# nat route

resource "aws_route" "nat-route" {
    route_table_id         = aws_route_table.private-route-table.id
    destination_cidr_block = "0.0.0.0/0"
    network_interface_id   = aws_network_interface.nat-eni.id
}

# site-site route propagation

resource "aws_vpn_gateway_route_propagation" "aws-vpn-private-route-propagation" {
    route_table_id = aws_route_table.private-route-table.id
    vpn_gateway_id = aws_vpn_gateway.svc-lp-vpn-gateway.id
}

resource "aws_vpn_gateway_route_propagation" "aws-vpn-public-route-propagation" {
    route_table_id = aws_route_table.public-route-table.id
    vpn_gateway_id = aws_vpn_gateway.svc-lp-vpn-gateway.id
}

# Associations

resource "aws_route_table_association" "public-subnet0-route-table-association" {
    subnet_id      = aws_subnet.public-subnet0.id
    route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "private-subnet0-route-table-association" {
    subnet_id      = aws_subnet.private-subnet0.id
    route_table_id = aws_route_table.private-route-table.id
}
