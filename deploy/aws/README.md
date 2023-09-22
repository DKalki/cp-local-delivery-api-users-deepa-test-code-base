# Deployment to AWS

## Prerequisite

- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/#install-via-a-package-manager)
- [AWS CLI](https://aws.amazon.com/cli/)
- [GO](https://golang.org)

## Overview

The `deploy/aws` folder in this project contains all of the components required to deploy the Organisation Management Service
solution into the AWS environment.

The Visual Studio Code HashiCorp Terraform Extension should be installed when working with Terraform files.

### First Time Setup

To deploy the setup of the solution to a unique AWS environment (i.e. prefixed resources):

1. Add entries in `.bashrc` or `.zshrc` to set the development environment:
    - `export ENV={env}` where `{env}` is the deployment environment that the AWS resources will be created against, this can be `sbx, dev, int, stg, prd`
    - `export INSTANCE={instance}` where `{instance}` is your unique prefix which will be added to AWS resources you create.
2. Refresh your terminal to pick up the changes by e.g. running `source ~/.bashrc` or `source ~/.zshrc`.
3. Run `make aws-setup` - this will configure all of the prerequisite components. It will fail with an error if you have not defined the environment variables above.

### Deployment Environment

Before running any commands you will need to set a valid AWS token for your target environment.

To deploy the solution:

- run `make aws-deploy` - this will deploy all of the components to the configured environment.

To destroy the solution within AWS:

- run `make aws-destroy` - this will remove all of the components.

### Development

[cloudonaut.io](https://iam.cloudonaut.io/) is a useful pocket book of IAM permissions and their functions.

### Troubleshooting

**Cause:** Running the `make aws-setup` command\
**Error:** `No valid credential sources found for AWS Provider.`\
**Possible fix:** Ensure the AWS credentials file is configured and the token hasn't expired. The credentials may need to be stored under `[default]`
