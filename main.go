package main

import (
	_ "embed"
	"flag"
	"os"
	"strings"

	"github.com/cuishu/zero-api/api"
	"github.com/cuishu/zero-api/generator"
	parser "github.com/zeromicro/go-zero/tools/goctl/api/parser"
)

var (
	//go:embed template/example.api.gtpl
	exampleTemplate string
	//go:embed template/config/config.go.tpl
	configTmpl string
	//go:embed template/config/config.yaml.gtpl
	configYaml string
	//go:embed template/logic/logic.go.tpl
	logicTmpl string
	//go:embed template/router/router.go.tpl
	routerTmpl string
	//go:embed template/svc/svc.go.tpl
	svcTmpl string
	//go:embed template/main.go.tpl
	mainTmpl string
	//go:embed template/gitignore.gtpl
	gitignoreTmpl string
)

var (
	genExample  bool
	filename    string
	packagename string
)

func init() {
	flag.BoolVar(&genExample, "api", false, "generate example api filename")
	flag.StringVar(&filename, "f", "", "generate example api filename")
	flag.Parse()

	var pkg api.Package
	data, err := os.ReadFile("go.mod")
	if err != nil {
		panic(err)
	}
	slice := strings.Split(string(data), "\n")
	slice = strings.Split(slice[0], " ")
	packagename = slice[len(slice)-1]
	if genExample {
		pkg.Set(packagename)
		generator.GenAPI(exampleTemplate, &pkg)
		os.Exit(0)
	}
}

func main() {
	spec, err := parser.Parse(filename)
	if err != nil {
		panic(err)
	}
	if err := spec.Validate(); err != nil {
		panic(err)
	}
	apiSpec := api.ToSpec(spec)
	apiSpec.Template.Config = configTmpl
	apiSpec.Template.ConfigYaml = configYaml
	apiSpec.Template.Logic = logicTmpl
	apiSpec.Template.Router = routerTmpl
	apiSpec.Template.Svc = svcTmpl
	apiSpec.Template.Main = mainTmpl
	apiSpec.Template.Gitignore = gitignoreTmpl
	apiSpec.Package.Set(packagename)
	generator.GenerateCode(&apiSpec)
}
