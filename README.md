# Terraform + Ansible CI/CD Workspace

This workspace provisions two Windows Server 2019 VMs on Azure and configures them with Ansible using GitHub Actions CI/CD.

## Files
- terraform/: Terraform configuration (RG, VNet, Subnet, NSG, Public IPs, NICs, Windows VMs)
- ansible/: Playbooks and inventory template
- .github/workflows/ci-cd.yml: CI/CD pipeline

## Before you run
1. Create Azure Storage backend (resource group, storage account, container) for Terraform state.
2. Add GitHub Secrets (Repository → Settings → Secrets and variables → Actions):
   - ARM_CLIENT_ID         (your service principal client id)
   - ARM_CLIENT_SECRET     (your service principal secret)
   - ARM_SUBSCRIPTION_ID   (your subscription id)
   - ARM_TENANT_ID         (your tenant id)
   - VM_ADMIN_PASSWORD     (password for Windows VMs)
   - AZURE_BACKEND_RG      (resource group that contains storage account)
   - AZURE_BACKEND_STORAGE (storage account name)
   - AZURE_BACKEND_CONTAINER (container name)

## How the pipeline works
1. Terraform job: initializes (with backend from secrets), plans and applies.
2. Outputs are saved and uploaded as artifact.
3. Ansible job: downloads outputs, creates inventory.ini, runs playbooks against the VMs.

## Notes
- Set `variable "allowed_cidr"` in terraform/variables.tf to your office/home IP (CIDR) for production to restrict RDP/WinRM.
- The pipeline uses WinRM (5985) for Ansible to connect to Windows VMs; you may need to configure WinRM and Firewall on the VMs (terraform allows NSG rule, but Windows firewall must allow it).

