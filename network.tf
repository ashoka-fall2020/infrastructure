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
  name        = "application_security_group"
  description = "Allow HTTP, HTTPS and SSH traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH"
    from_port   = var.ssh-port
    to_port     = var.ssh-port
    protocol    = var.protocol-tcp
    cidr_blocks = var.cidr_sg
  }

  ingress {
    description = "HTTPS"
    from_port   = var.https-port
    to_port     = var.https-port
    protocol    = var.protocol-tcp
    cidr_blocks = var.cidr_sg
  }

  ingress {
    description = "HTTP"
    from_port   = var.http-port
    to_port     = var.http-port
    protocol    = var.protocol-tcp
    cidr_blocks = var.cidr_sg
  }

  ingress {
    description = "TCP Custom For Running Application"
    from_port   = var.application-port
    to_port     = var.application-port
    protocol    = var.protocol-tcp
    cidr_blocks = var.cidr_sg
  }

  egress {
    from_port   = var.egres_port
    to_port     = var.egres_port
    protocol    = var.egress-protocol
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
  role = aws_iam_role.iam_role.name
}

resource "aws_iam_role_policy_attachment" "user-attach" {
  role = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.webapps3.arn
}

resource "aws_key_pair" "ec2-key" {
  key_name   = var.ec2-keypair-name
  public_key = var.public-key
}

resource "aws_instance" "ec2_instance" {
  ami = var.ami
  instance_type = var.ec2-instance-type
  vpc_security_group_ids = [aws_security_group.application_security_group.id]
  subnet_id = aws_subnet.subnet-1.id
  root_block_device {
    volume_type = var.ec2-volume-type
    volume_size = var.ec2-volume-size
    delete_on_termination = var.ec2-delete_on_termination
  }
  associate_public_ip_address = true
  key_name               = aws_key_pair.ec2-key.key_name
  iam_instance_profile   = aws_iam_instance_profile.iam_instance_profile.name
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
  tags = {
    Name = var.ec2-name
  }
}

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

