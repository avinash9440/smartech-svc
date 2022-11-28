/*
 * File: jenkins.tf
 * Project: 06-platform
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:28:18 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




# jenkins master

resource "aws_security_group" "jenkins-sg" {
    name        = "${var.env}-jenkins-sg"
    description = "Security group for jenkins instance"
    vpc_id      = var.vpc_id

    ingress {
        from_port = 22
        to_port   = 22
        protocol  = "tcp"
        security_groups = [var.ssh_sg]
    }

    ingress {
        from_port = 443
        to_port   = 443
        protocol  = "tcp"
        cidr_blocks = var.office_public_cidr
    }

    ingress {
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
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
                    "Name", "${var.env}-jenkins-sg",
                )
             )

}

resource "aws_network_interface" "jenkins-eni" {
    subnet_id         = var.private_subnet0_id
    security_groups   = [aws_security_group.jenkins-sg.id]
    private_ips       = [var.jenkins_private_ip]
    source_dest_check = false
    tags              = merge(
                            var.tags,
                            map(
                                "Name", "${var.env}-jenkins-eni",
                            )
                        )
}

data "template_file" "jenkins-userdata-tmpl" {
    template = file("${path.module}/tmpl/jenkins-userdata.tmpl")
    vars     = {
                devops_bucket        = var.devops_bucket
                aws_region           = var.aws_region
                network_interface_id = aws_network_interface.jenkins-eni.id
                private_ip           = var.jenkins_private_ip
                subnet_cidr          = var.private_subnet0_cidr
                gateway_ip           = var.private_gateway_ip
    }
}

resource "aws_launch_template" "jenkins-lt" {
    
    key_name               = var.jenkins_keypair
    image_id               = var.jenkins_ami_id
    user_data              = base64encode(data.template_file.jenkins-userdata-tmpl.rendered)
    name_prefix            = "${var.env}-jenkins-lt"
    instance_type          = "t3.nano"
    
    tag_specifications {
        tags          = var.tags
        resource_type = "instance"
    }

    iam_instance_profile {
        name = var.jenkins_instance_profile
    }
    
    block_device_mappings {
        device_name = "/dev/sda1"
        ebs {
            delete_on_termination = true
            volume_size           = var.jenkins_base_vol_size
        }
    }

    network_interfaces {
        security_groups             = [aws_security_group.jenkins-sg.id]
        delete_on_termination       = true
        device_index                = 0
    }

    tags   = merge(
                var.tags,
                map(
                    "Name", "${var.env}-jenkins-lt",
                )
              )
}

resource "aws_autoscaling_group" "jenkins-asg" {

    # Keep min, max and desired always 1 for this jenkins
    desired_capacity    = var.jenkins_desired_count
    max_size            = var.jenkins_max_count
    min_size            = var.jenkins_min_count

    vpc_zone_identifier = [var.private_subnet0_id]
    health_check_type   = "EC2"

    mixed_instances_policy {
        
        instances_distribution {
            on_demand_base_capacity                  = var.jenkins_base_capacity
            on_demand_percentage_above_base_capacity = var.jenkins_per_above_base_capacity
            spot_instance_pools                      = 20
        }

        launch_template {
            launch_template_specification {
                launch_template_id = aws_launch_template.jenkins-lt.id
                version            = aws_launch_template.jenkins-lt.latest_version
            }
            
            override {
                instance_type = "t2.small"
            }

            override {
                instance_type = "t2.medium"
            }

            override {
                instance_type = "t3.small"
            }

            # override {
            #     instance_type = "t2.micro"
            # }

            # override {
            #     instance_type = "t3.nano"
            # }            
        }
    }

    tags = [
        {
            key                 = "Name"
            value               = "${var.env}-jenkins-asg"
            propagate_at_launch = true
        }
    ]

}

# Disabled: To be started from terraform
# resource "aws_autoscaling_schedule" "startup-jenkins-asg-schedule" {
#     scheduled_action_name  = "startup scheduled action for jenkins-asg"
#     min_size               = 0
#     desired_capacity       = 1
#     max_size               = 1
#     recurrence             = var.asg_startup_cron
#     autoscaling_group_name = aws_autoscaling_group.jenkins-asg.name
# }

resource "aws_autoscaling_schedule" "shutdown-jenkins-asg-schedule" {
    count = var.jenkins_scheduled_actions_enabled ? 1 : 0

    scheduled_action_name  = "shutdown scheduled action for jenkins-asg"
    min_size               = 0
    desired_capacity       = 0
    max_size               = 1
    recurrence             = var.asg_shutdown_cron
    autoscaling_group_name = aws_autoscaling_group.jenkins-asg.name
}

resource "aws_route53_record" "jenkins-a-record" {
    zone_id = var.internal_zone_id
    name = "jenkins.${var.aws_region}"
    type = "A"
    ttl  = "60"
    records = aws_network_interface.jenkins-eni.private_ips
}