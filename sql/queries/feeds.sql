-- name: CreateFeed :one
INSERT INTO feeds (id, name, url, user_id, created_at, updated_at)
VALUES (
    $1,
    $2,
    $3,
    $4,
    $5,
    $6
)
RETURNING *;

-- name: GetFeeds :many
SELECT
    feeds.name,
    feeds.url,
    users.name AS user_name
FROM feeds
INNER JOIN users ON feeds.user_id = users.id;

-- name: GetFeed :one
SELECT
    feeds.id,
    feeds.name,
    feeds.url,
    users.name AS user_name
FROM feeds
INNER JOIN users ON feeds.user_id = users.id
WHERE feeds.url = $1;

-- name: MarkFeedFetched :exec
UPDATE feeds
SET last_fetched_at = $1,
    updated_at = $2
WHERE id = $3;

-- name: GetNextFeedToFetch :one
SELECT
    feeds.id,
    feeds.name,
    feeds.url,
    users.name AS user_name,
    feeds.last_fetched_at,
    feeds.created_at,
    feeds.updated_at
FROM feeds
INNER JOIN users ON feeds.user_id = users.id
ORDER BY feeds.last_fetched_at ASC NULLS FIRST
LIMIT 1;
