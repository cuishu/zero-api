package main

import (
	_ "embed"
	"flag"
	"os"
	"os/user"
	"strings"

	"github.com/cuishu/zero-api/api"
	"github.com/cuishu/zero-api/ast"
	"github.com/cuishu/zero-api/generator"
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
	//go:embed template/router/middleware.go.tpl
	middlewareTmpl string
	//go:embed template/svc/svc.go.tpl
	svcTmpl string
	//go:embed template/main.go.tpl
	mainTmpl string
	//go:embed template/gitignore.gtpl
	gitignoreTmpl string
	//go:embed template/build.sh.gtpl
	buildSHTmpl string
	//go:embed template/Makefile.gtpl
	makefileTmpl string
	//go:embed template/Dockerfile.gtpl
	dockerfileTmpl string
	//go:embed template/proto/proto.go.tpl
	protoTmpl string
	//go:embed template/svc/session.go.tpl
	sessionTmpl string
	//go:embed template/doc/api.md.gtpl
	docAPITmpl string
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
	slice := strings.Split(
		strings.ReplaceAll(
			strings.ReplaceAll(string(data), "\r\n", "\n"),
			"\r", "\n"),
		"\n")
	slice = strings.Split(slice[0], " ")
	packagename = slice[len(slice)-1]
	if genExample {
		user, err := user.Current()
		if err != nil {
			panic(err.Error())
		}
		pkg.CurrentUser = user.Username
		pkg.Set(packagename)
		generator.GenAPI(exampleTemplate, &pkg)
		os.Exit(0)
	}
	if filename == "" {
		return
	}
}

func mkdirAll() {
	os.MkdirAll("config", 0755)
	os.MkdirAll("logic", 0755)
	os.MkdirAll("router", 0755)
	os.MkdirAll("svc", 0755)
	os.MkdirAll("proto", 0755)
	os.MkdirAll("doc", 0755)
}

func main() {
	spec := ast.Parse(filename)
	if spec == nil {
		return
	}
	if err := spec.Validate(); err != nil {
		panic(err)
	}
	apiSpec := api.ToSpec(spec)
	apiSpec.Template.Config = configTmpl
	apiSpec.Template.ConfigYaml = configYaml
	apiSpec.Template.Logic = logicTmpl
	apiSpec.Template.Router = routerTmpl
	apiSpec.Template.Middleware = middlewareTmpl
	apiSpec.Template.Svc = svcTmpl
	apiSpec.Template.Main = mainTmpl
	apiSpec.Template.Gitignore = gitignoreTmpl
	apiSpec.Template.BuildSH = buildSHTmpl
	apiSpec.Template.Makefile = makefileTmpl
	apiSpec.Template.Dockerfile = dockerfileTmpl
	apiSpec.Template.Proto = protoTmpl
	apiSpec.Template.Session = sessionTmpl
	apiSpec.Template.DocAPI = docAPITmpl
	mkdirAll()
	apiSpec.Package.Set(packagename)
	generator.GenerateCode(&apiSpec)
	generator.GenerateProto(&apiSpec)
}
