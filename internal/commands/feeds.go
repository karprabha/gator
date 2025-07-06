package commands

import (
	"context"
	"fmt"
)

func HandlerFeeds(s *State, cmd Command) error {
	feeds, err := s.DB.GetFeeds(context.Background())
	if err != nil {
		return fmt.Errorf("couldn't get feeds: %w", err)
	}

	for _, feed := range feeds {
		fmt.Printf("Feed: %s, URL: %s, User: %s\n", feed.Name, feed.Url, feed.UserName)
	}

	return nil
}
