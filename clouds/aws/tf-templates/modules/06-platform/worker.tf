/*
 * File: worker.tf
 * Project: 06-platform
 * Created Date: Thursday July 11th 2019
 * Author: Ashay Varun Chitnis
 * -----
 * Last Modified: Thursday July 11th 2019 4:12:19 am
 * Modified By: Ashay Varun Chitnis at <ashay.chitnis@gmail.com>
 * -----
 * Copyright (c) 2019 Ashay Chitnis, all rights reserved.
 */




# jenkins worker


resource "aws_security_group" "worker-sg" {
    name        = "${var.env}-worker-sg"
    description = "Security group for worker instance"
    vpc_id      = var.vpc_id

    ingress {
        from_port = 22
        to_port   = 22
        protocol  = "tcp"
        security_groups = [
            var.ssh_sg, 
            aws_security_group.jenkins-sg.id
        ]
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
                    "Name", "${var.env}-worker-sg",
                )
             )

}

data "template_file" "worker-userdata-tmpl" {
    count    = length(var.worker_sit_env)
    template = file("${path.module}/tmpl/worker-userdata.tmpl")
    vars     = {
                devops_bucket  = var.devops_bucket
                aws_region     = var.aws_region
                sit_env        = element(keys(var.worker_sit_env), count.index)

                home_dir       = lookup(
                                    var.worker_sit_env[element(keys(var.worker_sit_env), count.index)],
                                    "worker_home_dir",
                                    var.worker_default_home_dir
                                 )

                executor_count = lookup(
                                    var.worker_sit_env[element(keys(var.worker_sit_env), count.index)],
                                    "worker_executor_count",
                                    var.worker_default_executor_count
                                 )

                credentials_id = lookup(
                                    var.worker_sit_env[element(keys(var.worker_sit_env), count.index)],
                                    "worker_credentials_id",
                                    var.worker_default_credentials_id
                                 )

                ssh_user       = lookup(
                                    var.worker_sit_env[element(keys(var.worker_sit_env), count.index)],
                                    "worker_ssh_user",
                                    var.worker_default_ssh_user
                                 )

                ssh_group      = lookup(
                                    var.worker_sit_env[element(keys(var.worker_sit_env), count.index)],
                                    "worker_ssh_group",
                                    var.worker_default_ssh_group
                                 )
                                 
                ssh_port       = lookup(
                                    var.worker_sit_env[element(keys(var.worker_sit_env), count.index)],
                                    "worker_ssh_port",
                                    var.worker_default_ssh_port
                                 )                                       

    }
}

resource "aws_launch_template" "worker-lt" {
    count         = length(var.worker_sit_env)

    user_data     = base64encode(data.template_file.worker-userdata-tmpl[count.index].rendered)
    name_prefix   = "${var.env}-worker-${element(keys(var.worker_sit_env), count.index)}-lt"
    instance_type = "t3.nano"

    image_id      = lookup(
                        var.worker_sit_env[element(keys(var.worker_sit_env), count.index)], 
                        "worker_ami_id",
                        var.worker_default_ami_id
               )

    key_name      =  lookup(
                        var.worker_sit_env[element(keys(var.worker_sit_env), count.index)], 
                        "worker_keypair",
                        var.worker_default_keypair
                )
    
    tag_specifications {
        tags          = var.tags
        resource_type = "instance"
    }

    iam_instance_profile {
        name = var.worker_instance_profile
    }
    
    block_device_mappings {
        device_name = "/dev/sda1"
        ebs {
            delete_on_termination = true
            volume_size           = lookup(
                                        var.worker_sit_env[element(keys(var.worker_sit_env), count.index)], 
                                        "worker_base_vol_size",
                                        var.worker_default_base_vol_size
                                    )
        }
    }

    network_interfaces {
        security_groups             = [aws_security_group.worker-sg.id]
        delete_on_termination       = true
        device_index                = 0
    }

    tags   = merge(
                var.tags,
                map(
                    "Name", "${var.env}-worker-lt",
                )
             )
}

resource "aws_autoscaling_group" "worker-asg" {
    count      = length(var.worker_sit_env)
    depends_on = [aws_autoscaling_group.jenkins-asg]

    # Keep min, max and desired always 1 for this worker
    desired_capacity    = lookup(
                           var.worker_sit_env[element(keys(var.worker_sit_env), count.index)], 
                           "worker_desired_count",
                            var.worker_default_desired_count
                        )


    max_size            = lookup(
                           var.worker_sit_env[element(keys(var.worker_sit_env), count.index)], 
                           "worker_max_count",
                            var.worker_default_max_count
                        )

    min_size            = lookup(
                            var.worker_sit_env[element(keys(var.worker_sit_env), count.index)], 
                            "worker_min_count",
                            var.worker_default_min_count
                        )

    vpc_zone_identifier = [var.private_subnet0_id]
    health_check_type   = "EC2"

    mixed_instances_policy {
        
        instances_distribution {
            on_demand_base_capacity   = lookup(
                                            var.worker_sit_env[element(keys(var.worker_sit_env), count.index)], 
                                            "worker_base_capacity",
                                            var.worker_default_base_capacity
                                        )

            on_demand_percentage_above_base_capacity = lookup(
                                                           var.worker_sit_env[element(keys(var.worker_sit_env), count.index)],
                                                           "worker_per_above_base_capacity",
                                                           var.worker_default_per_above_base_capacity
                                                    )

            spot_instance_pools                      = 20
        }

        launch_template {
            launch_template_specification {
                launch_template_id = aws_launch_template.worker-lt[count.index].id
                version            = aws_launch_template.worker-lt[count.index].latest_version
            }
            
            override {
                instance_type = "m5.large"
            }

            override {
                instance_type = "t2.large"
            }

            override {
                instance_type = "t2.medium"
            }            
        }
    }

    tags = [
        {
            key                 = "Name"
            value               = "${var.env}-worker-${element(keys(var.worker_sit_env), count.index)}-asg"
            propagate_at_launch = true
        },
        {
            key                 = "SITEnv"
            value               = element(keys(var.worker_sit_env), count.index)
            propagate_at_launch = true
        }
    ]

}

# Disabled: To be started from terraform
# resource "aws_autoscaling_schedule" "startup-worker-asg-schedule" {
#     count                  = length(var.worker_sit_env)
#     scheduled_action_name  = "startup scheduled action for worker-asg"
#     min_size               = 0
#     desired_capacity       = 1
#     max_size               = 1
#     recurrence             = var.asg_startup_cron
#     autoscaling_group_name = aws_autoscaling_group.worker-asg.*.name[count.index]
# }

resource "aws_autoscaling_schedule" "shutdown-worker-asg-schedule" {
    count = var.worker_default_scheduled_actions_enabled ? length(var.worker_sit_env) : 0

    scheduled_action_name  = "shutdown scheduled action for worker-asg"
    min_size               = 0
    desired_capacity       = 0
    max_size               = 1
    recurrence             = var.asg_shutdown_cron
    autoscaling_group_name = aws_autoscaling_group.worker-asg.*.name[count.index]
}