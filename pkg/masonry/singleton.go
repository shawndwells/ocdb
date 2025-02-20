package masonry

import (
	"github.com/opencontrol/compliance-masonry/pkg/lib/common"
	"sync"
)

var instance *common.Workspace
var once sync.Once

// GetInstance gets memory representation of the masonry cache
func GetInstance() *common.Workspace {
	once.Do(func() {
		Refresh()
	})
	return instance
}

// Refresh function refreshes masonry data
func Refresh() {
	data, errors := build()
	if errors != nil {
		panic(errors)
	}
	instance = &data
}
