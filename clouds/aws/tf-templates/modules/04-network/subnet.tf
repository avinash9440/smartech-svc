/*
 * File: subnet.tf
 * Project: 04-network
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:31:51 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */


# availability zones

data "aws_availability_zones" "available" {
  state = "available"
}

# subnets

resource "aws_subnet" "private-subnet0" {
    vpc_id            = aws_vpc.vpc.id
    availability_zone = data.aws_availability_zones.available.names[var.availability_zone_index]
    cidr_block        = var.private_subnet0_cidr
    tags              = merge(
                            var.tags,
                            map(
                                "Name", "${var.env}-private-subnet0",
                            )
                        )
}

resource "aws_subnet" "public-subnet0" {
    vpc_id            = aws_vpc.vpc.id
    availability_zone = data.aws_availability_zones.available.names[var.availability_zone_index]
    cidr_block        = var.public_subnet0_cidr
    tags              = merge(
                            var.tags,
                            map(
                                "Name", "${var.env}-public-subnet0",
                            )
                        )
}
