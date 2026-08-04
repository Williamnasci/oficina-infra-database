output "db_endpoint" {
  description = "Endpoint (host) da instância RDS."
  value       = aws_db_instance.postgres.address
}

output "db_port" {
  description = "Porta da instância RDS."
  value       = aws_db_instance.postgres.port
}

output "db_security_group_id" {
  description = "ID do security group do RDS — necessário para autorizar novas origens (ex: IP da EC2 do oficina-infra-k8s)."
  value       = aws_security_group.rds.id
}

output "db_secret_arn" {
  description = "ARN do segredo no Secrets Manager com as credenciais completas de conexão."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "database_url" {
  description = "Connection string completa (Prisma-compatible). Sensível — não expor em logs de CI."
  value       = "postgresql://${var.db_username}:${random_password.master.result}@${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${var.db_name}?schema=public&sslmode=require"
  sensitive   = true
}
