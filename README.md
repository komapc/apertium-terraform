# Terraform — extractor-results S3 bucket

This configuration manages **only** the S3 bucket for extractor results (`s3.tf`).

The production APy server (i-056c20a3f393e9982, t3.micro, eu-west-1, **no EIP**) was
created out of band and is not in Terraform state. The old EC2 / EIP / security-group /
key-pair / EventBridge definitions were removed (#14) so `terraform apply` can't create a
duplicate server. Never stop/start that box (its public IP would change) — reboot only.
Operating it is documented in `translator/RUNBOOK.md`.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # optional; defaults are fine
terraform init
terraform plan
terraform apply
```

| Variable | Default | |
|---|---|---|
| `aws_region` | `eu-west-1` | |
| `project_name` | `ido-epo-translator` | bucket name prefix |
| `create_s3_bucket` | `true` | |

State is local (`terraform.tfstate`, gitignored).
