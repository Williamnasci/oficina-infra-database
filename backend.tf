# Backend remoto compartilhado entre oficina-infra-database e oficina-infra-k8s.
# Bucket criado uma unica vez fora do Terraform (bootstrap manual) para evitar o
# problema de "ovo e galinha" de um backend gerenciado pelo proprio Terraform que
# ele referencia. Locking nativo do S3 (sem DynamoDB) requer Terraform >= 1.10.
terraform {
  backend "s3" {
    bucket       = "oficina-tfstate-778031418843"
    key          = "database/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }
}
