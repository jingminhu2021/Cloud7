data "aws_ami" "appsmith_ami" {
  # filter {
  #   name   = "name"
  #   values = ["appsmith-ee-ami-*"]
  # }
  filter {
    name   = "image-id"
    values = ["ami-0d4ff711255cd3e38"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  most_recent = true
}

# Create a security group for EC2 instances to allow ingress on port 80 :
resource "aws_security_group" "ec2_ingress" {
  name        = "ec2_http_ingress"
  description = "Used for autoscale group"
  vpc_id      = module.vpc.vpc_id
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

# create launch configuration for ASG :
resource "aws_launch_configuration" "asg_launch_conf" {
  name_prefix = "tf-asg-lc"
  # image_id      = data.aws_ami.ubuntu_ami.id
  image_id      = data.aws_ami.appsmith_ami.id
  instance_type = "t3.medium"
  # user_data       = data.template_cloudinit_config.user_data.rendered
  security_groups = [aws_security_group.ec2_ingress.id]
  lifecycle {
    create_before_destroy = true
  }
}
# create ASG with Launch Configuration :
resource "aws_autoscaling_group" "asg" {
  name                 = "tf-asg"
  launch_configuration = aws_launch_configuration.asg_launch_conf.name
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = module.vpc.private_subnets # placing asg in private subnet
  target_group_arns    = [aws_lb_target_group.alb_tg.arn]
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    module.vpc,
    aws_lb_target_group.alb_tg,
    aws_launch_configuration.asg_launch_conf
  ]
}

# fetch al2023 ami id:
# data "aws_ami" "amazon_linux_ami" {
#   filter {
#     name   = "image-id"
#     values = ["ami-036d8cf6cf7a08f64"]
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
#   most_recent = true
# }

# resource "aws_security_group" "ec2_ingress_grafana" {
#   name        = "ec2_http_ingress_grafana"
#   description = "Used for autoscale group"
#   vpc_id      = module.vpc.vpc_id
#   # HTTP access from anywhere
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 3000
#     to_port     = 3000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# generate user data script :
# data "template_cloudinit_config" "user_data" {
#   gzip          = false
#   base64_encode = true
#   part {
#     content_type = "text/x-shellscript"
#     content      = <<-EOT
#     #!/bin/bash
#     sudo yum update -y
#     sudo yum install -y docker
#     sudo service docker start
#     sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
#     sudo chmod +x /usr/local/bin/docker-compose
#     curl -fsSL https://raw.githubusercontent.com/grafana/oncall/dev/docker-compose.yml -o docker-compose.yml
#     echo "DOMAIN=http://localhost:8080
#     # Remove 'with_grafana' below if you want to use existing grafana
#     # Add 'with_prometheus' below to optionally enable a local prometheus for oncall metrics
#     # e.g. COMPOSE_PROFILES=with_grafana,with_prometheus
#     COMPOSE_PROFILES=with_grafana
#     # to setup an auth token for prometheus exporter metrics:
#     # PROMETHEUS_EXPORTER_SECRET=my_random_prometheus_secret
#     # also, make sure to enable the /metrics endpoint:
#     # FEATURE_PROMETHEUS_EXPORTER_ENABLED=True
#     SECRET_KEY=my_random_secret_must_be_more_than_32_characters_long" > .env
#     echo "global:
#       scrape_interval:     15s
#       evaluation_interval: 15s

#     scrape_configs:
#       - job_name: prometheus
#         metrics_path: /metrics/
#         authorization:
#           credentials: my_random_prometheus_secret
#         static_configs:
#           - targets: [\"host.docker.internal:8080\"]" > prometheus.yml
#     docker-compose pull && docker-compose up -d
#     EOT
#   }
# }

# create launch configuration for ASG :
# resource "aws_launch_configuration" "grafana_asg_launch_conf" {
#   name_prefix     = "tf-asg-grafana-lc"
#   image_id        = data.aws_ami.amazon_linux_ami.id
#   instance_type   = "t3.medium"
#   user_data       = data.template_cloudinit_config.user_data.rendered
#   security_groups = [aws_security_group.ec2_ingress_grafana.id]
#   lifecycle {
#     create_before_destroy = true
#   }
# }


# # create ASG with Launch Configuration :
# resource "aws_autoscaling_group" "grafana_asg" {
#   name                 = "grafana-asg"
#   launch_configuration = aws_launch_configuration.grafana_asg_launch_conf.name
#   min_size             = 1
#   max_size             = 1
#   vpc_zone_identifier  = module.vpc.private_subnets # placing asg in private subnet
#   target_group_arns    = [aws_lb_target_group.grafana_alb_tg.arn]
#   lifecycle {
#     create_before_destroy = true
#   }

#   depends_on = [
#     module.vpc,
#     aws_lb_target_group.grafana_alb_tg,
#     aws_launch_configuration.grafana_asg_launch_conf
#   ]
#   tag {
#     key                 = "Name"
#     value               = "grafana-asg"
#     propagate_at_launch = true
#   }
# }
