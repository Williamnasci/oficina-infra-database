data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_security_group" "rds" {
  name        = "${var.db_identifier}-sg"
  description = "Acesso a PostgreSQL (5432) para a aplicacao e a Lambda de autenticacao"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_allowed_cidrs" {
  for_each = toset(var.allowed_cidr_blocks)

  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = each.value
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
  description       = "CIDR autorizado explicitamente via var.allowed_cidr_blocks"
}

data "aws_security_group" "cluster_host" {
  filter {
    name   = "group-name"
    values = ["oficina-cluster-sg"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_cluster_host" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = data.aws_security_group.cluster_host.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "EC2 do cluster Kind (oficina-infra-k8s) - mesma VPC, trafego usa IP privado"
}

resource "aws_vpc_security_group_ingress_rule" "postgres_open_for_lambda_auth" {
  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
  description       = "ABERTO GLOBALMENTE para viabilizar oficina-lambda-auth (fora de VPC) - ver ADR-0006"
}

resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_instance" "postgres" {
  identifier     = var.db_identifier
  engine         = "postgres"
  engine_version = var.db_engine_version

  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.master.result
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = var.publicly_accessible

  multi_az                = false
  backup_retention_period = var.db_backup_retention_days
  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.db_identifier}-final"
  apply_immediately         = true

  parameter_group_name = aws_db_parameter_group.force_ssl.name
}

resource "aws_db_parameter_group" "force_ssl" {
  name   = "${var.db_identifier}-force-ssl"
  family = "postgres16"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "oficina/database/credentials"
  description = "Credenciais de conexao ao RDS PostgreSQL (oficina-infra-database)"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.master.result
    host     = aws_db_instance.postgres.address
    port     = aws_db_instance.postgres.port
    dbname   = var.db_name
    url = "postgresql://${var.db_username}:${urlencode(random_password.master.result)}@${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${var.db_name}?schema=public&sslmode=require"
  })
}
