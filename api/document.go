package api

import (
	"strings"

	"github.com/cuishu/functools"
	"github.com/cuishu/zero-api/ast"
)

type DocApi struct {
	Document string
	URI      string
	Method   string
	Params   []DocParams
	Response []DocParams
}

type DocParams struct {
	Name     string
	Type     string
	Validate string
	Comment  string
}

type Document struct {
	Name     string
	Document string
	Info     ast.Info
	Apis     []DocApi
}

func NewDocument(spec *ast.Spec) Document {
	var document Document
	document.Name = spec.Service.Name
	document.Document = strings.Trim(strings.Trim(spec.Comment, "/"), "*")
	document.Info = spec.Info
	document.Apis = functools.Map(func(a ast.Api) DocApi {
		return DocApi{
			Document: strings.Trim(strings.Trim(a.Comment, "/"), "*"),
			URI:      a.URI,
			Method:   a.Method,
			Params: functools.Map(func(field Field) DocParams {
				tags := strings.Split(strings.Trim(field.Tag, "`"), " ")
				var name string
				var vali string
				for _, tag := range tags {
					slice := strings.Split(tag, ":")
					switch slice[0] {
					case "json", "form":
						name = strings.Trim(slice[1], `"`)
					case "binding":
						vali = strings.Trim(slice[1], `"`)
					}
				}
				return DocParams{
					Name:     name,
					Type:     field.Type,
					Validate: vali,
					Comment:  strings.Trim(strings.Trim(field.Documents, "/"), "*"),
				}
			}, symbleMap[a.Input].Fields),
			Response: functools.Map(func(field Field) DocParams {
				tags := strings.Split(strings.Trim(field.Tag, "`"), " ")
				var name string = "无"
				var vali string = "无"
				for _, tag := range tags {
					slice := strings.Split(tag, ":")
					switch slice[0] {
					case "json":
						name = strings.Trim(slice[1], `"`)
					case "binding":
						vali = strings.Trim(slice[1], `"`)
					}
				}
				return DocParams{
					Name:     name,
					Type:     field.Type,
					Validate: vali,
					Comment:  strings.Trim(strings.Trim(field.Documents, "/"), "*"),
				}
			}, symbleMap[a.Output].Fields),
		}
	}, spec.Service.Apis)
	return document
}
