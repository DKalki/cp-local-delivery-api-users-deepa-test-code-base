###
##Local Delivery API
###

.DEFAULT_GOAL:=explain
.PHONY: explain
explain:
	#### Welcome to Community Pharmacy Local Delivery

	#
	#
	# _      _____  _____   ___   _      ______  _____  _     _____  _   _  _____ ______ __   __
	#| |    |  _  |/  __ \ / _ \ | |     |  _  \|  ___|| |   |_   _|| | | ||  ___|| ___ \\ \ / /
	#| |    | | | || /  \// /_\ \| |     | | | || |__  | |     | |  | | | || |__  | |_/ / \ V / 
	#| |    | | | || |    |  _  || |     | | | ||  __| | |     | |  | | | ||  __| |    /   \ /  
	#| |____\ \_/ /| \__/\| | | || |____ | |/ / | |___ | |_____| |_ \ \_/ /| |___ | |\ \   | |  
	#\_____/ \___/  \____/\_| |_/\_____/ |___/  \____/ \_____/\___/  \___/ \____/ \_| \_|  \_/  
	#                                                                                                                                                                                  
	#

	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

###
# Variables
###

# Defaults to false as a make command. Is set to true in GitHub Actions.
CI ?= false

# Defines the C# build configuration.
C_SHARP_BUILD_CONFIGURATION ?= Debug

# The AWS Region we are deploying to
AWS_REGION ?= eu-west-2

# Settings for dotnet tests - report type and how to build
ifeq ($(CI),true)
REPORT_TYPE = SonarQube
CI_TEST_CONFIGURATION = --no-build --verbosity normal
else
REPORT_TYPE = Html
endif

###
##@ Cleanup
###
.PHONY: clean
clean: ## Clean non-version controlled directories
	@echo "- Cleaning the repo..."
	rm -rf ./**/*/bin
	rm -rf ./**/*/obj
	rm -fr ./build && mkdir -p ./build
	rm -rf ./node_modules
	git clean -fX || true
	@echo "✔ Done"

.PHONY: clean-terrform-auto-files
clean-terrform-auto-files: ## Clean non-version controlled directories
	@echo "- Cleaning the terraform auto gen files..."
	rm -rf ./deploy/**/*/.terraform
	rm -rf ./deploy/**/*/.terraform.lock.hcl
	rm -fr ./deploy/**/*/backend.tf
	rm -fr ./deploy/**/*/provider.grunt.tf
	git clean -fX || true
	@echo "✔ Done"

###
##@ Installing
###
.PHONY: install
install: install-npm  ## Install all the dependencies

.PHONY: install-npm
install-npm: ## Install npm dependencies
	@echo "- Installing NPM packages..."
ifeq ($(CI),true)
	npm ci
else
	npm install
	npm run husky-prep
endif
	@echo "✔ Done"

.PHONY: install-go
install-go: ## Install Golang packages
	@echo "- Installing Golang..."
	go get golang.org/x/lint/golint
	go get gotest.tools/gotestsum
	@echo "✔ Done"

.PHONY: install-terraform
install-terraform: ## Install Terraform
	@echo "- Installing Terraform..."
ifeq ($(CI),true)
	./scripts/install-terraform.sh
endif
	@echo "✔ Done"

.PHONY: install-terragrunt
install-terragrunt: ## Install Terragrunt
	@echo "- Installing Terragrunt..."
ifeq ($(CI),true)
	./scripts/install-terragrunt.sh
endif
	@echo "✔ Done"

.PHONY: dotnet-restore
dotnet-restore: ## Restore C# dependencies via NuGet
	@echo "- Restoring C# dependencies via NuGet..."
	dotnet restore ./src/api/Cp.LocalDelivery.sln
	@echo "✔ Done"

.PHONY: dotnet-tool-restore
dotnet-tool-restore: ## Restore local .NET tools
	@echo "- Restoring local .NET tools..."
	dotnet tool restore
	@echo "✔ Done"


###
##@ Validation
###
.PHONY: lint-markdown
lint-markdown: ## Lint the Markdown files
	@echo "- Linting Markdown files..."
	npm run md-lint
	@echo "✔ Done"

.PHONY: spellcheck-markdown
spellcheck-markdown: ## Spell checking Markdown file
	@echo "- Spellcheck files..."
	npm run md-spellcheck
	@echo "✔ Done"

.PHONY: editorconfig-check
editorconfig-check:
	@echo "- Checking EditorConfig files..."
	npm run eclint-check
	@echo "✔ Done"

.PHONY: editorconfig-fix
editorconfig-fix:
	@echo "- Fixing EditorConfig files..."
	npm run eclint-fix
	@echo "✔ Done"

###
##@ Building
###
.PHONY: build
build: dotnet-build ## Build everything

.PHONY: dotnet-build
dotnet-build: ## Build C# solution
	@echo "- Building C# solution..."
ifeq ($(CI),true)
	dotnet build ./src/api/Cp.LocalDelivery.sln --configuration "${C_SHARP_BUILD_CONFIGURATION}" --no-restore /clp:NoSummary
else
	dotnet build ./src/api/Cp.LocalDelivery.sln --configuration "${C_SHARP_BUILD_CONFIGURATION}"
endif
	@echo "✔ Done"

###
##@ Testing
###
.PHONY: test
test: dotnet-test ## Test everything

.PHONY: dotnet-test
dotnet-test: ## Test C# solution
	@echo "- Testing C# solution..."
	dotnet test ./src/api/Cp.LocalDelivery.sln \
		--logger trx \
		--collect:"XPlat Code Coverage" \
		--results-directory ${PWD}/build/tests \
		--configuration "${C_SHARP_BUILD_CONFIGURATION}" \
		${CI_TEST_CONFIGURATION}
	dotnet reportgenerator \
		"-reports:${PWD}/build/tests/**/coverage.cobertura.xml" \
		"-targetdir:./build/tests/coveragereport" \
		-reporttypes:${REPORT_TYPE}
	@echo "✔ Done"

.PHONY: test-planned-infrastructure
test-planned-infrastructure: check-instance check-environment ## Testing planned AWS resource creation
	@echo "- Running infrastructure terratests..."
	cd tests/terratest-planned && \
	go test ./... -timeout 15m
	@echo "✔ Done"

###
##@ Sonar
###
.PHONY: sonar-dotnet-start-pr
sonar-dotnet-start-pr: ## Start the sonar gatherer, you will need to run build in between sonar-start and sonar-stop in a CI tool
	dotnet tool run dotnet-sonarscanner begin \
		/k:"cp-local-delivery-api" \
		/d:sonar.login=${SONAR_TOKEN} \
		/o:"emisgroup" \
		/d:sonar.host.url=https://sonarcloud.io \
		/d:sonar.coverageReportPaths="../../build/tests/coveragereport/SonarQube.xml" \
		/d:sonar.pullrequest.key=${CHANGE_ID} \
		/d:sonar.pullrequest.base=${CHANGE_TARGET} \
		/d:sonar.pullrequest.branch=${CHANGE_BRANCH} \
		/v:"${PACKAGE_VERSION}"
	@echo "✔ Done"

.PHONY: sonar-dotnet-start
sonar-dotnet-start: ## Start the sonar gatherer, you will need to run build in between sonar-start and sonar-stop in a CI tool
	dotnet tool run dotnet-sonarscanner begin \
		/k:"cp-local-delivery-api" \
		/d:sonar.login=${SONAR_TOKEN} \
		/o:"emisgroup" \
		/d:sonar.host.url=https://sonarcloud.io \
		/d:sonar.coverageReportPaths="../../build/tests/coveragereport/SonarQube.xml" \
		/d:sonar.branch.name=${CHANGE_BRANCH} \
		/v:"${PACKAGE_VERSION}"
	@echo "✔ Done"

.PHONY: sonar-dotnet-stop
sonar-dotnet-stop: ## Stop the sonar gatherer
	dotnet tool run dotnet-sonarscanner end /d:sonar.login=$(SONAR_TOKEN)
	@echo "✔ Done"

###
##@ Release
###
.PHONY: create-release
create-release: check-release ## Prepare the repo for a release to take place. (Update changelog first)
	./scripts/create-release.sh

.PHONY: check-release
check-release:
ifeq ($(RELEASE_VERSION),)
	@echo "[Error] Please specify RELEASE_VERSION in format YYYY.S, where S is sprint number"
	@exit 1;
endif
ifeq ($(RELEASE_DATE),)
	@echo "[Error] Please specify RELEASE_DATE in format: DD-MM-YYYY"
	@exit 1;
endif

.PHONY: merge-main-to-develop
merge-main-to-develop: ## Merges the main branch into the develop branch
	./scripts/merge-main-into-develop.sh

.PHONY: update-deps
update-deps: ## Updates the dependencies
	./scripts/update-deps.sh

###
##@ Deploy infrastructure to AWS
###
.PHONY: aws-deploy-one-offs
aws-deploy-one-offs: check-instance check-environment check-region
	cd deploy/aws/terraform && \
		terragrunt run-all apply \
			--terragrunt-non-interactive \
			--terragrunt-include-dir "./hosted-zone"

.PHONY: aws-destroy-one-offs
aws-destroy-one-offs: check-instance check-environment check-region
	cd deploy/aws/terraform && \
		terragrunt run-all destroy \
			--terragrunt-non-interactive \
			--terragrunt-include-dir "./hosted-zone"

.PHONY: aws-full-deploy
aws-full-deploy: aws-setup aws-deploy ## Sets up the AWS infrastructure and deploys it-useful for testing Deployment Role changes

.PHONY: aws-setup
aws-setup: deploy-deployment-role deploy-paramstore ## Setting up AWS infrastructure

.PHONY: aws-deploy
aws-deploy: check-instance check-environment check-region ## Deploys the infrastructure to AWS
	@echo "- Deploying infrastructure to AWS..."
	cd deploy/aws/terraform && \
		terragrunt run-all apply \
			--terragrunt-non-interactive \
			--terragrunt-exclude-dir "./deployment-role"  \
			--terragrunt-exclude-dir "./paramstore"  \
			--terragrunt-exclude-dir "./hosted-zone"
	@echo "✔ Done"

.PHONY: aws-deploy-plan
aws-deploy-plan: check-instance check-environment check-region get-terragrunt-iam-role ## Plans the deployment of the infrastructure to AWS
	@echo "- Planning deployment of infrastructure to AWS..."
	cd deploy/aws/terraform && \
		terragrunt run-all plan \
			--terragrunt-non-interactive \
			--terragrunt-exclude-dir "./deployment-role"  \
			--terragrunt-exclude-dir "./paramstore"  \
			--terragrunt-exclude-dir "./hosted-zone"
	@echo "✔ Done"

.PHONY: aws-destroy-deployment
aws-destroy-deployment: check-instance check-environment check-region get-terragrunt-iam-role # Destroys the resources deployed to aws using the aws-deploy command
	cd deploy/aws/terraform && \
		terragrunt run-all destroy \
			--terragrunt-non-interactive \
			--terragrunt-exclude-dir "./deployment-role"  \
			--terragrunt-exclude-dir "./paramstore"  \
			--terragrunt-exclude-dir "./hosted-zone"

.PHONY: aws-destroy-all
aws-destroy-all: check-instance check-environment check-region # Destroys all of the resources deployed to aws using terraform
	cd deploy/aws/terraform && \
	terragrunt run-all destroy \
	--terragrunt-non-interactive

# Terraform standalone module for remote state resources
.PHONY: deploy-remote-state
deploy-remote-state: check-environment ## Deploy the remote_state. Not included in deploy-all. Runs locally to update terraform.tfstate.
	cd deploy/aws/terraform/remote-state && \
		terraform init && \
		terraform workspace new $(ENV) || true && \
		terraform workspace select $(ENV) && \
		terraform apply \
			-var environment=$(ENV)

.PHONY: plan-deployment-role
plan-deployment-role: check-environment check-region check-instance ## Deploy the deployment role
	@echo "- Setting up deployment role in AWS..."
	cd ./deploy/aws/terraform/deployment-role && \
		terragrunt run-all plan \
			--terragrunt-non-interactive
	@echo "✔ Done"

.PHONY: deploy-deployment-role
deploy-deployment-role: check-environment check-region check-instance ## Deploy the deployment role
	@echo "- Setting up deployment role in AWS..."
	cd ./deploy/aws/terraform/deployment-role && \
		terragrunt run-all apply \
			--terragrunt-non-interactive
	@echo "✔ Done"

.PHONY: destroy-deployment-role
destroy-deployment-role: check-environment check-region check-instance ## Destroy the deployment role
	@echo "- Destroying deployment role in AWS..."
	cd ./deploy/aws/terraform/deployment-role && \
		terragrunt run-all destroy \
			--terragrunt-non-interactive
	@echo "✔ Done"

.PHONY: deploy-paramstore
deploy-paramstore: check-environment check-region check-instance ## Deploy the parameter store resources
	@echo "- Setting up parameter store values in AWS..."
	cd ./deploy/aws/terraform/paramstore && \
		terragrunt run-all apply \
			--terragrunt-non-interactive \
			-var "audit-external-id=$(AUDIT_EXTERNAL_ID)" \
			-var "logging-external-id=$(LOGGING_EXTERNAL_ID)"
	@echo "✔ Done"

.PHONY: destroy-paramstore
destroy-paramstore: check-environment check-region check-instance ## Destroy the parameter store resources
	@echo "- Destroying parameter store values in AWS..."
	cd ./deploy/aws/terraform/paramstore && \
		terragrunt run-all destroy \
			--terragrunt-non-interactive \
			-var "audit-external-id=$(AUDIT_EXTERNAL_ID)" \
			-var "logging-external-id=$(LOGGING_EXTERNAL_ID)"
	@echo "✔ Done"

.PHONY: unlock-terraform-resource
unlock-terraform-resource: check-environment check-region check-instance check-lockid ##Removes the lock on a Terraform component
	@echo "- Removing Terraform lock..."
	cd ./deploy/aws/terraform && \
		terragrunt force-unlock ${LOCK_ID}
	@echo "✔ Done"

###
##@ Deploy AWS Cognito
###
.PHONY: aws-deploy-cognito
aws-deploy-cognito: check-instance check-environment check-region
	cd deploy/aws/terraform && \
		terragrunt run-all apply \
			--terragrunt-non-interactive \
			--terragrunt-include-dir "./cognito"

.PHONY: aws-destroy-cognito
aws-destroy-cognito: check-instance check-environment check-region
	cd deploy/aws/terraform && \
		terragrunt run-all destroy \
			--terragrunt-non-interactive \
			--terragrunt-include-dir "./cognito"


###
##@ Deploy AWS KMS, SQS, SNS
###
.PHONY: aws-deploy-topics
aws-deploy-topics: check-instance check-environment check-region
	cd deploy/aws/terraform && \
		terragrunt run-all apply \
			--terragrunt-non-interactive \
			--terragrunt-include-dir "./sns-sqs"

.PHONY: aws-destroy-topics
aws-destroy-topics: check-instance check-environment check-region
	cd deploy/aws/terraform && \
		terragrunt run-all destroy \
			--terragrunt-non-interactive \
			--terragrunt-include-dir "./sns-sqs"

###
##@ Utility
###
.PHONY: check-environment
check-environment: ## Check the ENV parameter is set to a valid value
ifeq ($(ENV),)
	@echo "[Error] Please specify an ENV"
	@exit 1;
endif
ifneq ($(ENV), $(filter $(ENV),sbx dev int stg prd))
	@echo "[Error] Please specify a valid ENV"
	@exit 1;
endif

.PHONY: check-instance
check-instance: ## Check the INSTANCE parameter is set
ifeq ($(INSTANCE),)
	@echo "[Error] Please specify an INSTANCE"
	@exit 1;
endif

.PHONY: check-region
check-region: ## Check the AWS_REGION parameter is set
ifeq ($(AWS_REGION),)
	@echo "[Error] Please specify an AWS_REGION"
	@exit 1;
endif

.PHONY: check-lockid
check-lockid: ## Check the LOCK_ID parameter is set
ifeq ($(LOCK_ID),)
	@echo "[Error] Please specify a LOCK_ID"
	@exit 1;
endif

.PHONY: get-terragrunt-iam-role
get-terragrunt-iam-role: check-environment check-instance # Determine the deployment role based on the environment and instance
	@$(eval AWS_ACCOUNT_ID:=$(shell jq -r '.accounts[] | select(.environment=="${ENV}") | .id' < emis.json))
	@$(eval DEPLOYMENT_ROLE:="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${INSTANCE}-ld-plat-rol-deployment")

.PHONY: get-package-version
get-package-version:	# Gets the package version
	@$(eval PACKAGE_VERSION:=$(shell jq -r .version package.json | tr . -))

###
##@ Swagger Document Scripts
###

.PHONY: build-local-delivery-api-spec
build-local-delivery-api-spec: ## Build the Local Delivery Integration API Swagger document
	@echo "- Running build-local-delivery-api-spec"
	npx swagger-cli bundle ./docs/open-api/local-delivery-api/_indexV1.yaml -r --outfile ./docs/open-api/local-delivery-api/generated/local-delivery-api_v1.yml --type yaml
	npx swagger-cli bundle ./docs/open-api/local-delivery-api/_indexV1.yaml -r --outfile ./docs/open-api/local-delivery-api/generated/local-delivery-api_v1.json --type json
	npx swagger-cli validate ./docs/open-api/local-delivery-api/generated/local-delivery-api_v1.yml
	@echo "✔ Done"