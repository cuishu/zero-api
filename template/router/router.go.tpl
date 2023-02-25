package router

import (
	"{{.Package.Name}}/logic"
	"{{.Package.Name}}/svc"

	"github.com/gin-gonic/gin"
)

func RegisterRouter(r *gin.Engine) {
	{{range .Route}}
	{{.Doc}}
	r.{{.Method}}({{.Path}}, logic.{{.FuncName}}(&svc.Svc{}))
	{{end}}
}
