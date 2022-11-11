# provider.tf

# Specify the provider and access details
# Note: Home folder syntax is the same in Windows and Linux
provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  shared_config_files      = ["~/.aws/config"]
  profile                 = "default"
  region                  = "eu-central-1"
}
