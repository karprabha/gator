package commands

import (
	"context"
	"fmt"
	"log"

	"github.com/karprabha/gator/internal/feed"
)

func HandlerAgg(s *State, cmd Command) error {
	feed, err := feed.FetchFeed(context.Background(), "https://www.wagslane.dev/index.xml")
	if err != nil {
		log.Fatalf("failed to fetch feed: %v", err)
	}

	fmt.Printf("%+v\n", feed)

	return nil
}
