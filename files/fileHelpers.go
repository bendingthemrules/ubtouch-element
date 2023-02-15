package files

import (
	"fmt"
	"os"
)

func FileExists(path string) bool {
	f, err := os.Stat(path)
	return err == nil && !f.IsDir()
}

func CreateFile(path string, content string) error {
	fmt.Println("Creating file", path)
	f, err := os.Create(path)
	if err != nil {
		return err
	}

	_, err = f.WriteString(content)
	if err != nil {
		return err
	}

	return nil
}
