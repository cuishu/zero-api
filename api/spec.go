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
	CurrentUser string
	Name        string
	ShortName   string
}

func (p *Package) Set(name string) {
	p.Name = name
	slice := strings.Split(name, "/")
	p.ShortName = slice[len(slice)-1]
}

type Spec struct {
	Package               Package
	Document              string
	Info                  Info
	ApiName               string
	Types                 []Type
	Route                 []Route
	Template              Template
	ContainsMultipartFile bool
	ContainsFile          bool
	ContainsValidToken    bool
	Docs                  Document
}

var symbleMap map[string]Type = make(map[string]Type)

func ToSpec(spec *ast.Spec) Spec {
	var ret Spec
	ret.ApiName = spec.Service.Name
	ret.Document = spec.Comment
	ret.Info = toInfo(spec.Info)
	for _, item := range spec.Types {
		t := convertSpecType(item)
		ret.Types = append(ret.Types, t)
		symbleMap[item.Name] = t
	}
	for _, item := range spec.Service.Apis {
		input := symbleMap[item.Input]
		if input.HasFile {
			inputContainsMultipartFile = true
		}
		output := symbleMap[item.Output]
		if output.HasFile {
			outputContainsMultipartFile = true
		}
		if item.ValidToken {
			ret.ContainsValidToken = true
		}
		route := Route{
			FuncName:        item.Handler,
			Request:         item.Input,
			RequestFields:   input.Fields,
			Response:        item.Output,
			ResponseFields:  output.Fields,
			ResponseHasFile: output.HasFile,
			Path:            item.URI,
			Doc:             item.Comment,
			ValidToken:      item.ValidToken,
			Method:          strings.ToUpper(item.Method),
		}
		route.Check()
		ret.Route = append(ret.Route, route)
	}
	ret.Docs = NewDocument(spec)
	ret.ContainsFile = inputContainsMultipartFile || outputContainsMultipartFile
	ret.ContainsMultipartFile = inputContainsMultipartFile
	return ret
}
