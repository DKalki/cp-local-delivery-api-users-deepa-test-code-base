package test

import (
	"fmt"
	"os"
	"testing"

	helper "github.com/emisgroup/cp-local-delivery-api/tests/terratest-planned/helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// The Terratest plan tests for the AWS Deployment Role
func TestDeploymentRole(t *testing.T) {
	t.Parallel()

	requiredResources := []struct {
		resourceName string
		resourceType string
	}{
		{
			resourceName: "deployment-role",
			resourceType: "aws_iam_role",
		},
		{
			resourceName: "extended-iam",
			resourceType: "aws_iam_policy",
		},
		{
			resourceName: "additional_policy",
			resourceType: "aws_iam_policy_attachment",
		},
	}

	tfOptions := &terraform.Options{
		TerraformDir: "../../../deploy/aws/terraform/deployment-role",
		Vars: map[string]interface{}{
			"environment":  os.Getenv("ENV"),
			"default-tags": map[string]interface{}{},
			"account-id":   "",
		},
		PlanFilePath: "./terraform_plan.out",
	}

	planJSON := terraform.InitAndPlanAndShow(t, tfOptions)
	plannedResources := helper.GetPlannedResources(t, planJSON)
	assert.Equal(t, len(plannedResources), len(requiredResources))

	for _, tt := range requiredResources {
		t.Run(tt.resourceName+"."+tt.resourceType, func(t *testing.T) {
			found := 0
			for _, plannedResource := range plannedResources {
				plannedResourceAttributes := plannedResource.(map[string]interface{})
				if tt.resourceName == plannedResourceAttributes["name"] {
					if tt.resourceType == plannedResourceAttributes["type"] {
						found = found + 1
					}
				}
			}
			if found != 1 {
				t.Fatalf(fmt.Sprintf("Planned resource '%s.%s' should exist once but was found %v times", tt.resourceType, tt.resourceName, found))
			}
		})
	}
}
