package commands

import (
	"context"
	"fmt"

	"github.com/karprabha/gator/internal/database"
)

func HandlerFollowing(s *State, cmd Command, user database.User) error {
	following, err := s.DB.GetFeedFollowsForUser(context.Background(), user.ID)
	if err != nil {
		return fmt.Errorf("failed to get feed follows for user: %w", err)
	}

	for _, feed := range following {
		fmt.Printf("%s\n", feed.FeedName)
	}

	return nil
}
