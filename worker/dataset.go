package worker

import (
	"fmt"

	"github.com/gofrs/uuid"
)

// DeviceValues represents a fake device
type DeviceValues map[string]string

// Dataset is an alias for a list of DeviceValues
type Dataset []DeviceValues

func genKey(id uuid.UUID, key string) string {
	return fmt.Sprintf("{%s}.%s", id.String(), key)
}

// ToPairs converts a DeviceValues into a list of keys and values for use with MSet
func (d DeviceValues) ToPairs() *[]interface{} {
	result := make([]interface{}, 0)
	for k, v := range d {
		result = append(result, k, v)
	}
	return &result
}

// ToKeys extracts the keys for a DeviceValues
func (d DeviceValues) ToKeys() *[]string {
	result := make([]string, 0)
	for k := range d {
		result = append(result, k)
	}
	return &result
}

// MakeDataset makes a new Dataset
func MakeDataset(num int) Dataset {
	var dataset Dataset
	for i := 0; i < num; i++ {
		id := uuid.Must(uuid.NewV4())
		dataset = append(dataset, DeviceValues{
			genKey(id, "foo"):  "Something",
			genKey(id, "bar"):  "42",
			genKey(id, "baz"):  "00000000000",
			genKey(id, "quux"): "999999999999",
		})
	}
	return dataset
}
