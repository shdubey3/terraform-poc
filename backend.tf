################################################################################
# TERRAFORM BACKEND CONFIGURATION - COMPREHENSIVE GUIDE
################################################################################
#
# Terraform backends store state remotely to enable team collaboration and
# protect sensitive data. Below are detailed examples of different backend options
# suitable for multi-user and multi-environment scenarios.
#
################################################################################
# 1. LOCAL BACKEND (Default - Single Developer)
################################################################################
# Use case: Single developer, local development only
# Limitations: NO state locking, NO remote access, NOT safe for teams
# ⚠️  State file stored locally with sensitive data - DON'T commit to git!

# No explicit configuration needed - this is the default behavior
# State file created: terraform.tfstate (in your working directory)
# Backup: terraform.tfstate.backup

# WARNING: Never use in production or with multiple team members!


################################################################################
# 2. S3 BACKEND (Basic) - For Single Environment
################################################################################
# Use case: Simple projects, single environment
# Limitations: No state locking (race conditions possible with multiple users)
# When to use: Small projects, learning, single developer

# terraform {
#   backend "s3" {
#     bucket = "my-company-terraform-state"
#     key    = "vpc-project/terraform.tfstate"
#     region = "us-east-1"
#   }
# }

# How it works:
# - State file stored in S3 bucket: s3://my-company-terraform-state/vpc-project/terraform.tfstate
# - Anyone with AWS credentials can read/modify state
# - Concurrent applies can overwrite each other (no locking)
# - Good for backup and version control through S3 versioning


################################################################################
# 3. S3 BACKEND WITH DYNAMODB LOCKING (Recommended for Teams)
################################################################################
# Use case: Team environments, multi-user scenarios
# Locks: State locked during apply to prevent concurrent modifications
# When to use: Production environments, team collaboration

# terraform {
#   backend "s3" {
#     bucket           = "my-company-terraform-state"
#     key              = "dev/vpc-project/terraform.tfstate"
#     region           = "us-east-1"
#     encrypt          = true                    # Encrypt state in S3
#     dynamodb_table   = "terraform-state-lock" # DynamoDB for state locking
#   }
# }

# How it works:
# 1. State file stored in S3 (encrypted at rest)
# 2. When terraform apply/destroy runs:
#    - DynamoDB table "terraform-state-lock" is locked
#    - Only one user can modify state at a time
#    - Lock released after operation completes
#    - If process dies unexpectedly, lock expires after timeout
# 3. Prevents the "merge conflict" problem in Terraform

# DynamoDB Table Setup (AWS CLI):
# aws dynamodb create-table \
#   --table-name terraform-state-lock \
#   --attribute-definitions AttributeName=LockID,AttributeType=S \
#   --key-schema AttributeName=LockID,KeyType=HASH \
#   --billing-mode PAY_PER_REQUEST \
#   --region us-east-1

# Example directory structure for multi-environment:
# s3://my-company-terraform-state/
# ├── dev/vpc-project/terraform.tfstate
# ├── staging/vpc-project/terraform.tfstate
# └── prod/vpc-project/terraform.tfstate
#
# Each environment has:
# - Separate state files
# - Separate DynamoDB locks
# - Isolated changes (dev changes don't affect prod)


################################################################################
# 4. MULTI-ENVIRONMENT S3 + DYNAMODB SETUP (Alternative Approach)
################################################################################
# Use case: Multiple environments with shared DynamoDB lock
# Organization: One state file per environment, single lock table

# Development Environment:
# terraform {
#   backend "s3" {
#     bucket           = "my-company-terraform-state-dev"
#     key              = "vpc-project/terraform.tfstate"
#     region           = "us-east-1"
#     encrypt          = true
#     dynamodb_table   = "terraform-state-locks"
#   }
# }

# Staging Environment (separate state):
# terraform {
#   backend "s3" {
#     bucket           = "my-company-terraform-state-staging"
#     key              = "vpc-project/terraform.tfstate"
#     region           = "us-east-1"
#     encrypt          = true
#     dynamodb_table   = "terraform-state-locks"
#   }
# }

# Production Environment (separate state):
# terraform {
#   backend "s3" {
#     bucket           = "my-company-terraform-state-prod"
#     key              = "vpc-project/terraform.tfstate"
#     region           = "us-east-1"
#     encrypt          = true
#     dynamodb_table   = "terraform-state-locks"
#   }
# }

# Benefits:
# - Complete isolation between environments
# - Production state never affected by dev changes
# - Each environment can have different access controls
# - Easier to manage IAM permissions per environment


################################################################################
# 5. TERRAFORM CLOUD / TERRAFORM ENTERPRISE (Best Practice for Enterprise)
################################################################################
# Use case: Enterprise teams, advanced features, managed service
# Features: State locking, team management, cost estimation, policy as code

# terraform {
#   cloud {
#     organization = "my-company"
#
#     workspaces {
#       name = "vpc-project-dev"  # Or use prefix for multiple workspaces
#       # name = "vpc-project-${var.environment}"
#     }
#   }
# }

# How it works:
# 1. No local state file (stored in Terraform Cloud)
# 2. Automatic state locking and versioning
# 3. Web UI for state management and history
# 4. Supports Teams & RBAC (Role-Based Access Control)
# 5. Cost estimation before applies
# 6. VCS integration (GitHub, GitLab, Bitbucket)
# 7. Workspace per environment (dev/staging/prod)

# Multi-environment setup in Terraform Cloud:
# Organization: my-company
# ├── Project: vpc-infrastructure
#     ├── Workspace: vpc-dev
#     ├── Workspace: vpc-staging
#     └── Workspace: vpc-prod

# Workflow:
# 1. Push code to git branch
# 2. Terraform Cloud detects change (via VCS webhook)
# 3. Automatic terraform plan
# 4. Manual approval in UI
# 5. Automatic terraform apply
# 6. Logs stored permanently for audit


################################################################################
# 6. CONSUL BACKEND (For High Availability)
################################################################################
# Use case: Multi-region, high availability requirements
# Features: Distributed state management, automatic failover

# terraform {
#   backend "consul" {
#     address      = "consul.example.com:8500"
#     path         = "terraform/vpc-project"
#     datacenter   = "us-east-1"
#     http_auth    = "user:password"
#   }
# }

# How it works:
# - State stored in Consul (distributed key-value store)
# - Integrates with VCS and service discovery
# - Automatic state locking
# - Multi-region capable
# Requires: Consul cluster setup and maintenance


################################################################################
# 7. AZURERM BACKEND (Azure Users)
################################################################################
# Use case: Azure-based teams, integrated with Azure Storage
# Features: State stored in Azure Blob Storage, built-in locking

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "my-company-rg"
#     storage_account_name = "mycompanystate"
#     container_name       = "tfstate"
#     key                  = "dev/vpc-project/terraform.tfstate"
#   }
# }

# How it works:
# - State in Azure Blob Storage
# - Leverages Azure's RBAC for access control
# - Built-in state locking
# - Good for Azure-native organizations


################################################################################
# 8. GCS BACKEND (Google Cloud Users)
################################################################################
# Use case: GCP-based teams, integrated with Google Cloud Storage
# Features: State in GCS, automatic locking, RBAC integration

# terraform {
#   backend "gcs" {
#     bucket  = "my-company-terraform-state"
#     prefix  = "vpc-project"
#     project = "my-gcp-project"
#   }
# }

# How it works:
# - State in Google Cloud Storage bucket
# - Automatic state locking via GCS object versioning
# - Integrates with Google Cloud IAM
# - Multi-regional buckets supported


################################################################################
# 9. RECONFIGURING BACKENDS - MIGRATION EXAMPLE
################################################################################
# Scenario: Migrating from local to S3+DynamoDB

# Step 1: Configure new backend in terraform block (as above)
# Step 2: Run migration command:
#   terraform init
#   # Terraform detects configuration change
#   # Prompts: "Do you want to copy existing state to new backend?"
#   # Type: yes
# Step 3: Verify state migrated:
#   terraform state list
#   aws s3 ls s3://my-company-terraform-state/vpc-project/

# Step 4: Update remote state (remove local state tracking):
#   rm -f .terraform/terraform.tfstate
#   rm -f terraform.tfstate*

# Step 5: Commit changes to git:
#   git add -A
#   git commit -m "Migrate to S3+DynamoDB backend"


################################################################################
# 10. STATE LOCKING - UNDERSTANDING LOCKS
################################################################################
# What happens when someone runs terraform apply?
#
# User 1:
# $ terraform apply
# ├─ Acquires lock in DynamoDB
# │  (LockID = "my-company-terraform-state/vpc-project/terraform.tfstate")
# ├─ Creates/modifies resources (5 minutes)
# ├─ Releases lock
# └─ State updated in S3

# User 2 (simultaneously):
# $ terraform apply
# ├─ Tries to acquire lock → BLOCKED
# └─ Message: "Acquiring state lock. This may take a few moments..."
#    (waits for User 1's lock to release, then proceeds)

# If User 1's process crashes without releasing lock:
# $ terraform apply
# ├─ Detects stale lock
# ├─ Offers to force-unlock: terraform force-unlock LOCK_ID
# └─ Danger: Use only after confirming no active apply!


################################################################################
# 11. RECOMMENDED PRODUCTION SETUP
################################################################################
# For enterprise multi-environment Terraform:
#
# OPTION A: Terraform Cloud (Recommended for SaaS)
# ├─ Pros: Fully managed, excellent team support, audit logs
# ├─ Cons: Requires subscription, internet connectivity
# └─ Cost: $20-70+ per month
#
# OPTION B: S3 + DynamoDB (Recommended for AWS-only)
# ├─ Pros: Low cost, fine-grained IAM control, easy automation
# ├─ Cons: Manual setup, less UI, requires AWS knowledge
# └─ Cost: ~$5-15/month (S3+DynamoDB)
#
# OPTION C: Consul (Recommended for complex infrastructure)
# ├─ Pros: Multi-region, service discovery, advanced features
# ├─ Cons: Requires Consul cluster maintenance
# └─ Cost: Varies (self-hosted or SaaS)
#
# For this project: S3 + DynamoDB is ideal for team collaboration


################################################################################
# UNCOMMENT ONE OF THE OPTIONS ABOVE AND CONFIGURE FOR YOUR SETUP
################################################################################

# Current recommendation for this project:
# terraform {
#   backend "s3" {
#     bucket           = "my-company-terraform-state"
#     key              = "dev/vpc-project/terraform.tfstate"
#     region           = "us-east-1"
#     encrypt          = true
#     dynamodb_table   = "terraform-state-locks"
#   }
# }
