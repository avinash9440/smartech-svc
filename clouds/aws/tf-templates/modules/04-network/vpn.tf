/*
 * File: vpn.tf
 * Project: 04-network
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:26:37 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




# openvpn / office <--> aws vpc (svc)

resource "aws_security_group" "openvpn-sg" {
    name        = "${var.env}-openvpn-sg"
    description = "Security group for openvpn instance"
    vpc_id      = aws_vpc.vpc.id

    ingress {
        from_port = 22
        to_port   = 22
        protocol  = "tcp"
        cidr_blocks = var.office_public_cidr
    }

    ingress {
        from_port = 443
        to_port   = 443
        protocol  = "tcp"
        cidr_blocks = var.office_public_cidr
    }

    ingress {
        from_port = 943
        to_port   = 943
        protocol  = "tcp"
        cidr_blocks = var.office_public_cidr
    }

    ingress {
        from_port = 1194
        to_port   = 1194
        protocol  = "udp"
        cidr_blocks = var.office_public_cidr
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags   = merge(
                var.tags,
                map(
                    "Name", "${var.env}-openvpn-sg",
                )
             )

}

resource "aws_eip" "openvpn-eip" {
    vpc               = true
    depends_on        = [aws_internet_gateway.igw]
    tags              = merge(
                            var.tags,
                            map(
                                "Name", "${var.env}-openvpn-eip",
                            )
                        )
}

data "template_file" "openvpn-userdata-tmpl" {
    template = file("${path.module}/tmpl/openvpn-userdata.tmpl")
    vars     = {
                devops_bucket = var.devops_bucket
                aws_region    = var.aws_region
                allocation_id = aws_eip.openvpn-eip.id
    }
}

resource "aws_launch_template" "openvpn-lt" {
    
    key_name               = var.openvpn_keypair
    image_id               = var.openvpn_ami_id
    user_data              = base64encode(data.template_file.openvpn-userdata-tmpl.rendered)
    name_prefix            = "${var.env}-openvpn-lt"
    instance_type          = "t3.nano"
    
    tag_specifications {
        tags          = var.tags
        resource_type = "instance"
    }

    iam_instance_profile {
        name = var.openvpn_instance_profile
    }
    
    block_device_mappings {
        device_name = "/dev/sda1"
        ebs {
            delete_on_termination = true
            volume_size           = var.openvpn_base_vol_size
        }
    }

    network_interfaces {
        security_groups             = [aws_security_group.openvpn-sg.id]
        associate_public_ip_address = true
        delete_on_termination       = true
        device_index                = 0
    }    

    tags   = merge(
                var.tags,
                map(
                    "Name", "${var.env}-openvpn-lt",
                )
             )
}

resource "aws_autoscaling_group" "openvpn-asg" {

    # Keep min, max and desired always 1 for this openvpn
    desired_capacity    = var.openvpn_desired_count
    max_size            = var.openvpn_max_count
    min_size            = var.openvpn_min_count

    vpc_zone_identifier = [aws_subnet.public-subnet0.id]
    health_check_type   = "EC2"

    mixed_instances_policy {
        
        instances_distribution {
            on_demand_base_capacity                  = var.openvpn_base_capacity
            on_demand_percentage_above_base_capacity = var.openvpn_per_above_base_capacity
            spot_instance_pools                      = 20
        }

        launch_template {
            launch_template_specification {
                launch_template_id = aws_launch_template.openvpn-lt.id
                version            = aws_launch_template.openvpn-lt.latest_version
            }

            override {
                instance_type = "t3.micro"
            }

            override {
                instance_type = "t3.nano"
            }            

            override {
                instance_type = "t2.micro"
            }


            override {
                instance_type = "t2.small"
            }
            
        }
    }

    tags = [
        {
            key                 = "Name"
            value               = "${var.env}-openvpn-asg"
            propagate_at_launch = true
        }
    ]

}

# Disabled: To be started from AWS Management Console
# resource "aws_autoscaling_schedule" "startup-vpn-asg-schedule" {
#     scheduled_action_name  = "startup scheduled action for openvpn-asg"
#     min_size               = 0
#     desired_capacity       = 1
#     max_size               = 1
#     recurrence             = var.asg_startup_cron
#     autoscaling_group_name = aws_autoscaling_group.openvpn-asg.name
# }

resource "aws_autoscaling_schedule" "shutdown-vpn-asg-schedule" {
    count = var.openvpn_scheduled_actions_enabled ? 1 : 0

    scheduled_action_name  = "shutdown scheduled action for openvpn-asg"
    min_size               = 0
    desired_capacity       = 0
    max_size               = 1
    recurrence             = var.asg_shutdown_cron
    autoscaling_group_name = aws_autoscaling_group.openvpn-asg.name
}

# aws site-site / netcore lower parel <--> aws vpc (svc)

resource "aws_vpn_gateway" "svc-lp-vpn-gateway" {
    vpc_id = aws_vpc.vpc.id
    tags   = merge(
                var.tags,
                map(
                    "Name", "${var.env}-lp-vpn-gateway",
                )
             )
}

resource "aws_customer_gateway" "svc-lp-customer-gateway" {
    bgp_asn    = 65000
    ip_address = var.customer_gateway_ip
    type       = "ipsec.1"
    tags       = merge(
                    var.tags,
                    map(
                        "Name", "${var.env}-lp-customer-gateway",
                    )
                 )
}

resource "aws_vpn_connection" "svc-lp-vpn-conn" {
    vpn_gateway_id      = aws_vpn_gateway.svc-lp-vpn-gateway.id
    customer_gateway_id = aws_customer_gateway.svc-lp-customer-gateway.id
    type                = "ipsec.1"
    static_routes_only  = true
    tags   = merge(
                var.tags,
                map(
                    "Name", "${var.env}-lp-vpn-connection",
                )
             )
}

resource "aws_vpn_connection_route" "lp-office-static-route" {
    count                  = length(var.office_private_cidr)
    destination_cidr_block = var.office_private_cidr[count.index]
    vpn_connection_id      = aws_vpn_connection.svc-lp-vpn-conn.id
}