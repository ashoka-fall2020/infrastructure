variable "region" {
  description = "Region"
  type = string
}

variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  type = string
}

variable "subnets_cidr" {
  description = "CIDR block for the subnet"
  type = list(string)
}

variable "availability_zones" {
  description = "availability zone to create subnet1"
  type = list(string)
}

variable "cidr_route_table" {
  description = "CIDR block for the route table"
  type = string
  default = "0.0.0.0/0"
}

variable "ami" {
  description = "Custom AMI"
  type = string
}

variable "public-key" {
  description = "Dev AWS Key"
  type = string
}

variable "bucket-name" {
  description = "S3 Bucket Name"
  type = string
}

variable "s3-access-level" {
  description = "Access Level S3 Bucket"
  type = string
}

variable "rds-db-engine" {
  description = "RDS DB Engine"
  type = string
}

variable "rds-db-engine-version" {
  description = "RDS DB Engine Version"
  type = string
}

variable "rds-db-name" {
  description = "RDS DB Name"
  type = string
}

variable "rds-db-username" {
  description = "RDS DB Username"
  type = string
}

variable "rds-db-password" {
  description = "RDS DB Password"
  type = string
}

variable "rds-db-identifier" {
  description = "RDS DB Identifier"
  type = string
}

variable "rds-db-storage" {
  description = "RDS DB Storage"
  type = number
}

variable "rds-instance-class" {
  description = "RDS DB Instance Class"
  type = string
}

variable "ec2-instance-type" {
  description = "EC2 instance type"
  type = string
}

variable "ec2-volume-type" {
  description = "EC2 valume type"
  type = string
}

variable "ec2-volume-size" {
  description = "EC2 volume size"
  type = number
}

variable "ec2-delete_on_termination" {
  description = "EC2 delete on termination"
  type = string
}

variable "dynamodb-name" {
  description = "Dynamo DB Name"
  type = string
}

variable "dynamodb-hashkey" {
  description = "Dynamo DB Hash Key"
  type = string
}

variable "dynamodb-write-capacity" {
  description = "Dynamo DB Write Key"
  type = number
}

variable "dynamodb-read-capacity" {
  description = "Dynamo DB Read Key"
  type = number
}

variable "dynamodb-hashkey-type" {
  description = "Dynamo DB Hash Key Type"
  type = string
}

variable "ec2-keypair-name" {
  description = "EC2 key pair name"
  type = string
}

variable "ec2-name" {
  description = "EC2 name"
  type = string
}

variable "ec2-instance-profile-name" {
  description = "EC2 instance profile name"
  type = string
}

variable "ec2-iam-role-name" {
  description = "EC2 Iam role name"
  type = string
}

variable "ec2-iam-policy-name" {
  description = "EC2 Iam profile name"
  type = string
}

variable "db-subnet-group-name" {
  description = "DB subnet group name"
  type = string
}

variable "s3-bucket-name-storage" {
  description = "S3 bucket storage"
  type = string
}

variable "s3-bucket-sse-algo" {
  description = "S3 bucket storage"
  type = string
}

variable "protocol-tcp" {
  description = "TCP Protocol"
  type = string
}

variable "database-port" {
  description = "DB port"
  type = number
}

variable "application-port" {
  description = "Application port"
  type = number
}

variable "http-port" {
  description = "HTTP port"
  type = number
}

variable "https-port" {
  description = "HTTPS port"
  type = number
}

variable "ssh-port" {
  description = "SSH port"
  type = number
}

variable "db-security-group-name" {
  description = "Database security group name"
  type = string
}

variable "cidr_sg" {
  description = "CIDR block for the route table"
  type = list(string)
}

variable "egres_port" {
  description = "Egres port"
  type = number
}

variable "egress-protocol" {
  description = "Egres port"
  type = string
}

variable "codeploy-s3-bucket-name" {
  description = "S3 bucket storage name for code deploy"
  type = string
}

variable "aws-account-id" {
  description = "AWS account id"
  type = string
}

variable "aws-region" {
  description = "AWS region"
  type = string
}

variable "code-deploy-application-name" {
  description = "AWS deploy application name"
  type = string
}

variable "code-deploy-service-role-name" {
  description = "AWS code deploy service name"
  type = string
}

variable "code-deploy-ec2-s3-name" {
  description = "Code deploy policy name"
  type = string
}

variable "gh-upload-s3-policy-name" {
  description = "Code deploy policy name"
  type = string
}

variable "gh-code-deploy-name" {
  description = "Code deploy name"
  type = string
}

variable "ci-cd-user-name" {
  description = "Code deploy name"
  type = string
}

variable "public_dns_name" {
  description = "Public dns name"
  type = string
}

variable "code-deploy-application-group-name" {
  description = "AWS deploy application name"
  type = string
}

variable "route53-recode-name" {
  description = "Route 53 recode name"
  type = string
}

variable "route53-recode-type" {
  description = "Route 53 recode type"
  type = string
}

variable "route53-recode-ttl" {
  description = "Route 53 recode TTL"
  type = string
}

variable "route-53-zone-name" {
  description = "Route 53 zone name"
  type = string
}

variable "deployment-config-name" {
  description = "Deployment-Config-Name"
  type = string
}

variable "deployment-type" {
  description = "Deployment Type"
  type = string
}

variable "filter-key" {
  description = "EC2 Tag Filter Key"
  type = string
}

variable "filter-type" {
  description = "EC2 Tag Filter Type"
  type = string
}

variable "deployment-failure-event" {
  description = "Deployment failure event"
  type = string
}

variable "code-deploy-application-compute-platform" {
  description = "Application compute platform"
  type = string
}

variable "launch-configuration-name" {
  description = "Name of launch configuration"
  type = string
}

variable "autoscale-group-name" {
  description = "Name of auto scale group"
  type = string
}

variable "health-checkup-type" {
  description = "health checkup type"
  type = string
}

variable "load-balancer-security-group-name" {
  description = "Security group name"
  type = string
}
variable "http-protocol" {
  description = "HTTP PROTOCOL"
  type = string
}
variable "listener-action" {
  description = "Listener action"
  type = string
}

variable "webapp-scaleup-policy-name" {
  description = "Webapp scaleup policy name"
  type = string
}

variable "webapp-scaleup-adjustment" {
  description = "Webapp scaleup adjustment"
  type = number
}

variable "webapp-scaleup-type" {
  description = "Webapp scaleup type"
  type = string
}

variable "webapp-scale-cooldown" {
  description = "Webapp scale cooldown time"
  type = number
}

variable "webapp-scaledown-policy-name" {
  description = "Webapp scale down policy name"
  type = string
}

variable "webapp-scaledown-adjustment" {
  description = "Webapp scale down adjustment"
  type = number
}

variable "lb-target-group-name" {
  description = "Load balance target group name"
  type = string
}

variable "lb-target-group-type" {
  description = "Load balance target group type"
  type = string
}

variable "cpu-low-alarm-name" {
  description = "CPU Low Alarm name"
  type = string
}

variable "cpu-high-alarm-name" {
  description = "CPU high alarm name"
  type = string
}

variable "cpu-alarm-high-threshold" {
  description = "CPU high threshold"
  type = string
}

variable "cpu-alarm-low-threshold" {
  description = "CPU low threshold"
  type = string
}

variable "cloud-watch-metric-name" {
  description = "Cloud watch metric name"
  type = string
}

variable "cloud-watch-evaluation-periods" {
  description = "Cloud watch evaluation periods"
  type = string
}

variable "cloud-watch-metric-namespace" {
  description = "Cloud watch name space"
  type = string
}

variable "cloud-watch-metric-period" {
  description = "Cloud watch metric period"
  type = string
}

variable "cloud-watch-metric-statistics" {
  description = "Cloud watch statistics"
  type = string
}

variable "cloud-watch-metric-low-threshold" {
  description = "Cloud watch metric low threshold"
  type = string
}

variable "cloud-watch-metric-high-threshold" {
  description = "Cloud watch metric low threshold"
  type = string
}

variable "healthy-threshold" {
  description = "Cloud watch metric high threshold"
  type = number
}

variable "unhealthy-threshold" {
  description = "Cloud watch metric high threshold"
  type = number
}

variable "health-checkup-timeout" {
  description = "Health checkup timeout"
  type = number
}

variable "health-checkup-interval" {
  description = "Health checkup interval"
  type = number
}

variable "health-checkup-path" {
  description = "Health checkup path"
  type = string
}

variable "load-balancer-name" {
  description = "Load balancer name"
  type = string
}

variable "load-balancer-type" {
  description = "Load balancer type"
  type = string
}

variable "min-scale-value" {
  description = "auto scaling min value"
  type = string
}

variable "max-scale-value" {
  description = "auto scaling max value"
  type = string
}

variable "desired-capacity" {
  description = "Desired capacity"
  type = string
}