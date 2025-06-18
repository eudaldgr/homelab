# 🚀 Backblaze B2 Bootstrap per Terraform State

Aquest mòdul crea el bucket i la clau d'accés necessaris per guardar els fitxers `terraform.tfstate` de manera remota a Backblaze B2 (S3-compatible).

## 📁 Contingut

Aquesta configuració fa:

- ✅ Creació d’un bucket privat amb xifrat SSE-B2
- ✅ Creació d’una `application_key` amb permisos restringits al bucket
- ✅ Exportació d’ID del bucket i claus per ser usades com a backend remot

## 🔐 Requisits

Has de tenir una **clau mestra (master application key)** del teu compte Backblaze:

- `master_key_id`
- `master_key`

## 📦 Variables

| Nom              | Descripció                                 | Tipus   | Requerit  |
|------------------|--------------------------------------------|---------|-----------|
| `master_key_id`  | ID de la clau mestra                       | string  | ✅        |
| `master_key`     | Clau secreta de l'`application_key` mestra | string  | ✅        |
| `bucket_name`    | Nom del bucket a crear                     | string  | ✅        |

## ▶️ Ús

### 1. Exporta les variables d'entorn

```sh
export B2_APPLICATION_KEY_ID="your-master-key-id"
export B2_APPLICATION_KEY="your-master-key"
```

### 2. Executa Terraform

```sh
tofu -chdir=infra/bootstrap init
tofu -chdir=infra/bootstrap apply \
  -var="bucket_name=tofu-state"
```

## 📤 Outputs

Un cop aplicat, obtindràs:

- `bucket_id` — ID intern del bucket
- `application_key_id` — ID de la clau específica pel backend
- `application_key` — Clau secreta (sensitive)

## ➕ Exemple per configurar el backend en altres mòduls

```hcl
terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://s3.eu-central-003.backblazeb2.com"
    }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    region     = "us-east-1"
    bucket     = "tofu-state"
    key        = "infra/hetzner/k3s-ghost/terraform.tfstate"
  }
}
```

## 🛟 Nota de seguretat

- La `application_key` generada té permisos mínims i està lligada al bucket.
- No versionis `terraform.tfstate` ni sortides sensibles!

## 🧠 Extensió futura

Pots afegir:

- Regles de lifecycle
- Polítiques de versions
- Arxius inicials al bucket (amb `b2_bucket_file_version`)