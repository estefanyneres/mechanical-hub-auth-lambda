data "aws_vpc" "base" {
  filter {
    name   = "tag:Name"
    values = [var.projectName]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.base.id]
  }

  tags = {
    Tier = "private"
  }
}

data "aws_security_group" "lambda_auth" {
  filter {
    name   = "tag:Name"
    values = ["${var.projectName}-lambda-auth-sg"]
  }
}

data "aws_db_instance" "main" {
  db_instance_identifier = "${var.projectName}-db"
}
