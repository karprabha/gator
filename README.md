# Gator

A command-line RSS feed aggregator built in Go. Gator allows you to manage RSS feeds, follow your favorite sources, and browse the latest posts all from your terminal.

**🚀 Quick Start:** Get up and running in minutes with our interactive setup script!

## Features

- 🔐 User authentication and management
- 📰 Add and manage RSS feeds
- 👥 Follow/unfollow feeds from other users
- 📖 Browse latest posts from your followed feeds
- 🔄 Automatic feed aggregation
- 💾 PostgreSQL database storage
- ⚙️ Simple JSON configuration

## Prerequisites

Before installing Gator, make sure you have the following installed:

- **Go 1.20+** - [Download Go](https://golang.org/dl/)
- **PostgreSQL** - [Download PostgreSQL](https://www.postgresql.org/download/)

## Installation

### Quick Setup (Recommended)

For the easiest setup experience, clone the repository and run the setup script:

```bash
git clone https://github.com/karprabha/gator.git
cd gator
./setup.sh
```

The setup script will:

- ✅ Check if Go and PostgreSQL are installed
- ✅ Help you create and configure the database
- ✅ Install the goose migration tool
- ✅ Run all database migrations automatically
- ✅ Create your configuration file
- ✅ Build and install the gator binary
- ✅ Optionally set up example users and feeds

### Manual Installation

If you prefer to set up manually:

1. **Install Gator:**

   ```bash
   go install github.com/karprabha/gator@latest
   ```

2. **Database Setup:**

   ```sql
   CREATE DATABASE gator;
   ```

3. **Install migration tool:**

   ```bash
   go install github.com/pressly/goose/v3/cmd/goose@latest
   ```

4. **Run migrations:**

   ```bash
   goose -dir sql/schema postgres "postgres://username:password@localhost/gator?sslmode=disable" up
   ```

5. **Create configuration file at `~/.gatorconfig.json`:**
   ```json
   {
     "db_url": "postgres://username:password@localhost/gator?sslmode=disable"
   }
   ```

## Usage

### Getting Started

1. **Register a user account:**

   ```bash
   gator register yourusername
   ```

2. **Add your first RSS feed:**

   ```bash
   gator addfeed "TechCrunch" "https://techcrunch.com/feed/"
   ```

3. **Browse the latest posts:**
   ```bash
   gator browse
   ```

### Available Commands

#### User Management

- `gator register <username>` - Create a new user account
- `gator login <username>` - Switch to a different user
- `gator users` - List all registered users

#### Feed Management

- `gator addfeed <name> <url>` - Add a new RSS feed
- `gator feeds` - List all available feeds
- `gator follow <feed_url>` - Follow an existing feed
- `gator unfollow <feed_url>` - Unfollow a feed
- `gator following` - Show feeds you're currently following

#### Content

- `gator browse [limit]` - Browse latest posts from followed feeds
- `gator agg <time_between_requests>` - Start feed aggregation (fetches new posts)

#### Utility

- `gator reset` - Reset the database (⚠️ **Warning**: This deletes all data)

### Examples

```bash
# Register and login
gator register alice
gator login alice

# Add some feeds
gator addfeed "Hacker News" "https://hnrss.org/newest"
gator addfeed "Go Blog" "https://blog.golang.org/feed.atom"
gator addfeed "GitHub Blog" "https://github.blog/feed/"

# Follow feeds from other users
gator follow "https://techcrunch.com/feed/"

# Check what you're following
gator following

# Browse latest posts (default: 2 posts)
gator browse

# Browse more posts
gator browse 10

# Start aggregation (fetches new posts every 60 seconds)
gator agg 60s
```

## Configuration File

The configuration file (`~/.gatorconfig.json`) supports the following options:

```json
{
  "db_url": "postgres://user:password@localhost/gator?sslmode=disable",
  "current_user_name": "alice"
}
```

- `db_url` - PostgreSQL connection string
- `current_user_name` - Currently logged-in user (set automatically)

## Development

### Building from Source

```bash
git clone https://github.com/karprabha/gator.git
cd gator
go build -o gator
```

### Setup Script Options

The `setup.sh` script provides several options for different use cases:

```bash
./setup.sh          # Complete setup (default)
./setup.sh setup    # Complete setup
./setup.sh db       # Database setup only
./setup.sh migrate  # Run migrations only
./setup.sh config   # Create config file only
./setup.sh install  # Install gator binary only
./setup.sh help     # Show help message
```

### Managing Database Migrations

To run migrations manually:

```bash
# Up migrations
goose -dir sql/schema postgres "your_db_url" up

# Down migrations
goose -dir sql/schema postgres "your_db_url" down

# Migration status
goose -dir sql/schema postgres "your_db_url" status
```

### Database Schema

The application uses the following main tables:

- `users` - User accounts
- `feeds` - RSS feed definitions
- `feed_follows` - User-feed relationships
- `posts` - Aggregated RSS posts

### Project Structure

```
gator/
├── main.go                 # Application entry point
├── internal/
│   ├── commands/          # CLI command handlers
│   ├── config/           # Configuration management
│   ├── database/         # Database queries and models
│   ├── feed/            # RSS feed parsing
│   └── middleware/      # Authentication middleware
└── sql/
    ├── queries/         # SQL query definitions
    └── schema/         # Database migrations
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Troubleshooting

### Quick Fix

If you're having setup issues, try running the setup script which handles most common problems automatically:

```bash
git clone https://github.com/karprabha/gator.git
cd gator
./setup.sh
```

### Common Issues

**"Error reading config"**

- Make sure `~/.gatorconfig.json` exists and has valid JSON
- Check that your database URL is correct
- Try running `./setup.sh config` to recreate the config file

**"Error opening database"**

- Verify PostgreSQL is running
- Check your database credentials
- Ensure the database exists
- Try running `./setup.sh db` to reconfigure the database

**"Unknown command"**

- Check command spelling
- Run `gator` without arguments to see usage
- Make sure gator is installed: `./setup.sh install`

**Database connection issues**

- Verify your `db_url` in the config file
- Test database connectivity with `psql`
- Check firewall and network settings
- Try running `./setup.sh migrate` to ensure schema is up to date

**Migration issues**

- Make sure goose is installed: `go install github.com/pressly/goose/v3/cmd/goose@latest`
- Run migrations manually: `./setup.sh migrate`
- Check migration status: `goose -dir sql/schema postgres "your_db_url" status`

For more help, please open an issue on the [GitHub repository](https://github.com/karprabha/gator).
