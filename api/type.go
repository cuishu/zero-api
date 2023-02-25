package api

import (
	"strings"

	ft "github.com/cuishu/functools"
	"github.com/zeromicro/go-zero/tools/goctl/api/spec"
)

type Field struct {
	Name      string
	Tag       string
	Type      string
	Documents string
}

type Type struct {
	Name      string
	TypeName  string
	IsStruct  bool
	Fields    []Field
	Documents string
}

func memberToField(member spec.Member) Field {
	return Field{
		Name: member.Name,
		Tag:  member.Tag,
		Type: member.Type.Name(),
		Documents: strings.Join(ft.Map(func(x string) string {
			return strings.Replace(x, "\t", "  ", -1)
		}, member.Docs), "\n\t"),
	}
}

func convertSpecType(item spec.Type) Type {
	var t Type
	switch v := item.(type) {
	case spec.DefineStruct:
		t.Name = v.Name()
		t.Documents = strings.Join(ft.Map(func(x string) string {
			return strings.Replace(x, "\t", " ", -1)
		}, v.Docs), "\n\t")
		for _, member := range v.Members {
			t.Fields = append(t.Fields, memberToField(member))
		}
	default:
	}
	return t
}
