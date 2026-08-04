variable "aws_region" {
  description = "Região AWS. Fixa em us-east-2 por decisão de projeto (ver docs/rfc/0001-escolha-da-nuvem.md no oficina-api)."
  type        = string
  default     = "us-east-2"
}

variable "db_identifier" {
  description = "Identificador da instância RDS."
  type        = string
  default     = "oficina-db"
}

variable "db_name" {
  description = "Nome do banco de dados criado na instância."
  type        = string
  default     = "oficina_db"
}

variable "db_username" {
  description = "Usuário master do banco."
  type        = string
  default     = "oficina_admin"
}

variable "db_instance_class" {
  description = "Classe da instância RDS. db.t3.micro é elegível ao Free Tier (750h/mês nos primeiros 12 meses)."
  type        = string
  default     = "db.t3.micro"
}

variable "db_engine_version" {
  description = "Versão do engine PostgreSQL. 16.4 nao esta mais disponivel na regiao/conta; 16.14 e a mais recente da serie 16 (compativel com o parameter group family postgres16)."
  type        = string
  default     = "16.14"
}

variable "db_allocated_storage" {
  description = "Armazenamento em GB. 20GB é o limite do Free Tier."
  type        = number
  default     = 20
}

variable "db_backup_retention_days" {
  description = "Dias de retenção de backup automático. Contas novas em Free Tier tem um teto mais baixo do que os 7 dias normalmente permitidos (a API rejeita em runtime se exceder); 1 é o valor seguro."
  type        = number
  default     = 1
}

variable "publicly_accessible" {
  description = <<-EOT
    Se true, a instância recebe um endpoint público. Necessário neste projeto porque a
    Lambda de autenticação (oficina-lambda-auth) roda fora de uma VPC (evita o custo de
    NAT Gateway, que não é Free Tier) e precisa alcançar o banco pela internet. O acesso
    de rede continua restrito pelo security group (var.allowed_cidr_blocks), não por
    isolamento de VPC. Ver ADR-0006 no oficina-api para a justificativa completa do trade-off.
  EOT
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = <<-EOT
    Lista de CIDRs autorizados a conectar na porta 5432. Vazio por padrão (fail-closed) —
    é responsabilidade de quem aplica o Terraform adicionar explicitamente o IP da EC2
    (oficina-infra-k8s) e qualquer IP de desenvolvimento/migração necessário. Não usar
    0.0.0.0/0 sem justificativa documentada.
  EOT
  type        = list(string)
  default     = []
}
