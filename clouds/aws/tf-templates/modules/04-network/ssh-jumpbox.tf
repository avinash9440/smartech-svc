/*
 * File: ssh-jumpbox.tf
 * Project: 06-platform
 * Created Date: Friday June 28th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Friday June 28th 2019 3:28:54 pm
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




# ssh / office -> aws vpc (svc)

data "aws_ami" "ssh" {
    owners      = ["amazon"]
    most_recent = true

    filter {
        name    = "name"
        values  = ["amzn2-ami-minimal-hvm-*-x86_64-ebs"]
    }
}

resource "aws_security_group" "ssh-sg" {
    name        = "${var.env}-ssh-sg"
    description = "Security group for ssh instance"
    vpc_id      = aws_vpc.vpc.id

    ingress {
        from_port = 22
        to_port   = 22
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
                    "Name", "${var.env}-ssh-sg",
                )
              )

}

resource "aws_eip" "ssh-eip" {
    vpc               = true
    depends_on        = [aws_internet_gateway.igw]
    tags              = merge(
                            var.tags,
                            map(
                                "Name", "${var.env}-ssh-eip",
                            )
                        )
}

data "template_file" "ssh-userdata-tmpl" {
    template = file("${path.module}/tmpl/ssh-userdata.tmpl")
    vars     = {
                devops_bucket             = var.devops_bucket
                devops_bucket_region      = var.devops_bucket_region 
                devops_bucket_bkup        = var.devops_bucket_bkup
                devops_bucket_bkup_region = var.devops_bucket_bkup_region
                aws_region                = var.aws_region
                allocation_id             = aws_eip.ssh-eip.id
    }
}

resource "aws_launch_template" "ssh-lt" {
    
    key_name               = var.ssh_keypair
    image_id               = data.aws_ami.ssh.id
    user_data              = base64encode(data.template_file.ssh-userdata-tmpl.rendered)
    name_prefix            = "${var.env}-ssh-lt"
    instance_type          = "t3.nano"
    
    tag_specifications {
        tags          = var.tags
        resource_type = "instance"
    }

    iam_instance_profile {
        name = var.ssh_instance_profile
    }
    
    block_device_mappings {
        device_name = "/dev/xvda"
        ebs {
            delete_on_termination = true
            volume_size           = var.ssh_base_vol_size
        }
    }

    network_interfaces {
        security_groups             = [aws_security_group.ssh-sg.id]
        associate_public_ip_address = true
        delete_on_termination       = true
        device_index                = 0
    }    

    tags   = merge(
                var.tags,
                map(
                    "Name", "${var.env}-ssh-lt",
                )
             )
}

resource "aws_autoscaling_group" "ssh-asg" {

    # Keep min, max and desired always 1 for this ssh
    desired_capacity    = var.ssh_desired_count
    max_size            = var.ssh_max_count
    min_size            = var.ssh_min_count

    vpc_zone_identifier = [aws_subnet.public-subnet0.id]
    health_check_type   = "EC2"

    mixed_instances_policy {
        
        instances_distribution {
            on_demand_base_capacity                  = var.ssh_base_capacity
            on_demand_percentage_above_base_capacity = var.ssh_per_above_base_capacity
            spot_instance_pools                      = 20
        }

        launch_template {
            launch_template_specification {
                launch_template_id = aws_launch_template.ssh-lt.id
                version            = aws_launch_template.ssh-lt.latest_version
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
            value               = "${var.env}-ssh-asg"
            propagate_at_launch = true
        }
    ]

}

# Disabled: To be started from AWS Management Console
# resource "aws_autoscaling_schedule" "startup-ssh-asg-schedule" {
#     scheduled_action_name  = "startup scheduled action for ssh-asg"
#     min_size               = 0
#     desired_capacity       = 1
#     max_size               = 1
#     recurrence             = var.asg_startup_cron
#     autoscaling_group_name = aws_autoscaling_group.ssh-asg.name
# }

resource "aws_autoscaling_schedule" "shutdown-ssh-asg-schedule" {
    count = var.ssh_scheduled_actions_enabled ? 1 : 0

    scheduled_action_name  = "shutdown scheduled action for ssh-asg"
    min_size               = 0
    desired_capacity       = 0
    max_size               = 1
    recurrence             = var.asg_shutdown_cron
    autoscaling_group_name = aws_autoscaling_group.ssh-asg.name
}