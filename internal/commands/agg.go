package commands

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/karprabha/gator/internal/database"
	"github.com/karprabha/gator/internal/feed"
)

func HandlerAgg(s *State, cmd Command) error {
	if len(cmd.Args) == 0 {
		return fmt.Errorf("agg command requires time_between_reqs argument")
	}

	timeBetweenRequests, err := time.ParseDuration(cmd.Args[0])
	if err != nil {
		return fmt.Errorf("invalid time_between_reqs argument: %w", err)
	}

	fmt.Printf("Collecting feeds every %s\n", timeBetweenRequests)

	ticker := time.NewTicker(timeBetweenRequests)

	for ; ; <-ticker.C {
		fmt.Println("Scraping feeds...")
		scrapeFeeds(s)
	}
}

func scrapeFeeds(s *State) error {
	feedToFetch, err := s.DB.GetNextFeedToFetch(context.Background())
	if err != nil {
		return fmt.Errorf("failed to get next feed to fetch: %w", err)
	}

	markFeedFetchedParams := database.MarkFeedFetchedParams{
		ID: feedToFetch.ID,
		LastFetchedAt: sql.NullTime{
			Time:  time.Now(),
			Valid: true,
		},
		UpdatedAt: time.Now(),
	}

	if err := s.DB.MarkFeedFetched(context.Background(), markFeedFetchedParams); err != nil {
		return fmt.Errorf("failed to mark feed fetched: %w", err)
	}

	parsedFeed, err := feed.FetchFeed(context.Background(), feedToFetch.Url)
	if err != nil {
		return fmt.Errorf("error fetching feed %s: %w", feedToFetch.Url, err)
	}

	for _, item := range parsedFeed.Channel.Item {
		fmt.Println(" -", item.Title)
	}

	return nil
}
