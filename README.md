# Technical Assignment

## 1. Why was this specific VM type chosen?

The VM size `Standard_B2ms` was selected due to its optimal balance between cost and performance. It offers **2 vCPUs** and **8 GB of RAM**, sufficient for comfortably running the Grafana monitoring stack (including Grafana, Prometheus, and Loki) on a Linux server. This sizing ensures stable operation without unnecessary resource overhead, aligning with best practices for lightweight to medium workloads like monitoring services.

---

## 2. Were all necessary resources created to ensure the VM is accessible?

**Yes.** To guarantee accessibility, the following essential resources were created:

- **Virtual Network (VNet)** and **Subnet** to logically isolate the VM.
- **Public IP** to enable direct SSH access from the internet.
- **Network Security Group (NSG)** explicitly allowing inbound traffic only for required ports:
  - **SSH** (`TCP/22`) for secure remote administration.
  - **Grafana** (`TCP/3000`), **Prometheus** (`TCP/9090`), **Loki** (`TCP/3100`) for monitoring purposes.

This strict setup improves security by limiting VM exposure to only necessary endpoints.

---

## 3. Is the Terraform code parameterized to allow reuse across different environments?

**Yes**, the code is fully parameterized via `variables.tf`. Essential parameters like VM size, location, resource group name, admin credentials, and SSH keys can be easily modified using different `.tfvars` files or inline parameters. This allows the Terraform configuration to be effortlessly reused across multiple environments (development, staging, production) by simply changing variable values without modifying the core infrastructure code.

---

## 4. How can it be ensured that the VM is managed exclusively through Terraform?

Managing infrastructure exclusively via Terraform involves multiple strategies:

- **Strict Workflow**: Avoid manual changes through Azure Portal or CLI. Ensure any modification is performed through Terraform code and committed to source control.
- **State Enforcement**: Regularly run `terraform plan` to identify and correct drift between Terraform state and actual infrastructure.
- **Azure Policies & RBAC**: Implement Azure Policies to prevent direct manual resource manipulation. Using Azure RBAC, limit user permissions strictly to **Reader** roles for production resources, while only granting **Contributor** access to automated service principals or select engineers responsible for running Terraform. This prevents accidental or unauthorized manual changes.

Together, these approaches help maintain consistency and control over your infrastructure management lifecycle.

---

## 5. What modifications are needed to make the code suitable for a team setup?

For a team-based setup, the Terraform workflow should consider:

### **Remote Backend with State Locking:**

Terraform stores its state file remotely (e.g., Azure Storage Account with Blob container as I have already done). State locking prevents multiple engineers from making concurrent conflicting changes.

**Example (`backend.tf`):**
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "confitechtfstateaccount "
    container_name       = "tfstate"
    key                  = "vm.tfstate"
  }
}
```
When one engineer runs terraform apply, Terraform locks the state file to prevent simultaneous modifications from another user.

- Secure Secrets Management:
For team-based usage, sensitive information such as SSH keys, credentials, or secrets should not be stored in plain text. Utilize Azure Key Vault integrated with Terraform (azurerm_key_vault_secret), or environment variables securely managed by the team's CI/CD system (Azure DevOps variable groups).

- Branching Strategy & Code Reviews:
Implement a proper Git branching model (e.g., GitFlow or Trunk-based Development) with mandatory code reviews, ensuring that all infrastructure changes are peer-reviewed and approved before execution.

- Documentation & Communication:
Clearly document Terraform workflows, including instructions for initialization, applying changes, managing state, handling secrets, and responding to issues.

## 6. How can the correct order of creating interdependent resources be ensured?

Terraform automatically manages resource dependencies by evaluating references within your configuration. When a resource references attributes of another resource, Terraform implicitly knows the correct creation order. For example, a VM depends on a Network Interface, which in turn depends on Subnets and VNets.

Explicit dependencies (depends_on) can also be defined to ensure Terraform's resource creation order explicitly when implicit dependencies aren't sufficient.

## 7. How can this code be executed automatically? Which Terraform commands make sense in which scenarios?

Manual Execution (currently described):

```hcl
terraform init      # initialize the working directory and backend
terraform validate  # validate the configuration syntax
terraform plan      # preview planned changes
terraform apply     # deploy changes to infrastructure
```

Automation via Azure DevOps Pipeline (theoretical):

Pipeline Flow:
```hcl
1. terraform init (auto)
2. terraform validate (auto)
3. terraform plan (auto)
4. Manual approval step in Azure DevOps to review the plan.
5. terraform apply (manual or automated after approval)
```

## 8. What are the advantages and disadvantages of using Terraform?

Advantages:
- Infrastructure as Code (IaC): Repeatable, maintainable, predictable deployments.
- Platform Agnostic: Supports multiple cloud providers and services.
- State Management: Maintains state of deployed infrastructure for tracking.
- Reusable: Modules & variables enable reusable, composable code.
- Community & Ecosystem: Active community, vast number of existing modules, good documentation.

Disadvantages:
- State Management Complexity: Corrupted state files or state drift can be challenging to fix.
- Limited Imperative Actions: Terraform is declarative; certain imperative tasks (like complex migrations) are challenging to implement.
- Rollback Limitations: Terraform lacks built-in rollback; manual rollback via previous code versions is needed.
- Learning Curve: Requires knowledge of both cloud providers and Terraform concepts.