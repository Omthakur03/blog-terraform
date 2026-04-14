# Blog Website — Terraform Infrastructure

This guide walks you through the complete setup and deployment of the AWS infrastructure for the Blog Website using Terraform.

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

<!-- Add more steps below as the project grows -->
