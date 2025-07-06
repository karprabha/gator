package commands

import (
	"context"
	"fmt"

	"github.com/karprabha/gator/internal/database"
)

func HandlerUnfollow(s *State, cmd Command, user database.User) error {
	if len(cmd.Args) == 0 {
		return fmt.Errorf("unfollow command requires url argument")
	}

	url := cmd.Args[0]

	feed, err := s.DB.GetFeed(context.Background(), url)
	if err != nil {
		return fmt.Errorf("failed to get feed %s: %w", url, err)
	}

	deleteFeedFollowParams := database.DeleteFeedFollowParams{
		UserID: user.ID,
		FeedID: feed.ID,
	}

	if err := s.DB.DeleteFeedFollow(context.Background(), deleteFeedFollowParams); err != nil {
		return fmt.Errorf("failed to unfollow %s: %w", url, err)
	}

	return nil
}
