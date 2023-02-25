package logic

import (
	"{{.Package.Name}}/svc"
	"{{.Package.Name}}/proto"
)

{{.Doc}}
func {{.FuncName}}(sess *svc.Session, input *proto.{{.Request}}) (*proto.{{.Response}}, error) {
	var resp proto.{{.Response}}
	return &resp, nil
}
