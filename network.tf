provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

# Subnets : public
resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnets_cidr[0]
  availability_zone = var.availability_zones[0]
  tags = {
    Name = "Subnet-1"
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnets_cidr[1]
  availability_zone = var.availability_zones[1]
  tags = {
    Name = "Subnet-2"
  }
}

resource "aws_subnet" "subnet-3" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnets_cidr[2]
  availability_zone = var.availability_zones[2]
  tags = {
    Name = "Subnet-3"
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.cidr_route_table
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "a1" {
  subnet_id  = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_route_table_association" "a2" {
  subnet_id  = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_route_table_association" "a3" {
  subnet_id  = aws_subnet.subnet-3.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_security_group" "application_security_group" {
  name = "application_security_group"
  description = "Allow HTTP, HTTPS and SSH traffic"
  vpc_id = aws_vpc.vpc.id

  //  ingress {
  //    description = "SSH"
  //    from_port   = var.ssh-port
  //    to_port     = var.ssh-port
  //    protocol    = var.protocol-tcp
  //    cidr_blocks = var.cidr_sg
  //  }
  //
  //  ingress {
  //    description = "HTTPS"
  //    from_port   = var.https-port
  //    to_port     = var.https-port
  //    protocol    = var.protocol-tcp
  //    cidr_blocks = var.cidr_sg
  //  }
  //
  //  ingress {
  //    description = "HTTP"
  //    from_port   = var.http-port
  //    to_port     = var.http-port
  //    protocol    = var.protocol-tcp
  //    cidr_blocks = var.cidr_sg
  //  }

  ingress {
    description = "TCP Custom For Running Application"
    from_port = var.application-port
    to_port = var.application-port
    protocol = var.protocol-tcp
    security_groups = [
      aws_security_group.load-balancer-security-group.id]
  }


  egress {
    from_port = var.egres_port
    to_port = var.egres_port
    protocol = var.egress-protocol
    cidr_blocks = var.cidr_sg
  }
  tags = {
    Name = "Application security group"
  }
}

resource "aws_security_group" "db_security_group" {
  name        = var.db-security-group-name
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description = "MYSQL"
    from_port   = var.database-port
    to_port     = var.database-port
    protocol    = var.protocol-tcp
   security_groups = [aws_security_group.application_security_group.id]
  }

  tags = {
    Name = "Database security group"
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket-name
  acl = var.s3-access-level
  lifecycle_rule {
    enabled = true
    transition {
      days = 30
      storage_class = var.s3-bucket-name-storage
    }
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.s3-bucket-sse-algo
      }
    }
  }
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_block_public_access" {
  bucket = aws_s3_bucket.s3_bucket.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_db_subnet_group" "aws_db_subnet_group" {
  name  = var.db-subnet-group-name
  subnet_ids = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id, aws_subnet.subnet-3.id]
  tags = {
    Name = "AWS DB subnet group"
  }
}

resource "aws_db_instance" "rds_db" {
  engine                    = var.rds-db-engine
  engine_version            = var.rds-db-engine-version
  instance_class            = var.rds-instance-class
  name                      = var.rds-db-name
  username                  = var.rds-db-username
  password                  = var.rds-db-password
  identifier                = var.rds-db-identifier
  multi_az                  = false
  publicly_accessible       = false
  allocated_storage         = var.rds-db-storage
  db_subnet_group_name      = aws_db_subnet_group.aws_db_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.db_security_group.id]
  skip_final_snapshot = true
}

data "aws_iam_policy_document" "webapps3policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:*"]
    resources = ["arn:aws:s3:::${var.bucket-name}",
                "arn:aws:s3:::${var.bucket-name}/*"]
  }
}

resource "aws_iam_policy" "webapps3" {
  name = var.ec2-iam-policy-name
  policy = data.aws_iam_policy_document.webapps3policy.json
}

resource "aws_iam_role" "iam_role" {
  name = var.ec2-iam-role-name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name  = var.ec2-instance-profile-name
  role = aws_iam_role.code-deploy-ec2-service-role.name
}

resource "aws_iam_role_policy_attachment" "user-attach" {
  role = aws_iam_role.code-deploy-ec2-service-role.name
  policy_arn = aws_iam_policy.webapps3.arn
}

resource "aws_iam_role_policy_attachment" "ec2-codedeploy-attach" {
  role = aws_iam_role.code-deploy-ec2-service-role.name
  policy_arn = aws_iam_policy.code-deploy-ec2-s3.arn
}

resource "aws_iam_role_policy_attachment" "ec2-cloudwatch-attach" {
  role = aws_iam_role.code-deploy-ec2-service-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_key_pair" "ec2-key" {
  key_name   = var.ec2-keypair-name
  public_key = var.public-key
}

//resource "aws_instance" "ec2_instance" {
//  ami = var.ami
//  instance_type = var.ec2-instance-type
//  vpc_security_group_ids = [aws_security_group.application_security_group.id]
//  subnet_id = aws_subnet.subnet-1.id
//  root_block_device {
//    volume_type = var.ec2-volume-type
//    volume_size = var.ec2-volume-size
//    delete_on_termination = var.ec2-delete_on_termination
//  }
//  associate_public_ip_address = true
//  key_name               = aws_key_pair.ec2-key.key_name
//  iam_instance_profile   = aws_iam_instance_profile.iam_instance_profile.name
//  user_data = <<-EOT
//    #!/bin/bash
//    apt-get install unzip
//    echo "DATABASE_HOST_NAME=${aws_db_instance.rds_db.address}" > /home/ubuntu/.env
//    echo "DATABASE_USER_NAME=${aws_db_instance.rds_db.username}" >> /home/ubuntu/.env
//    echo "DATABASE_PASSWORD=${aws_db_instance.rds_db.password}" >> /home/ubuntu/.env
//    echo "DATABASE_NAME=${var.rds-db-name}" >> /home/ubuntu/.env
//    echo "DATABASE_PORT=${var.database-port}" >> /home/ubuntu/.env
//    echo "S3BUCKETNAME=${var.bucket-name}" >> /home/ubuntu/.env
//    echo "PORT=${var.application-port}" >> /home/ubuntu/.env
//  EOT
//  tags = {
//    Name = var.ec2-name
//  }
//}

resource aws_dynamodb_table "dynamodb"{
  name = var.dynamodb-name
  hash_key = var.dynamodb-hashkey
  write_capacity  = var.dynamodb-write-capacity
  read_capacity  = var.dynamodb-read-capacity
  attribute {
    name = var.dynamodb-hashkey
    type = var.dynamodb-hashkey-type
  }
}

// Assignmnet 6

data "aws_iam_policy_document" "codedeply-ec2-s3" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*"]
    resources = ["arn:aws:s3:::${var.codeploy-s3-bucket-name}",
      "arn:aws:s3:::${var.codeploy-s3-bucket-name}/*"]
  }
}

resource "aws_iam_policy" "code-deploy-ec2-s3" {
  name = var.code-deploy-ec2-s3-name
  policy = data.aws_iam_policy_document.codedeply-ec2-s3.json
}


data "aws_iam_policy_document" "github-upload-s3" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:Get*",
      "s3:List*"]
    resources = ["arn:aws:s3:::${var.codeploy-s3-bucket-name}",
      "arn:aws:s3:::${var.codeploy-s3-bucket-name}/*"]
  }
}

resource "aws_iam_policy" "gh-upload-s3" {
  name = var.gh-upload-s3-policy-name
  policy = data.aws_iam_policy_document.github-upload-s3.json
}

data "aws_iam_policy_document" "github-code-deploy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "codedeploy:RegisterApplicationRevision",
      "codedeploy:GetApplicationRevision"
    ]
    resources = ["arn:aws:codedeploy:${var.aws-region}:${var.aws-account-id}:application:${var.code-deploy-application-name}"]
  }
  statement {
    effect = "Allow"
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetDeployment"
    ]
    resources = ["arn:aws:codedeploy:${var.aws-region}:${var.aws-account-id}:deploymentgroup:${var.code-deploy-application-name}/${var.code-deploy-application-group-name}"]
  }
  statement {
    effect = "Allow"
    actions = [
      "codedeploy:GetDeploymentConfig"
    ]
    resources = [
      "arn:aws:codedeploy:${var.aws-region}:${var.aws-account-id}:deploymentconfig:CodeDeployDefault.OneAtATime",
      "arn:aws:codedeploy:${var.aws-region}:${var.aws-account-id}:deploymentconfig:CodeDeployDefault.HalfAtATime",
      "arn:aws:codedeploy:${var.aws-region}:${var.aws-account-id}:deploymentconfig:CodeDeployDefault.AllAtOnce"
    ]
  }
}

resource "aws_iam_policy" "gh-code-deploy" {
  name = var.gh-code-deploy-name
  policy = data.aws_iam_policy_document.github-code-deploy.json
}

resource "aws_iam_role" "code-deploy-ec2-service-role" {
  name = var.code-deploy-ec2-s3-name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codedeploy_ec2_service" {
  role       = aws_iam_role.code-deploy-ec2-service-role.name
  policy_arn = aws_iam_policy.code-deploy-ec2-s3.arn
}

resource "aws_iam_role" "code-deploy-service-role" {
  name = var.code-deploy-service-role-name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codedeploy_service_role" {
  role       = aws_iam_role.code-deploy-service-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_user_policy_attachment" "cicd-gh-upload-s3" {
  user       = var.ci-cd-user-name
  policy_arn = aws_iam_policy.gh-upload-s3.arn
}

resource "aws_iam_user_policy_attachment" "cicd-gh-code-deploy" {
  user       = var.ci-cd-user-name
  policy_arn = aws_iam_policy.gh-code-deploy.arn
}

resource "aws_codedeploy_app" "code_deploy_app" {
  name = var.code-deploy-application-name
  compute_platform = var.code-deploy-application-compute-platform
}

//resource "aws_codedeploy_deployment_group" "deployment_group" {
//  app_name = aws_codedeploy_app.code_deploy_app.name
//  deployment_group_name = var.code-deploy-application-group-name
//  service_role_arn = aws_iam_role.code-deploy-service-role.arn
//  auto_rollback_configuration {
//    enabled = true
//    events = [
//      var.deployment-failure-event]
//  }
//  ec2_tag_set {
//    ec2_tag_filter {
//      key = var.filter-key
//      type = var.filter-type
//      value = var.ec2-name
//    }
//  }
//  deployment_style {
//    deployment_type = var.deployment-type
//  }
//  deployment_config_name = var.deployment-config-name
//}

//resource "aws_eip" "lb" {
//  instance = aws_instance.ec2_instance.id
//  vpc      = true
//}

data "aws_route53_zone" "selected" {
  name         = var.route-53-zone-name
  private_zone = false
}

//resource "aws_route53_record" "route53_record" {
//  zone_id = data.aws_route53_zone.selected.zone_id
//  name    = var.route53-recode-name
//  type    = var.route53-recode-type
//  ttl     = var.route53-recode-ttl
//  records = [aws_eip.lb.public_ip]
//}

# Assignment 8

resource "aws_launch_configuration" "webapp-launch-config" {
    image_id        = var.ami
    instance_type   = var.ec2-instance-type
    security_groups = [aws_security_group.application_security_group.id]
    key_name        = aws_key_pair.ec2-key.key_name
    associate_public_ip_address = true
    root_block_device {
      volume_type = var.ec2-volume-type
      volume_size = var.ec2-volume-size
      delete_on_termination = var.ec2-delete_on_termination
    }
    user_data = <<-EOT
      #!/bin/bash
      apt-get install unzip
      echo "DATABASE_HOST_NAME=${aws_db_instance.rds_db.address}" > /home/ubuntu/.env
      echo "DATABASE_USER_NAME=${aws_db_instance.rds_db.username}" >> /home/ubuntu/.env
      echo "DATABASE_PASSWORD=${aws_db_instance.rds_db.password}" >> /home/ubuntu/.env
      echo "DATABASE_NAME=${var.rds-db-name}" >> /home/ubuntu/.env
      echo "DATABASE_PORT=${var.database-port}" >> /home/ubuntu/.env
      echo "S3BUCKETNAME=${var.bucket-name}" >> /home/ubuntu/.env
      echo "PORT=${var.application-port}" >> /home/ubuntu/.env
    EOT
    iam_instance_profile   = aws_iam_instance_profile.iam_instance_profile.name
    name = var.launch-configuration-name
}

resource "aws_autoscaling_group" "webapp-autoscaling-group" {
  launch_configuration = aws_launch_configuration.webapp-launch-config.name
  vpc_zone_identifier = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id, aws_subnet.subnet-3.id]
  min_size = var.min-scale-value
  max_size = var.max-scale-value
  default_cooldown = 60
  desired_capacity = var.desired-capacity
  name = var.autoscale-group-name
  health_check_type    = var.health-checkup-type
  tag {
    key                 = "Name"
    value               = var.autoscale-group-name
    propagate_at_launch = true
  }
  target_group_arns = [aws_lb_target_group.target-group-lb.arn]
}

resource "aws_security_group" "load-balancer-security-group" {
  name        = var.load-balancer-security-group-name
  description = "Allow HTTP traffic to instances through Elastic Load Balancer"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = var.http-port
    to_port     = var.http-port
    protocol    = var.protocol-tcp
    cidr_blocks = var.cidr_sg
  }

  egress {
    from_port       = var.egres_port
    to_port         = var.egres_port
    protocol        = var.egress-protocol
    cidr_blocks     = var.cidr_sg
  }

  tags = {
    Name = "Allow HTTP through ELB Security Group"
  }
}

resource "aws_lb" "webapp-elb" {
  name = var.load-balancer-name
  internal = false
  load_balancer_type = var.load-balancer-type
  security_groups = [
    aws_security_group.load-balancer-security-group.id
  ]
  subnets = [
    aws_subnet.subnet-1.id,
    aws_subnet.subnet-2.id,
    aws_subnet.subnet-3.id]

}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.webapp-elb.arn
  port = var.http-port
  protocol = var.http-protocol
  default_action {
    type = var.listener-action
    target_group_arn = aws_lb_target_group.target-group-lb.arn
  }
}

resource "aws_autoscaling_policy" "webserver-scale-policy-up" {
  name = var.webapp-scaleup-policy-name
  scaling_adjustment = var.webapp-scaleup-adjustment
  adjustment_type = var.webapp-scaleup-type
  cooldown = var.webapp-scale-cooldown
  autoscaling_group_name = aws_autoscaling_group.webapp-autoscaling-group.name
}

resource "aws_autoscaling_policy" "webserver-scale-policy-down" {
  name = var.webapp-scaledown-policy-name
  scaling_adjustment = var.webapp-scaledown-adjustment
  adjustment_type = var.webapp-scaleup-type
  cooldown = var.webapp-scale-cooldown
  autoscaling_group_name = aws_autoscaling_group.webapp-autoscaling-group.name
}

resource "aws_cloudwatch_metric_alarm" "cpu-high" {
  alarm_name = var.cpu-high-alarm-name
  comparison_operator = var.cpu-alarm-high-threshold
  evaluation_periods = var.cloud-watch-evaluation-periods
  metric_name = var.cloud-watch-metric-name
  namespace = var.cloud-watch-metric-namespace
  period = var.cloud-watch-metric-period
  statistic = var.cloud-watch-metric-statistics
  threshold = var.cloud-watch-metric-high-threshold
  alarm_description = "This metric monitors cpu high utilization"
  alarm_actions = [
    aws_autoscaling_policy.webserver-scale-policy-up.arn
  ]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp-autoscaling-group.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu-low" {
  alarm_name = var.cpu-low-alarm-name
  comparison_operator = var.cpu-alarm-low-threshold
  evaluation_periods = var.cloud-watch-evaluation-periods
  metric_name = var.cloud-watch-metric-name
  namespace = var.cloud-watch-metric-namespace
  period = var.cloud-watch-metric-period
  statistic = var.cloud-watch-metric-statistics
  threshold = var.cloud-watch-metric-low-threshold
  alarm_description = "This metric monitors cpu low utilization"
  alarm_actions = [
    aws_autoscaling_policy.webserver-scale-policy-down.arn
  ]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp-autoscaling-group.name
  }
}

data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "elb_alias" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.route53-recode-name
  type    = var.route53-recode-type
  alias {
    name                   = aws_lb.webapp-elb.dns_name
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}

resource "aws_lb_target_group" "target-group-lb" {
  name     = var.lb-target-group-name
  target_type = var.lb-target-group-type
  vpc_id =  aws_vpc.vpc.id
  port        = var.application-port
  protocol    = var.http-protocol
  health_check {
    healthy_threshold   = var.healthy-threshold
    unhealthy_threshold = var.unhealthy-threshold
    timeout             = var.health-checkup-timeout
    interval            = var.health-checkup-interval
    path                = var.health-checkup-path
    port                = var.application-port
  }
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name = aws_codedeploy_app.code_deploy_app.name
  deployment_group_name = var.code-deploy-application-group-name
  service_role_arn = aws_iam_role.code-deploy-service-role.arn
  auto_rollback_configuration {
    enabled = true
    events = [
      var.deployment-failure-event]
  }
  ec2_tag_set {
    ec2_tag_filter {
      key = var.filter-key
      type = var.filter-type
      value = var.autoscale-group-name
    }
  }
  deployment_style {
    deployment_type = var.deployment-type
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
  }
  autoscaling_groups = [aws_autoscaling_group.webapp-autoscaling-group.name]
  load_balancer_info {
    target_group_info {
      name = aws_lb_target_group.target-group-lb.name
    }
  }
}