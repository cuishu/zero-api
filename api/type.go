package api

import (
	"strings"

	"github.com/cuishu/zero-api/ast"
)

var (
	inputContainsMultipartFile  = false
	outputContainsMultipartFile = false
)

type Field struct {
	Name          string
	Tag           string
	TagName       string
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

func (field *Field) setTagName() {
	field.TagName = field.Name
	tags := strings.Split(strings.Trim(field.Tag, "`"), " ")
	if len(tags) == 0 {
		return
	}
	for _, tag := range tags {
		slice := strings.Split(tag, ":")
		switch slice[0] {
		case "json", "form":
			field.TagName = strings.Trim(slice[1], `"`)
		}
	}
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
	case "decimal":
		t = "Decimal"
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
		field.setTagName()
		t.Fields = append(t.Fields, field)
		if isFile {
			t.HasFile = true
		}
	}
	return t
}
