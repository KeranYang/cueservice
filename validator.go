package embeded

import (
	"embed"
	"fmt"
	"io/fs"
	"log"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/cuecontext"
	"cuelang.org/go/cue/load"
	"gopkg.in/yaml.v2"
)

// Embed all CUE schema files and the cue.mod directory
//
//go:embed cue.mod/*
//go:embed schemas/*/*/*.cue
var embeddedFiles embed.FS

func ValidatePipelineSpec(input []byte) bool {
	ctx := cuecontext.New()
	schemaInstance := loadInstance(ctx, "/schemas/numaflow/v-1-2/pipeline.cue")
	if err := schemaInstance.Err(); err != nil {
		fmt.Printf("Error loading schema: %v\n", err)
		return false
	}
	specInstance := generateCueValueOfYamlEncoding(ctx, input)
	if unified := specInstance.Unify(schemaInstance.LookupPath(cue.ParsePath("#Data"))); unified.Err() != nil {
		fmt.Printf("Error unifying spec with schema: %v\n", unified.Err())
		return false
	}
	return true
}

// loadInstance loads a CUE instance from a schema file.
func loadInstance(ctx *cue.Context, schemaPath string) *cue.Value {
	overlay, _ := setupOverlay()

	/*
		fmt.Printf("Overlay")
		for k, v := range overlay {
			fmt.Printf("Key: %s, Value: %s\n", k, v)
		}
	*/

	instConfig := &load.Config{
		Dir:        "/",
		ModuleRoot: "/",
		Overlay:    overlay,
	}

	buildInstances := load.Instances([]string{schemaPath}, instConfig)
	if len(buildInstances) == 0 || buildInstances[0].Err != nil {
		log.Printf("Error loading instances: %v\n", buildInstances[0].Err)
		return nil
	}

	inst := ctx.BuildInstance(buildInstances[0])
	if inst.Err() != nil {
		log.Printf("Error building instance from schema: %v\n", inst.Err())
		return nil
	}

	return &inst
}

// setupOverlay sets up an overlay for the CUE instances. It walks the embedded files and creates a map of the file paths and their contents.
func setupOverlay() (map[string]load.Source, error) {
	overlay := make(map[string]load.Source)
	err := fs.WalkDir(embeddedFiles, ".", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if !d.IsDir() {
			data, err := fs.ReadFile(embeddedFiles, path)
			if err != nil {
				return err
			}
			// The following line ensures all paths in the overlay use '/' and are set up from the root ('/')
			overlay["/"+path] = load.FromBytes(data)
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return overlay, nil
}

// generateCueValueOfYamlEncoding generates a CUE value from a YAML byte array.
func generateCueValueOfYamlEncoding(cueCtx *cue.Context, input []byte) *cue.Value {
	var i interface{}
	if err := yaml.Unmarshal(input, &i); err != nil {
		return nil
	}
	converted := convertMapKeysToString(i)
	specInstance := cueCtx.Encode(converted)
	return &specInstance
}

func convertMapKeysToString(i interface{}) interface{} {
	switch x := i.(type) {
	case map[interface{}]interface{}:
		m := make(map[string]interface{})
		for k, v := range x {
			m[fmt.Sprint(k)] = convertMapKeysToString(v)
		}
		return m
	case []interface{}:
		for idx, val := range x {
			x[idx] = convertMapKeysToString(val)
		}
	}
	return i
}
