# Blog Website — Terraform Infrastructure

This guide walks you through the complete setup and deployment of the AWS infrastructure for the Blog Website using Terraform.

---

## Architecture Overview

Our infrastructure is designed to be highly available, secure, and scalable. Depending on the environment, it provisions the following components:

- **Frontend Hosting:** S3 bucket for static website hosting distributed globally via CloudFront (CDN).
- **Network (VPC):** Custom VPC with public and private subnets, ensuring secure isolation of resources (Prod only).
- **Backend Compute:** Elastic Kubernetes Service (EKS) for container orchestration, running backend microservices.
- **Database:** Amazon RDS in private subnets for secure, reliable data storage.
- **Container Registry:** Elastic Container Registry (ECR) for storing Docker images.
- **Bastion Host:** EC2 instance in a public subnet for secure access to private resources.
- **DNS & SSL:** Route 53 for DNS routing and ACM for automated SSL/TLS certificate management.

*Note: Some resources (like VPC, RDS, EC2, and EKS) are provisioned conditionally based on the environment (e.g., only in production) to optimize costs.*

---

## Prerequisites & Setup

### Step 1 — Install AWS CLI

The AWS Command Line Interface (CLI) is required to interact with AWS services from your terminal.

1. Download the AWS CLI installer for your OS from the [official AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

2. **Windows:** Run the downloaded `.msi` installer and follow the setup wizard.

3. **macOS / Linux:** Follow the platform-specific instructions in the AWS docs.

4. Verify the installation:
   ```bash
   aws --version
   ```
   You should see output similar to:
   ```
   aws-cli/2.x.x Python/3.x.x ...
   ```

---

### Step 2 — Install Terraform

Terraform is the Infrastructure-as-Code tool used to provision and manage AWS resources.

1. Download the appropriate Terraform binary for your OS from [https://developer.hashicorp.com/terraform/downloads](https://developer.hashicorp.com/terraform/downloads).

2. **Windows:**
   - Extract the `.zip` file and move `terraform.exe` to a directory included in your system `PATH` (e.g., `C:\Program Files\Terraform\`).
   - Add that directory to your environment variables `PATH`.

3. **macOS (via Homebrew):**
   ```bash
   brew tap hashicorp/tap
   brew install hashicorp/tap/terraform
   ```

4. **Linux:**
   ```bash
   sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
   wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   sudo apt update && sudo apt install terraform
   ```

5. Verify the installation:
   ```bash
   terraform -version
   ```
   You should see output similar to:
   ```
   Terraform v1.x.x
   ```

---

### Step 3 — Configure AWS Credentials

Use the `aws configure` command to provide your AWS account credentials. This allows Terraform (via the AWS provider) to authenticate and manage resources in your account.

Run the following command in your terminal:

```bash
aws configure
```

You will be prompted to enter the following:

```
AWS Access Key ID [None]:       <your-access-key-id>
AWS Secret Access Key [None]:   <your-secret-access-key>
Default region name [None]:     <your-aws-region>       # e.g., us-east-1
Default output format [None]:   json
```

> **Where to find your credentials:**
> Log in to the AWS Management Console → Click your username (top-right) → **Security credentials** → **Access keys** → Create a new access key.

> ⚠️ **Security Note:** Never commit your AWS credentials to version control. Use `.gitignore` to exclude any files containing secrets.

---

## Deployment

This project uses **Terraform Workspaces** to manage different environments (e.g., `staging`, `prod`) with their respective state files. Environment-specific variables are stored in the `environments/` directory.

### Staging Environment

The staging environment provisions a lightweight version of the infrastructure, primarily focusing on frontend components and ECR to save costs.

1. **Create and switch to the staging workspace:**
   ```bash
   terraform workspace new staging
   ```
   *(If the workspace already exists, use `terraform workspace select staging`)*

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Plan and Apply:**
   ```bash
   terraform apply -var-file="environments/staging.tfvars"
   ```

### Production Environment

The production environment provisions the complete infrastructure, including the VPC, EKS cluster, RDS database, and EC2 instances.

1. **Create and switch to the prod workspace:**
   ```bash
   terraform workspace new prod
   ```
   *(If the workspace already exists, use `terraform workspace select prod`)*

2. **Initialize Terraform (if not already initialized):**
   ```bash
   terraform init
   ```

3. **Plan and Apply:**
   ```bash
   terraform apply -var-file="environments/prod.tfvars"
   ```


