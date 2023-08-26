package api

import (
	"github.com/cuishu/zero-api/ast"
)

var (
	inputContainsMultipartFile  = false
	outputContainsMultipartFile = false
)

type Field struct {
	Name          string
	Tag           string
	Type          string
	IsFile        bool
	IsBuiltinType bool
	Documents     string
}

type Type struct {
	Name      string
	TypeName  string
	Fields    []Field
	Documents string
	HasFile   bool
}

func memberToField(member ast.Field) (Field, bool) {
	isBuiltinType := false
	t := member.Type
	var isFile bool
	switch member.Type {
	case "file":
		t = "File"
		isFile = true
	case "id":
		t = "ID"
		isBuiltinType = true
	case "uid":
		t = "UID"
		isBuiltinType = true
	case "phone":
		t = "Phone"
		isBuiltinType = true
	case "time":
		t = "Time"
		isBuiltinType = true
	}
	return Field{
		Name:          member.Name,
		Tag:           member.Tag,
		Type:          t,
		Documents:     member.Comment,
		IsFile:        isFile,
		IsBuiltinType: isBuiltinType,
	}, isFile
}

func convertSpecType(item ast.Type) Type {
	var t Type
	t.Name = item.Name
	t.Documents = item.Comment
	for _, member := range item.Fields {
		field, isFile := memberToField(member)
		t.Fields = append(t.Fields, field)
		if isFile {
			t.HasFile = true
		}
	}
	return t
}
