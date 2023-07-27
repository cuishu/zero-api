package ast

//#include "ast.h"
import "C"
import (
	"strings"
	"unsafe"
)

type Info struct {
	Author  string
	Email   string
	Version string
}

type Field struct {
	Comment string
	Name    string
	Type    string
	Tag     string
}

type Type struct {
	Comment string
	Name    string
	Fields  []Field
}

type Api struct {
	Comment    string
	Handler    string
	Method     string
	URI        string
	Input      string
	Output     string
	ValidToken bool
}

type Service struct {
	Comment string
	Name    string
	Apis    []Api
}

type Spec struct {
	Comment string
	Info    Info
	Types   []Type
	Service Service
}

func (spec Spec) Validate() error {
	return nil
}

func toInfo(info *C.struct_info) Info {
	var ret Info
	ret.Author = C.GoString(info.author)
	ret.Email = C.GoString(info.email)
	ret.Version = C.GoString(info.version)
	return ret
}

func toFields(fieldsPtr *C.struct_list_head) []Field {
	var fields []Field
	ptr := fieldsPtr
	for {
		t := C.next_field(ptr, fieldsPtr)
		if unsafe.Pointer(t) == nil {
			break
		}
		fields = append(fields, Field{
			Comment: strings.TrimRight(C.GoString(t.comment), "\n"),
			Name:    C.GoString(t.name),
			Type:    C.GoString(t._type),
			Tag:     C.GoString(t.tag),
		})
		ptr = &t.node
	}
	return fields
}

func toTypes(typesPtr *C.struct_list_head) []Type {
	var ret []Type
	var ptr = typesPtr
	for {
		f := C.next_type(ptr)
		if unsafe.Pointer(f) == nil {
			break
		}
		fields := toFields(&f.fields)
		ret = append(ret, Type{
			Comment: strings.TrimRight(C.GoString(f.comment), "\n"),
			Name:    C.GoString(f.name),
			Fields:  fields,
		})
		ptr = &f.node
	}
	return ret
}

func toApis(apis *C.struct_list_head) []Api {
	var ret []Api
	ptr := apis
	for {
		a := C.next_api(ptr)
		if unsafe.Pointer(a) == nil {
			break
		}
		p := Api{
			Comment:    strings.TrimRight(C.GoString(a.comment), "\n"),
			Handler:    C.GoString(a.handler),
			Method:     C.GoString(a.method),
			URI:        C.GoString(a.uri),
			Input:      C.GoString(a.input),
			Output:     C.GoString(a.output),
			ValidToken: bool(a.valid_token),
		}
		ret = append(ret, p)
		ptr = &a.node
	}
	return ret
}

func toService(service *C.struct_service) Service {
	var ret Service
	ret.Comment = C.GoString(service.comment)
	ret.Name = C.GoString(service.name)
	ret.Apis = toApis(&service.apis)
	return ret
}

func Parse(filename string) *Spec {
	cstr := C.CString(filename)
	defer C.free(unsafe.Pointer(cstr))
	var spec Spec
	ast := C.yyparser(cstr)
	if unsafe.Pointer(ast) == nil {
		return nil
	}
	spec.Comment = C.GoString(ast.comment)
	spec.Info = toInfo(&ast.info)
	spec.Types = toTypes(&ast.types)
	spec.Service = toService(&ast.service)
	return &spec
}
