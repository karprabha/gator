package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	"github.com/karprabha/gator/internal/commands"
	"github.com/karprabha/gator/internal/config"
	"github.com/karprabha/gator/internal/database"
	"github.com/karprabha/gator/internal/middleware"
	_ "github.com/lib/pq"
)

func main() {
	cfg, err := config.Read()
	if err != nil {
		log.Fatalf("Error reading config: %v", err)
	}

	db, err := sql.Open("postgres", cfg.DBUrl)
	if err != nil {
		log.Fatalf("Error opening database: %v", err)
	}

	dbQueries := database.New(db)

	programState := &commands.State{Cfg: cfg, DB: dbQueries}

	cmds := commands.NewCommands()

	cmds.Register("agg", commands.HandlerAgg)
	cmds.Register("feeds", commands.HandlerFeeds)
	cmds.Register("reset", commands.HandlerReset)
	cmds.Register("login", commands.HandlerLogin)
	cmds.Register("users", commands.HandlerUsers)
	cmds.Register("register", commands.HandlerRegister)
	cmds.Register("follow", middleware.MiddlewareLoggedIn(commands.HandlerFollow))
	cmds.Register("addfeed", middleware.MiddlewareLoggedIn(commands.HandlerAddfeed))
	cmds.Register("unfollow", middleware.MiddlewareLoggedIn(commands.HandlerUnfollow))
	cmds.Register("following", middleware.MiddlewareLoggedIn(commands.HandlerFollowing))

	args := os.Args
	if len(args) < 2 {
		fmt.Println("Error: not enough arguments provided")
		os.Exit(1)
	}

	cmdName := args[1]
	cmdArgs := []string{}
	if len(args) > 2 {
		cmdArgs = args[2:]
	}

	cmd := commands.Command{
		Name: cmdName,
		Args: cmdArgs,
	}

	err = cmds.Run(programState, cmd)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}
}
