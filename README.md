# Terraform + Ansible Sandbox (WS2019) - CI/CD learning workspace

This workspace creates two Windows Server 2019 VMs (DC01 and WS01) in Azure and configures them using Ansible via GitHub Actions.

## What this creates
- Resource Group (default: `rg-sandbox`)
- Virtual Network + Subnet
- Network Security Group allowing RDP (3389), WinRM (5985) from `allowed_cidr` and HTTP (80) from the internet
- Public IPs (Standard SKU) assigned to both VMs
- Two Windows 2019 VMs: `DC01` and `WS01`
- CustomScriptExtension on each VM to enable WinRM and firewall rules so Ansible can connect

## Ansible configuration
- `ansible/dc01.yml` - installs AD-Domain-Services and DNS feature on DC01
- `ansible/ws01.yml` - installs IIS + management tools and creates a test `index.html` showing the host IP

## Before you run
1. Create an Azure Service Principal (or use existing) and note: clientId, clientSecret, subscriptionId, tenantId.
2. Create a storage account + container for Terraform state (or use existing):
   - Resource Group for backend (example): `rg-terraform-state`
   - Storage account name (example): `jumbodatastr1981`
   - Container name (example): `tfstate`

3. Push this repo to GitHub **main** branch.

4. Add GitHub Secrets (Repository → Settings → Secrets and variables → Actions):
   - `ARM_CLIENT_ID`         (service principal clientId)
   - `ARM_CLIENT_SECRET`     (service principal secret)
   - `ARM_SUBSCRIPTION_ID`   (subscription id)
   - `ARM_TENANT_ID`         (tenant id)
   - `VM_ADMIN_PASSWORD`     (VM local admin password to be used by Ansible)
   - `AZURE_BACKEND_RG`      (resource group that contains the storage account for tfstate)
   - `AZURE_BACKEND_STORAGE` (storage account name)
   - `AZURE_BACKEND_CONTAINER` (container name)

## How to run (high level)
1. Push to `main` on GitHub. The workflow `.github/workflows/ci-cd.yml` will:
   - Run Terraform (init, plan, apply)
   - Save outputs and upload artifact
   - Run Ansible jobs to configure DC01 and WS01

## Notes & security
- `allowed_cidr` defaults to `0.0.0.0/0` for testing convenience. **Change to your office IP/32 before production**.
- The Custom Script Extension configures WinRM (HTTP, unencrypted + Basic) for demo/testing only; for production use HTTPS + certificates and secure authentication methods.
- Consider using Azure Key Vault / GitHub Encrypted Secrets and least privilege for Service Principal.
