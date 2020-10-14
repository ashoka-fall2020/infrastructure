# Infrastructure as Code
## Project Description
 Set up a VPC that can be used to launch EC2 instance using Terraform
## Requirement
1. Terraform
2. AWS CLI
3. AWS account
## Project set up and Build
1. Clone the project from https://github.com/ashoka-fall2020/infrastructure.git
2. Open the terminal
3. Install AWS CLI https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
4. Configure aws dev profile by running the command `aws config --profile dev` and provide your `AWS Access Key ID`, `AWS Secret Access Key`,
`Default region name` as `us-east-1` and `Default output format` as `json`
5. Configure aws prod profile by running the command `aws config --profile prod` and provide your `AWS Access Key ID`, `AWS Secret Access Key`,
`Default region name` as `us-east-1` and `Default output format` as `json`
6. Go to the directory infrastructure
7. Run the command `export AWS_PROFILE=dev`
8. Create a `var.tfvars` file in the directory and give the values for the keys 
`region`, `cidr_vpc`, `subnets_cidr` as a list of 3 CIDR, 
`availability_zones` as a list of 3 availability zones of your region
9. Run the  following commands
````
terraform init
terraform plan -var-file="var.tfvars"
terraform apply -var-file="var.tfvars"
````
The VPC will be generated and available in your AWS account\
Use the command `terraform destroy` to delete the vpc
## Deploy
Go to your AWS account and launch an instance with the generated VPC




 
   


   