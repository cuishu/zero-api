package api

import (
	"fmt"
	"strings"

	ft "github.com/cuishu/functools"
	"github.com/zeromicro/go-zero/tools/goctl/api/spec"
)

type Field struct {
	Name      string
	Type      string
	Documents spec.Doc
}

type Type struct {
	Name      string
	TypeName  string
	IsStruct  bool
	Fields    []Field
	Documents spec.Doc
}

func goTypeToTsType(t string) string {
	if strings.Index(t, "[]") == 0 {
		t = fmt.Sprintf("Array<%s>", goTypeToTsType(strings.TrimLeft(t, "[]")))
	}
	switch t {
	case "int", "int8", "int16", "int32", "int64",
		"uint", "uint8", "uint16", "uint32", "uint64",
		"float32", "float64":
		return "number"
	case "bool":
		return "boolean"
	default:
		return t
	}
}

func memberToField(member spec.Member) Field {
	tags := strings.Split(strings.Trim(member.Tag, "`"), " ")
	if len(tags) == 0 {
		return Field{}
	}
	return Field{
		Name: strings.Trim(strings.Split(tags[0], ":")[1], `"`),
		Type: goTypeToTsType(member.Type.Name()),
		Documents: ft.Map(func(x string) string  {
			return strings.Replace(x, "\t", "  ", -1)
		},member.Docs),
	}
}

func convertSpecType(item spec.Type) Type {
	var t Type
	switch v := item.(type) {
	case spec.DefineStruct:
		t.Name = v.Name()
		t.Documents = ft.Map(func(x string) string  {
			return strings.Replace(x, "\t", " ", -1)
		}, v.Docs)
		for _, member := range v.Members {
			t.Fields = append(t.Fields, memberToField(member))
		}
	default:
	}
	return t
}
