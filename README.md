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

✅ Terraform completo (RDS `db.t3.micro`, security group fail-closed, segredo no Secrets Manager). Ainda não aplicado contra a conta AWS real — ver seção abaixo.

## Deploy e execução

### Pré-requisitos (uma vez só)

1. Bucket S3 de backend remoto (compartilhado com `oficina-infra-k8s`) — ver instruções no `oficina-api` (`docs/phase-3-plan.md`).
2. Secrets do repositório GitHub (Settings → Secrets and variables → Actions):
   - `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` — credenciais de um usuário/role IAM com permissão para RDS, EC2 (SG), Secrets Manager e o bucket de state. **Não usar as credenciais root.**

### Local

```bash
cp terraform.tfvars.example terraform.tfvars
# edite allowed_cidr_blocks com o IP publico da EC2 (saida de oficina-infra-k8s)
terraform init
terraform plan
terraform apply
```

### CI/CD

`.github/workflows/terraform.yml`: `terraform plan` em todo PR; `terraform apply` automático ao mergear em `main` (job `apply`, ambiente `production`).

## Consumindo as credenciais

A aplicação (`oficina-api`) e a Lambda (`oficina-lambda-auth`) devem ler a connection string do Secrets Manager (`oficina/database/credentials`, chave `url`), não de variável de ambiente estática — evita duplicar a senha em múltiplos repositórios.
