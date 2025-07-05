package commands

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/karprabha/gator/internal/database"
)

func HandlerRegister(s *State, cmd Command) error {
	if len(cmd.Args) == 0 {
		return fmt.Errorf("register command requires a username argument")
	}

	username := cmd.Args[0]

	newUser := database.CreateUserParams{
		ID:        uuid.New(),
		Name:      username,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	user, err := s.DB.CreateUser(context.Background(), newUser)
	if err != nil {
		return fmt.Errorf("failed to create user: %w", err)
	}

	err = s.Cfg.SetUser(user.Name)
	if err != nil {
		return fmt.Errorf("couldn't set user: %w", err)
	}

	log.Printf("Created user: %+v\n", newUser)

	fmt.Printf("User '%s' created successfully!\n", username)

	return nil
}
