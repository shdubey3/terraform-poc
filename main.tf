# Terraform configuration for AWS VPC with Subnets and Route Tables
# This is the entry point for the Terraform configuration.
# 
# Project Structure:
# - provider.tf: AWS provider configuration
# - variables.tf: Input variables and default values
# - vpc.tf: VPC resource
# - subnet.tf: Subnet resources
# - route_table.tf: Route table and IGW resources
# - outputs.tf: Output values
# - terraform.tfvars: Variable values (local overrides)
# - backend.tf: Remote state configuration (optional)

# To initialize: terraform init
# To plan: terraform plan
# To apply: terraform apply
# To destroy: terraform destroy
