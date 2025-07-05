package commands

import (
	"context"
	"fmt"
)

func HandlerLogin(s *State, cmd Command) error {
	if len(cmd.Args) == 0 {
		return fmt.Errorf("login command requires a username argument")
	}

	username := cmd.Args[0]

	user, err := s.DB.GetUser(context.Background(), username)
	if err != nil {
		return fmt.Errorf("couldn't get user: %w", err)
	}

	err = s.Cfg.SetUser(user.Name)
	if err != nil {
		return fmt.Errorf("couldn't set user: %w", err)
	}

	fmt.Printf("User has been set to: %s\n", username)
	return nil
}
