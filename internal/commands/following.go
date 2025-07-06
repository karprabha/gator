package commands

import (
	"context"
	"fmt"
)

func HandlerFollowing(s *State, cmd Command) error {
	username := s.Cfg.CurrentUser
	user, err := s.DB.GetUser(context.Background(), username)
	if err != nil {
		return fmt.Errorf("failed to get current user: %w", err)
	}

	following, err := s.DB.GetFeedFollowsForUser(context.Background(), user.ID)
	if err != nil {
		return fmt.Errorf("failed to get feed follows for user: %w", err)
	}

	for _, feed := range following {
		fmt.Printf("%s\n", feed.FeedName)
	}

	return nil
}
