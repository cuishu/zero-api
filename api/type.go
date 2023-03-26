package api

import (
	"github.com/cuishu/zero-api/ast"
)

var containsMultipartFile = false

type Field struct {
	Name      string
	Tag       string
	Type      string
	Documents string
}

type Type struct {
	Name      string
	TypeName  string
	Fields    []Field
	Documents string
}

func memberToField(member ast.Field) Field {
	t := member.Type
	if member.Type == "file" {
		t = "*multipart.FileHeader"
		containsMultipartFile = true
	}
	return Field{
		Name:      member.Name,
		Tag:       member.Tag,
		Type:      t,
		Documents: member.Comment,
	}
}

func convertSpecType(item ast.Type) Type {
	var t Type
	t.Name = item.Name
	t.Documents = item.Comment
	for _, member := range item.Fields {
		t.Fields = append(t.Fields, memberToField(member))
	}
	return t
}
