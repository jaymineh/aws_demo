# EKS + ECR Deployment

In this project, I implemented an EKS (Elastic Kubernetes Search) cluster in AWS, with the addition of an ECR (Elastic Container Registry) and RDS instances running MySQL database. High availability is taken into consideration in this project to increase reliability of the cluster and the rest infrastructure. Additional steps (at my own discretion) are included to test the infrastructure if it was set up correctly. See infrastructure diagram below:

![AWS Infrastructure](images/prophiusinfra.png)

***Prerequisites***
*It is assumed that the user already possesses an AWS account and has these tools installed on their local machine: VS code (or any other IDE), Kubernetes CLI, Terraform & Docker*

*Also note that my comments and observations would be included at intervals during the project and not necessarily at the end. Enjoy the ride ;)*

**Step 1 - Create S3 bucket to host TF state file**
---

- Create a new file called `bucket.tf` and input the code block below:

```
# Create s3 bucket
resource "aws_s3_bucket" "prophius-bucket-aws" {
  bucket = "prophius-bucket"
  force_destroy = true
}

# Enable versioning on s3 bucket
resource "aws_s3_bucket_versioning" "version" {
  bucket = aws_s3_bucket.prophius-bucket-aws.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption for s3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "first" {
  bucket = aws_s3_bucket.prophius-bucket-aws.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

- Run `terraform init` to initialize terraform. After that, run `terraform apply` to start the bucket creation.

- Add the following code below to create create terraform locks using DynamoDB. *This helps to retain the integrity of the terraform state file when it has been deployed to the cloud to be worked on by a group of engineers.*

```
#Create dynamo DB for terraform locks
resource "aws_dynamodb_table" "prophius_locks_aws" {
  name         = "prophius-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
```

- Run `terraform apply` to run the configuration.

- Afrer the lock has been created, create a file called `backend.tf`. This will house the code where terraform is instructed to push the state file to the s3 bucket. *This came after the creation because Terraform expects that the bucket and other dependencies be set up before it pushes the state* Insert the code below:

```
# Push state file to cloud
terraform {
  backend "s3" {
    bucket         = "prophius-buck"
    key            = "prophius/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "prophius-locks"
    encrypt        = true
  }
}
```

![StateFile](images/statefile.png)

**Step 2 - Create VPC & Subnets**
---

*The VPC is the "house" that will host your subnets, instances, databases etc. It is a virtual network that resources in AWS need to be deployed in before they can communicate*

- Create a new file called `vpc.tf` and paste in the code below. The code will create the vpc and the public and private subnets:

```
# VPC Creation
resource "aws_vpc" "prophius" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "prophius"
    }
}

# Create public subnets
resource "aws_subnet" "public" {
    count = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets
    vpc_id = aws_vpc.prophius.id
    cidr_block = "40.0.${count.index + 10}.0/24"
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = "publicSubnet${count.index + 1}"
    }
}

# Create private subnets
resource "aws_subnet" "private" {
    count = var.preferred_number_of_private_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets
    vpc_id = aws_vpc.prophius.id
    cidr_block = "40.0.${count.index + 20}.0/24"
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
       Name = "privateSubnet${count.index + 1}"
    }
}
```

![VPC](images/vpc.png)

**Step 3 - Create IGW & NAT gateway**
---

*The internet gateway in this scenario is used to reach the EKS clusters over the internet. I took some extra steps which will be explained later and installed kubernetes on my local PC to manage the EKS clusters from the terminal without going to the AWS portal. An alternative can be used to achieve this and it is called VPC endpoints. However, I opted to using an internet gateway*

- Create a file called `igw.tf` and paste in the code below to create the internet gateway.

```
# Create IGW
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.prophius.id

  tags = {
      Name = format("%s-%s-%s!", var.name, aws_vpc.prophius.id, "IG")
  }
}
```

- Create a new file called `nat-gw.tf`. The code below which will be pasted in the file creates an elastic IP which will be used by the EKS worker nodes to communicate with the cluster. Since the worker nodes are placed in a private subnet, they need a NAT gateway to reach the EKS clusters. See code below:

```
# Create EIP for NAT
resource "aws_eip" "nat_eip" {
    domain = "vpc"
    depends_on = [aws_internet_gateway.ig]

    tags = {
        Name = "NAT EIP"
    }
}

# Create NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = element(aws_subnet.public.*.id, 0)
  depends_on = [aws_internet_gateway.ig]

  tags = {
    Name = "NAT GW"
  }
}
```

**Step 4 - 
---

-
