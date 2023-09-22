package helper

import (
	"reflect"
	"testing"
)

func TestGetPlannedResources(t *testing.T) {
	type args struct {
		t        *testing.T
		planJSON string
	}
	tests := []struct {
		name string
		args args
		want []interface{}
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := GetPlannedResources(tt.args.t, tt.args.planJSON); !reflect.DeepEqual(got, tt.want) {
				t.Errorf("GetPlannedResources() = %v, want %v", got, tt.want)
			}
		})
	}
}
