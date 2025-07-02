package main

import (
	"fmt"
	"log"

	"github.com/karprabha/gator/internal/config"
)

func main() {
	cfg, err := config.Read()
	if err != nil {
		log.Fatalf("Error reading config: %v", err)
	}

	err = cfg.SetUser("prabhakar")
	if err != nil {
		log.Fatalf("Error setting user: %v", err)
	}

	updatedCfg, err := config.Read()
	if err != nil {
		log.Fatalf("Error reading config after update: %v", err)
	}

	fmt.Printf("Current Config: %+v\n", *updatedCfg)
}
