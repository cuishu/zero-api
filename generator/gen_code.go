package generator

import (
	"fmt"
	"os"
	"strings"
	"text/template"

	"github.com/cuishu/zero-api/api"
)

func genFileOverwrite(filename, tmpl string, spec any) {
	t, err := template.New(filename).Parse(tmpl)
	if err != nil {
		panic(err)
	}
	// file, err := os.OpenFile(filename, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
	// if err != nil {
	// 	panic(err)
	// }
	if err := t.Execute(os.Stdout, spec); err != nil {
		panic(err)
	}
}

func genFile(filename, tmpl string, spec any) {
	if _, err := os.Stat(filename); err == nil {
		return
	}
	t, err := template.New(filename).Parse(tmpl)
	if err != nil {
		panic(err)
	}
	// file, err := os.OpenFile(filename, os.O_CREATE|os.O_WRONLY, 0644)
	// if err != nil {
	// 	panic(err)
	// }
	if err := t.Execute(os.Stdout, spec); err != nil {
		panic(err)
	}
}

func GenAPI(tmpl string, pkg *api.Package) {
	filename := fmt.Sprintf("%s.api", pkg.ShortName)
	pkg.ShortName = strings.ToTitle(pkg.ShortName)
	genFile(filename, tmpl, pkg)
}

func genConfig(spec *api.Spec) {
	genFile("config/config.go", spec.Template.Config, spec)
	genFile("config/config.yaml", spec.Template.ConfigYaml, spec)
	genFile("config/config.yaml.example", spec.Template.ConfigYaml, spec)
}

func genLogic(spec *api.Spec) {
	t, err := template.New("logic.go").Parse(spec.Template.Logic)
	if err != nil {
		panic(err)
	}
	for _, logic := range spec.Route {
		filename := fmt.Sprintf("logic/%s.go", logic.FuncName)
		if _, err := os.Stat(filename); err == nil {
			continue
		}
		logic.Package = spec.Package
		// file, err := os.OpenFile(filename, os.O_CREATE|os.O_WRONLY, 0644)
		// if err != nil {
		// 	panic(err)
		// }
		if err := t.Execute(os.Stdout, logic); err != nil {
			panic(err)
		}
	}
}

func genRouter(spec *api.Spec) {
	genFileOverwrite("router/router.go", spec.Template.Router, spec)
}

func genSvc(spec *api.Spec) {
	genFile("svc/svc.go", spec.Template.Svc, spec)
}

func genGitignore(spec *api.Spec) {
	genFile(".gitignore", spec.Template.Gitignore, spec)
}

func genMain(spec *api.Spec) {
	genFileOverwrite("main.go", spec.Template.Main, spec)
}

func GenerateCode(spec *api.Spec) {
	genConfig(spec)
	genLogic(spec)
	genRouter(spec)
	genSvc(spec)
	genGitignore(spec)
	genMain(spec)
}
