package main

import (
	"{{.Package.Name}}/config"
	"{{.Package.Name}}/router"
	"flag"
	"fmt"
	"os"

	"github.com/gin-gonic/gin"
)

var (
	BuildTime string
	Version   string
)

func init() {
	var showVersion bool
	flag.BoolVar(&showVersion, "v", false, "")
	flag.Parse()
	if showVersion {
		fmt.Println("version: ", Version)
		fmt.Println("build at:", BuildTime)
		os.Exit(0)
	}
}

func main() {
	config, err := config.NewConfig("config/config.yaml")
	if err != nil {
		panic(err)
	}

	r := gin.Default()
	router.RegisterRouter(r)
	r.Run(config.Listen)
}
