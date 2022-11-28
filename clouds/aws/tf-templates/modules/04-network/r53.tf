/*
 * File: r53.tf
 * Project: 04-network
 * Created Date: Saturday July 13th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Saturday July 13th 2019 5:08:51 am
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




resource "aws_route53_zone" "internal-dns-zone" {
    name = "${var.env}.${var.internal_domain_name}"

    vpc {
      vpc_id = aws_vpc.vpc.id
    }

    tags   = merge(
                var.tags,
                map(
                    "Name", "${var.env}-internal-dns-zone",
                )
             )
}
