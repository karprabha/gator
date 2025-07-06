package commands

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/karprabha/gator/internal/database"
)

func HandlerFollow(s *State, cmd Command) error {
	username := s.Cfg.CurrentUser
	user, err := s.DB.GetUser(context.Background(), username)
	if err != nil {
		return fmt.Errorf("failed to get current user: %w", err)
	}

	if len(cmd.Args) == 0 {
		return fmt.Errorf("follow command requires url argument")
	}

	url := cmd.Args[0]

	feed, err := s.DB.GetFeed(context.Background(), url)
	if err != nil {
		return fmt.Errorf("failed to get feed: %w", err)
	}

	newFeedFollow := database.CreateFeedFollowParams{
		ID:        uuid.New(),
		UserID:    user.ID,
		FeedID:    feed.ID,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	feedFollow, err := s.DB.CreateFeedFollow(context.Background(), newFeedFollow)
	if err != nil {
		return fmt.Errorf("failed to create feed follow: %w", err)
	}

	fmt.Printf("Feed Name: %s, User Name: %s\n", feedFollow.FeedName, feedFollow.UserName)

	return nil
}
