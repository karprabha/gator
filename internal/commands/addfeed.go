package commands

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/karprabha/gator/internal/database"
)

func HandlerAddfeed(s *State, cmd Command, user database.User) error {
	if len(cmd.Args) < 2 {
		return fmt.Errorf("addfeed command requires name and URL arguments")
	}

	name := cmd.Args[0]
	url := cmd.Args[1]

	newFeed := database.CreateFeedParams{
		ID:        uuid.New(),
		Name:      name,
		Url:       url,
		UserID:    user.ID,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	feed, err := s.DB.CreateFeed(context.Background(), newFeed)
	if err != nil {
		return fmt.Errorf("failed to create feed: %w", err)
	}

	newFeedFollow := database.CreateFeedFollowParams{
		ID:        uuid.New(),
		UserID:    user.ID,
		FeedID:    feed.ID,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	_, err = s.DB.CreateFeedFollow(context.Background(), newFeedFollow)
	if err != nil {
		return fmt.Errorf("failed to create feed follow for user %s: %w", user.Name, err)
	}

	fmt.Printf("%+v\n", feed)

	return nil
}
