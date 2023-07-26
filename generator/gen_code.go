package generator

import (
	"fmt"
	"os"
	"os/exec"
	"text/template"

	"github.com/cuishu/zero-api/api"
	"golang.org/x/text/cases"
	"golang.org/x/text/language"
)

func genFileOverwrite(filename, tmpl string, spec any) {
	t, err := template.New(filename).Parse(tmpl)
	if err != nil {
		panic(err)
	}
	file, err := os.OpenFile(filename, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
	if err != nil {
		panic(err)
	}
	if err := t.Execute(file, spec); err != nil {
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
	file, err := os.OpenFile(filename, os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		panic(err)
	}
	if err := t.Execute(file, spec); err != nil {
		panic(err)
	}
}

func GenAPI(tmpl string, pkg *api.Package) {
	filename := fmt.Sprintf("%s.api", pkg.ShortName)
	pkg.ShortName = cases.Title(language.English).String(pkg.ShortName)
	genFile(filename, tmpl, pkg)
}

func genConfig(spec *api.Spec) {
	genFile("config/config.go", spec.Template.Config, spec)
	genFile("config/config.yaml", spec.Template.ConfigYaml, spec)
	genFile("config/config.yaml.example", spec.Template.ConfigYaml, spec)
}

func genLogic(spec *api.Spec) {
	for _, logic := range spec.Route {
		filename := fmt.Sprintf("logic/%s.go", logic.FuncName)
		if _, err := os.Stat(filename); err == nil {
			continue
		}
		logic.Package = spec.Package
		genFile(filename, spec.Template.Logic, logic)
	}
}

func genRouter(spec *api.Spec) {
	genFileOverwrite("router/router.go", spec.Template.Router, spec)
}

func genMiddleware(spec *api.Spec) {
	genFile("router/middleware.go", spec.Template.Middleware, spec)
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

func genBuildSH(spec *api.Spec) {
	genFile("build.sh", spec.Template.BuildSH, spec)
}

func genMakefile(spec *api.Spec) {
	genFile("Makefile", spec.Template.Makefile, spec)
}

func genVersion() {
	genFile("VERSION", "v0.0.0", nil)
}

func genDockerFile(spec *api.Spec) {
	genFile("Dockerfile", spec.Template.Dockerfile, spec)
}

func genSession(spec *api.Spec) {
	genFileOverwrite("svc/session.go", spec.Template.Session, spec)
}

func genApiDoc(spec *api.Spec) {
	genFileOverwrite("doc/api.md", spec.Template.DocAPI, spec.Docs)
}

func genDrone(spec *api.Spec) {
	genFile(".drone.yml", spec.Template.Drone, spec)
}

func GenerateCode(spec *api.Spec) {
	genConfig(spec)
	genLogic(spec)
	genMiddleware(spec)
	genRouter(spec)
	genSvc(spec)
	genGitignore(spec)
	genMain(spec)
	genBuildSH(spec)
	genMakefile(spec)
	genVersion()
	genDockerFile(spec)
	genSession(spec)
	genApiDoc(spec)
	genDrone(spec)

	cmd := exec.Command("go", "mod", "tidy")
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Run()
}
