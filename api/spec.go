package api

import (
	"strings"

	"github.com/cuishu/zero-api/ast"
)

type Info struct {
	Title   string
	Desc    string
	Author  string
	Email   string
	Version string
}

func toInfo(props ast.Info) Info {
	var info Info
	info.Author = props.Author
	info.Email = props.Email
	info.Version = props.Version
	if info.Version == "" {
		panic("Info 中缺少版本号")
	}
	return info
}

type Package struct {
	Name      string
	ShortName string
}

func (p *Package) Set(name string) {
	p.Name = name
	slice := strings.Split(name, "/")
	p.ShortName = slice[len(slice)-1]
}

type Spec struct {
	Package               Package
	Info                  Info
	ApiName               string
	Types                 []Type
	Route                 []Route
	Template              Template
	ContainsMultipartFile bool
}

func ToSpec(spec *ast.Spec) Spec {
	var ret Spec
	ret.ApiName = spec.Service.Name
	ret.Info = toInfo(spec.Info)
	for _, item := range spec.Types {
		ret.Types = append(ret.Types, convertSpecType(item))
	}
	for _, item := range spec.Service.Apis {
		ret.Route = append(ret.Route, Route{
			FuncName: item.Handler,
			Request:  item.Input,
			Response: item.Output,
			Path:     item.URI,
			Doc:      item.Comment,
			Method:   strings.ToUpper(item.Method),
		})
	}
	ret.ContainsMultipartFile = containsMultipartFile
	return ret
}
