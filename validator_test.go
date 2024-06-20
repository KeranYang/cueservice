package embeded

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"gopkg.in/yaml.v2"
)

const expectedFinalPipelineSpec = `apiVersion: numaflow.numaproj.io/v1alpha1
metadata:
  name: simple-pipeline
spec:
  vertices:
    - name: in
      source:
        generator:
          duration: 1s
          rpu: 5
    - name: cat
      udf:
        builtin:
          name: cat
    - name: out
      sink:
        log: {}
  edges:
    - from: in
      to: cat
    - from: cat
      to: out
      onFull: discardLatest
kind: Pipeline
`

const unexpectedFinalPipelineSpec = `apiVersion: numaflow.numaproj.io/v1alpha1
metadata:
  name: simple-pipeline
spec:
  vertices:
    - name: in
      source:
        generator:
          duration: 1s
          rpu: 5ssssss
    - name: cat
      udf:
        builtin:
          name: cat
    - name: out
      sink:
        log: {}
  edges:
    - from: in
      to: cat
    - from: cat
      to: out
      onFull: discardLatest
kind: Pipeline
`

func Test_validatorSuccess(t *testing.T) {
	input, _ := convertYamlStrToByteArray(expectedFinalPipelineSpec)
	assert.True(t, ValidatePipelineSpec(input))
}

func Test_validatorFail(t *testing.T) {
	input, _ := convertYamlStrToByteArray(unexpectedFinalPipelineSpec)
	assert.False(t, ValidatePipelineSpec(input))
}

// convertYamlStrToByteArray converts a YAML string to a byte array.
// it's used mainly by unit tests to prepare test data.
func convertYamlStrToByteArray(input string) ([]byte, error) {
	var data map[interface{}]interface{}
	err := yaml.Unmarshal([]byte(input), &data)
	if err != nil {
		return nil, err
	}
	byteArray, err := yaml.Marshal(data)
	if err != nil {
		return nil, err
	}
	return byteArray, nil
}
