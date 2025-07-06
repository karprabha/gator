#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}         Gator Setup Script${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

check_prerequisites() {
    print_step "Checking prerequisites..."
    
    # Check if Go is installed
    if ! command -v go &> /dev/null; then
        print_error "Go is not installed. Please install Go 1.20+ from https://golang.org/dl/"
        exit 1
    fi
    
    GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
    print_success "Go found: $GO_VERSION"
    
    # Check if PostgreSQL is installed
    if ! command -v psql &> /dev/null; then
        print_error "PostgreSQL is not installed. Please install PostgreSQL from https://www.postgresql.org/download/"
        exit 1
    fi
    
    PG_VERSION=$(psql --version | awk '{print $3}')
    print_success "PostgreSQL found: $PG_VERSION"
    
    # Check if goose is installed, if not install it
    if ! command -v goose &> /dev/null; then
        print_warning "Goose migration tool not found. Installing..."
        go install github.com/pressly/goose/v3/cmd/goose@latest
        print_success "Goose installed successfully"
    else
        print_success "Goose migration tool found"
    fi
}

setup_database() {
    print_step "Setting up database..."
    
    echo -n "Enter PostgreSQL username (default: postgres): "
    read -r DB_USER
    DB_USER=${DB_USER:-postgres}
    
    echo -n "Enter PostgreSQL password: "
    read -rs DB_PASSWORD
    echo ""
    
    echo -n "Enter database name (default: gator): "
    read -r DB_NAME
    DB_NAME=${DB_NAME:-gator}
    
    echo -n "Enter database host (default: localhost): "
    read -r DB_HOST
    DB_HOST=${DB_HOST:-localhost}
    
    echo -n "Enter database port (default: 5432): "
    read -r DB_PORT
    DB_PORT=${DB_PORT:-5432}
    
    # Test connection
    print_status "Testing database connection..."
    export PGPASSWORD="$DB_PASSWORD"
    
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
        print_success "Database '$DB_NAME' already exists"
    else
        print_status "Creating database '$DB_NAME'..."
        if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -c "CREATE DATABASE $DB_NAME;" 2>/dev/null; then
            print_success "Database '$DB_NAME' created successfully"
        else
            print_error "Failed to create database. Please check your credentials and try again."
            exit 1
        fi
    fi
    
    # Store connection details for later use
    DB_URL="postgres://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME?sslmode=disable"
}

run_migrations() {
    print_step "Running database migrations..."
    
    print_status "Applying database schema..."
    
    if goose -dir sql/schema postgres "$DB_URL" up; then
        print_success "Database migrations completed successfully"
    else
        print_error "Database migrations failed"
        exit 1
    fi
}

create_config() {
    print_step "Creating configuration file..."
    
    CONFIG_FILE="$HOME/.gatorconfig.json"
    
    if [ -f "$CONFIG_FILE" ]; then
        print_warning "Configuration file already exists at $CONFIG_FILE"
        echo -n "Do you want to overwrite it? (y/N): "
        read -r overwrite
        if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
            print_status "Skipping configuration file creation"
            return
        fi
    fi
    
    cat > "$CONFIG_FILE" << EOF
{
  "db_url": "$DB_URL"
}
EOF
    
    print_success "Configuration file created at $CONFIG_FILE"
}

install_gator() {
    print_step "Installing Gator..."
    
    print_status "Building and installing gator binary..."
    
    if go install .; then
        print_success "Gator installed successfully"
        
        # Check if $GOPATH/bin is in PATH
        if [[ ":$PATH:" != *":$GOPATH/bin:"* ]] && [[ ":$PATH:" != *":$HOME/go/bin:"* ]]; then
            print_warning "Make sure your Go bin directory is in your PATH:"
            print_warning "export PATH=\$PATH:\$(go env GOPATH)/bin"
        fi
    else
        print_error "Failed to install gator"
        exit 1
    fi
}

setup_example_user() {
    print_step "Setting up example user..."
    
    echo -n "Would you like to create an example user? (Y/n): "
    read -r create_user
    if [[ "$create_user" =~ ^[Nn]$ ]]; then
        return
    fi
    
    echo -n "Enter username (default: admin): "
    read -r username
    username=${username:-admin}
    
    print_status "Creating user '$username'..."
    
    if gator register "$username" 2>/dev/null; then
        print_success "User '$username' created successfully"
        
        echo -n "Would you like to add some example RSS feeds? (Y/n): "
        read -r add_feeds
        if [[ ! "$add_feeds" =~ ^[Nn]$ ]]; then
            print_status "Adding example feeds..."
            
            gator addfeed "Go Blog" "https://blog.golang.org/feed.atom" 2>/dev/null || true
            gator addfeed "Hacker News" "https://hnrss.org/newest" 2>/dev/null || true
            gator addfeed "GitHub Blog" "https://github.blog/feed/" 2>/dev/null || true
            
            print_success "Example feeds added. Run 'gator feeds' to see them."
        fi
    else
        print_warning "Failed to create user (may already exist)"
    fi
}

print_completion() {
    print_step "Setup completed!"
    echo ""
    echo -e "${GREEN}🎉 Gator is now ready to use!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Run 'gator register <username>' to create a user"
    echo "2. Run 'gator addfeed <name> <url>' to add RSS feeds"
    echo "3. Run 'gator browse' to see latest posts"
    echo "4. Run 'gator --help' for more commands"
    echo ""
    echo "Configuration file: $HOME/.gatorconfig.json"
    echo "Database: $DB_NAME"
    echo ""
}

usage() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  setup     Complete setup (default)"
    echo "  db        Database setup only"
    echo "  migrate   Run migrations only"
    echo "  config    Create config file only"
    echo "  install   Install gator binary only"
    echo "  help      Show this help message"
    echo ""
}

main() {
    case "${1:-setup}" in
        "setup")
            print_header
            check_prerequisites
            setup_database
            run_migrations
            create_config
            install_gator
            setup_example_user
            print_completion
            ;;
        "db")
            print_header
            check_prerequisites
            setup_database
            ;;
        "migrate")
            print_header
            if [ -z "$DB_URL" ]; then
                print_error "Database URL not found. Please run database setup first or set DB_URL environment variable."
                exit 1
            fi
            run_migrations
            ;;
        "config")
            print_header
            if [ -z "$DB_URL" ]; then
                print_error "Database URL not found. Please run database setup first."
                exit 1
            fi
            create_config
            ;;
        "install")
            print_header
            check_prerequisites
            install_gator
            ;;
        "help"|"-h"|"--help")
            usage
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
}

trap 'echo ""; print_status "Setup interrupted"' INT TERM

main "$@" 