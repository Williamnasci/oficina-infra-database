# oficina-infra-database

Infraestrutura do banco de dados gerenciado (via Terraform) do Tech Challenge Fase 3 (POSTECH). Parte do split de repositórios descrito em [ADR-0005](https://github.com/Williamnasci/oficina-api/blob/main/docs/adr/0005-split-de-repositorios.md), no repositório principal [`oficina-api`](https://github.com/Williamnasci/oficina-api).

## Propósito

Provisiona, via Terraform, a instância **Amazon RDS PostgreSQL** (`db.t3.micro`, single-AZ, Free Tier) usada tanto pela aplicação principal (`oficina-api`) quanto pela Lambda de autenticação (`oficina-lambda-auth`) — mesma base de dados, sem duplicação de dados de cliente.

Justificativa completa da escolha do motor/instância em [RFC-0002](https://github.com/Williamnasci/oficina-api/blob/main/docs/rfc/0002-escolha-do-banco-de-dados-gerenciado.md). Diagrama ER e explicação dos relacionamentos em [database-er.md](https://github.com/Williamnasci/oficina-api/blob/main/docs/database-er.md).

## Tecnologias

- Terraform
- Amazon RDS (PostgreSQL)
- AWS Secrets Manager (credenciais de conexão)
- GitHub Actions (CI/CD)

## Status

🚧 Em construção. Estrutura de repositório e branch protection configuradas; o schema Prisma existente em `oficina-api/prisma/schema.prisma` será aplicado contra o endpoint RDS assim que a instância for provisionada.

## Deploy e execução

_A preencher assim que o pipeline de CI/CD e o deploy estiverem funcionais._
