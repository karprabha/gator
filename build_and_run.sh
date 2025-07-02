#!/bin/bash

set -e

PROJECT_NAME="gator"
BINARY_NAME="gator"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

cleanup() {
    print_status "Cleaning up..."
    if [ -f "$BINARY_NAME" ]; then
        rm -f "$BINARY_NAME"
        print_success "Removed binary: $BINARY_NAME"
    fi
}

build() {
    print_status "Building $PROJECT_NAME..."

    if [ ! -f "go.mod" ]; then
        print_error "go.mod not found. Please run 'go mod init' first."
        exit 1
    fi

    print_status "Downloading dependencies..."
    go mod download

    go build -o "$BINARY_NAME" .

    if [ -f "$BINARY_NAME" ]; then
        print_success "Build completed successfully!"
        print_status "Binary created: $BINARY_NAME"
    else
        print_error "Build failed!"
        exit 1
    fi
}

test() {
    print_status "Running tests..."
    if go test -v ./...; then
        print_success "All tests passed!"
    else
        print_error "Some tests failed!"
        return 1
    fi
}

run() {
    print_status "Running $PROJECT_NAME..."

    if [ ! -f "$BINARY_NAME" ]; then
        print_warning "Binary not found. Building first..."
        build
    fi

    print_status "Starting the application..."
    ./"$BINARY_NAME"
}

usage() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  build     Build the project"
    echo "  test      Run tests"
    echo "  run       Run the project"
    echo "  all       Build, test, and run (default)"
    echo "  clean     Clean up build artifacts"
    echo "  help      Show this help message"
    echo ""
}

main() {
    case "${1:-all}" in
        "build")
            build
            ;;
        "test")
            test
            ;;
        "run")
            run
            ;;
        "all")
            print_status "Building, testing, and running $PROJECT_NAME..."
            build
            test
            run
            ;;
        "clean")
            cleanup
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

trap 'echo ""; print_status "Script interrupted"' INT TERM

main "$@"
