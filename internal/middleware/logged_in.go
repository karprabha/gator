package middleware

import (
	"context"
	"fmt"

	"github.com/karprabha/gator/internal/commands"
	"github.com/karprabha/gator/internal/database"
)

func MiddlewareLoggedIn(handler func(s *commands.State, cmd commands.Command, user database.User) error) func(*commands.State, commands.Command) error {
	return func(s *commands.State, cmd commands.Command) error {
		username := s.Cfg.CurrentUser
		user, err := s.DB.GetUser(context.Background(), username)
		if err != nil {
			return fmt.Errorf("failed to get user: %w", err)
		}

		return handler(s, cmd, user)
	}
}
