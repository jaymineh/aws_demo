# EKS + ECR Deployment

In this project, I implemented an EKS (Elastic Kubernetes Search) cluster in AWS, with the addition of an ECR (Elastic Container Registry) and RDS instances running MySQL database. Additional steps (at my own discretion) are included to test the infrastructure if it was set up correctly. See infrastructure diagram below 

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

**Step 2**
---

