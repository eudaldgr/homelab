# 🚀 AWS S3 Bootstrap per OpenTofu State

Aquest mòdul crea el bucket S3 necessari per guardar els fitxers `terraform.tfstate` de manera remota amb **S3 native locking** (sense necessitat de DynamoDB).

## 📁 Contingut

Aquesta configuració fa:

- ✅ Creació d'un bucket S3 privat amb xifrat AES256
- ✅ Habilita versionat del bucket per mantenir historial
- ✅ Configuració de lifecycle per eliminar versions antigues automàticament
- ✅ S3 native locking amb `use_lockfile = true` (sense DynamoDB!)
- ✅ Bloqueig d'accés públic per seguretat màxima

## 🔐 Requisits

Has de tenir **credencials AWS** configurades:

- Variable d'entorn: `AWS_ACCESS_KEY_ID` i `AWS_SECRET_ACCESS_KEY`
- O perfil AWS: `aws configure`
- O IAM role si executes des d'EC2

## 📦 Variables

| Nom                    | Descripció                          | Tipus  | Per defecte               |
| ---------------------- | ----------------------------------- | ------ | ------------------------- |
| `bucket_name`          | Nom del bucket S3 a crear           | string | `e17n-homelab-tofu-state` |
| `aws_region`           | Regió AWS on crear els recursos     | string | `eu-west-3`               |
| `state_retention_days` | Dies per mantenir versions antigues | number | `30`                      |

## ▶️ Ús

### 1. Configura les credencials AWS

```sh
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
```

### 2. Executa OpenTofu

```sh
tofu -chdir=infra/bootstrap/backend init
tofu -chdir=infra/bootstrap/backend apply
```

### 3. Obté la configuració del backend

```sh
tofu -chdir=infra/bootstrap/backend output backend_config
```

## 📤 Outputs

Un cop aplicat, obtindràs:

- `s3_bucket_name` — Nom del bucket S3 creat
- `s3_bucket_arn` — ARN del bucket S3
- `aws_region` — Regió AWS utilitzada
- `backend_config` — Configuració completa per usar en altres mòduls

## ➕ Exemple per configurar el backend en altres mòduls

```hcl
terraform {
  backend "s3" {
    bucket      = "e17n-homelab-tofu-state"
    key         = "infra/home.arpa/fgs/pve/terraform.tfstate"
    region      = "eu-west-3"
    encrypt     = true
    use_lockfile = true
  }
}
```

## 🔒 S3 Native State Locking

Amb OpenTofu v1.10+ i `use_lockfile = true`, obtens:

- 🔐 **Bloqueja l'estat** automàticament amb S3 conditional writes
- ⏱️ **Espera** si un altre procés està modificant l'estat
- 🚫 **Evita modificacions concurrents** sense necessitat de DynamoDB
- ✅ **Desbloqueja** automàticament quan acaba l'operació
- 💰 **Més econòmic** - no cal pagar DynamoDB!

## 🛟 Nota de seguretat

- El bucket S3 té **accés públic completament bloquejat**
- Les versions antigues s'**eliminen automàticament** després de 30 dies
- Usa **xifrat AES256** per totes les dades
- **S3 native locking** evita la necessitat de recursos addicionals
- No versionis `terraform.tfstate` ni outputs sensibles!

## 🧠 Funcionalitats addicionals

- **Lifecycle policy**: Elimina versions antigues automàticament
- **Multipart upload**: Gestió automàtica de fitxers grans
- **Cross-region replication**: Pots habilitar-ho per màxima durabilitat
