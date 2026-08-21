variable "projectName" {
  default = "mechanical-hub"
}

variable "region_default" {
  default = "us-east-1"
}

variable "aws_account_id" {
  description = "ID da conta AWS Academy (muda a cada bimestre da pos-graduacao)"
  type        = string
}

variable "db_username" {
  description = "Usuario administrador do banco de dados RDS"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Senha do banco de dados RDS"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "Segredo usado para assinar o JWT (mesmo valor do repo da aplicacao)"
  type        = string
  sensitive   = true
}

variable "tags" {
  default = {
    School      = "FIAP"
    Environment = "Production"
  }
}

locals {
  labRole = "arn:aws:iam::${var.aws_account_id}:role/LabRole"
}
