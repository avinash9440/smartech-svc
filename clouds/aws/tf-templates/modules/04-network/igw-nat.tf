/*
 * File: igw-nat.tf
 * Project: 04-network
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:04:55 am
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




# internet gateway

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
    
    tags   = merge(
                var.tags,
                map(
                    "Name", "${var.env}-igw",
                )
             )
}

# nat

data "aws_ami" "nat" {
    owners      = ["amazon"]
    most_recent = true

    filter {
        name    = "name"
        values  = ["amzn-ami-vpc-nat*"]
    }
}

resource "aws_security_group" "nat-sg" {
    name        = "${var.env}-nat-sg"
    description = "Security group for nat instance"
    vpc_id      = aws_vpc.vpc.id

    ingress {
        from_port = 22
        to_port   = 22
        protocol  = "tcp"
        cidr_blocks = var.office_public_cidr
    }

    ingress {
        from_port = 0
        to_port   = 0
        protocol  = -1
        cidr_blocks = [var.private_subnet0_cidr]
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
                    "Name", "${var.env}-nat-sg",
                )
             )

}

resource "aws_eip" "nat-eip" {
    vpc               = true
    network_interface = aws_network_interface.nat-eni.id
    depends_on        = [aws_internet_gateway.igw]
    tags              = merge(
                            var.tags,
                            map(
                                "Name", "${var.env}-nat-eip",
                            )
                        )
}


resource "aws_network_interface" "nat-eni" {
    subnet_id         = aws_subnet.public-subnet0.id
    security_groups   = [aws_security_group.nat-sg.id]
    source_dest_check = false
    tags              = merge(
                            var.tags,
                            map(
                                "Name", "${var.env}-nat-eni",
                            )
                        )
}

data "aws_network_interface" "data-nat-eni" {
  id = aws_network_interface.nat-eni.id
}

data "template_file" "nat-userdata-tmpl" {
    template = file("${path.module}/tmpl/nat-userdata.tmpl")
    vars     = {
                aws_region           = var.aws_region
                private_route        = aws_route_table.private-route-table.id
                network_interface_id = aws_network_interface.nat-eni.id
                gateway_ip           = var.public_gateway_ip
                private_ip           = data.aws_network_interface.data-nat-eni.private_ip
    }
}

resource "aws_launch_template" "nat-lt" {
    
    key_name               = var.nat_keypair
    image_id               = data.aws_ami.nat.id
    user_data              = base64encode(data.template_file.nat-userdata-tmpl.rendered)
    name_prefix            = "${var.env}-nat-lt"
    instance_type          = "t3.nano"
    
    tag_specifications {
        tags          = var.tags
        resource_type = "instance"
    }

    iam_instance_profile {
        name = var.nat_instance_profile
    }
    
    block_device_mappings {
        device_name = "/dev/xvda"
        ebs {
            delete_on_termination = true
            volume_size           = var.nat_base_vol_size
        }
    }

    network_interfaces {
        security_groups             = [aws_security_group.nat-sg.id]
        associate_public_ip_address = true
        delete_on_termination       = true
        device_index                = 0
    }    

    tags   = merge(
                var.tags,
                map(
                    "Name", "${var.env}-nat-lt",
                )
             )
}

resource "aws_autoscaling_group" "nat-asg" {

    # Keep min, max and desired always 1 for this nat
    desired_capacity    = var.nat_desired_count
    max_size            = var.nat_max_count
    min_size            = var.nat_min_count

    vpc_zone_identifier = [aws_subnet.public-subnet0.id]
    health_check_type   = "EC2"

    mixed_instances_policy {
        
        instances_distribution {
            on_demand_base_capacity                  = var.nat_base_capacity
            on_demand_percentage_above_base_capacity = var.nat_per_above_base_capacity
            spot_instance_pools                      = 20
        }

        launch_template {
            launch_template_specification {
                launch_template_id = aws_launch_template.nat-lt.id
                version            = aws_launch_template.nat-lt.latest_version
            }

            override {
                instance_type = "t2.micro"
            }

            override {
                instance_type = "t3.nano"
            }

            override {
                instance_type = "t3.micro"
            }

            override {
                instance_type = "t2.small"
            }
        }
    }

    tags = [
        {
            key                 = "Name"
            value               = "${var.env}-nat-asg"
            propagate_at_launch = true
        }
    ]

}

# Disabled: To be started from AWS Management Console
# resource "aws_autoscaling_schedule" "startup-nat-asg-schedule" {
#     scheduled_action_name  = "startup scheduled action for nat-asg"
#     min_size               = 0
#     desired_capacity       = 1
#     max_size               = 1
#     recurrence             = var.asg_startup_cron
#     autoscaling_group_name = aws_autoscaling_group.nat-asg.name
# }

resource "aws_autoscaling_schedule" "shutdown-nat-asg-schedule" {
    count = var.nat_scheduled_actions_enabled ? 1 : 0

    scheduled_action_name  = "shutdown scheduled action for nat-asg"
    min_size               = 0
    desired_capacity       = 0
    max_size               = 1
    recurrence             = var.asg_shutdown_cron
    autoscaling_group_name = aws_autoscaling_group.nat-asg.name
}