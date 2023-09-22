package helper

import (
	"encoding/json"
	"testing"

	"github.com/buger/jsonparser"
	"github.com/stretchr/testify/assert"
)

// GetPlannedResources returns the list of planned resources
func GetPlannedResources(t *testing.T, planJSON string) []interface{} {
	val, err := jsonparser.GetUnsafeString([]byte(planJSON), "planned_values", "root_module", "resources")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	var jsonObjs interface{}
	json.Unmarshal([]byte(val), &jsonObjs)
	objSlice, _ := jsonObjs.([]interface{})

	return objSlice
}

// GetPlannedResourcesFromChildModule returns the list of planned resources
func GetPlannedResourcesFromChildModule(t *testing.T, planJSON string) []interface{} {
	val, err := jsonparser.GetUnsafeString([]byte(planJSON), "planned_values", "root_module", "child_modules", "[0]", "resources")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	var jsonObjs interface{}
	json.Unmarshal([]byte(val), &jsonObjs)
	objSlice, _ := jsonObjs.([]interface{})

	return objSlice
}

func GetStringFromJson(t *testing.T, data []byte, keys ...string) string {
	value, err := jsonparser.GetString(data, keys...)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	return value
}

func AssertStringInJson(t *testing.T, data []byte, expectedValue string, keys ...string) {

	assert.Equal(t, expectedValue, GetStringFromJson(t, data, keys...))
}
