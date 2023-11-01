# Create Security Group for ALB Ingress :
resource "aws_security_group" "alb_ingress" {
  name   = "alg_http_ingress"
  vpc_id = module.vpc.vpc_id
  # Allow ingress to http port 80 from anywhere
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Create ALB :
resource "aws_lb" "alb" {
  name            = "tf-cloudfront-alb"
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.alb_ingress.id]
  internal        = false
  idle_timeout    = 60
  tags            = var.tags
}
resource "aws_lb_target_group" "alb_tg" {
  name     = "tf-cloudfront-alb-tg"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  tags     = var.tags
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = 80
  }
}
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    type             = "forward"
  }
}

# Create Security Group for ALB Ingress :
# resource "aws_security_group" "grafana_alb_ingress" {
#   name   = "grafana_alg_http_ingress"
#   vpc_id = module.vpc.vpc_id
#   # Allow ingress to http port 80 from anywhere
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
# }
# # Create ALB :
# resource "aws_lb" "grafana_alb" {
#   name            = "tf-granfana-alb"
#   subnets         = module.vpc.public_subnets
#   security_groups = [aws_security_group.grafana_alb_ingress.id]
#   internal        = false
#   idle_timeout    = 60
#   tags            = var.tags
# }

# resource "aws_lb_target_group" "grafana_alb_tg" {
#   name     = "tf-grafana-alb-tg"
#   port     = "3000"
#   protocol = "HTTP"
#   vpc_id   = module.vpc.vpc_id
#   tags     = var.tags
#   health_check {
#     healthy_threshold   = 2
#     unhealthy_threshold = 3
#     timeout             = 5
#     interval            = 10
#     path                = "/"
#     port                = 3000
#   }
# }

# resource "aws_lb_listener" "grafana_alb_listener" {
#   load_balancer_arn = aws_lb.grafana_alb.arn
#   port              = 80
#   protocol          = "HTTP"
#   default_action {
#     target_group_arn = aws_lb_target_group.grafana_alb_tg.arn
#     type             = "forward"
#   }
# }

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

# output "grafana_alb_dns_name" {
#   value = aws_lb.grafana_alb.dns_name
# }
