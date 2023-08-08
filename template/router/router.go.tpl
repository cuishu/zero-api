// Code generated by zero-api. DO NOT EDIT.

package router

import (
	"{{.Package.Name}}/logic"
	"{{.Package.Name}}/proto"
	"{{.Package.Name}}/svc"
	"context"{{if .ContainsMultipartFile}}
	"mime/multipart"{{else}}{{end}}{{if .ContainsFile}}
	"io"{{end}}
	"net/http"
{{if .ContainsValidToken}}
	
	"gitlab.qingyuantop.top/financial_freedom_league/validtoken"{{end}}
	"github.com/gin-gonic/gin"
)

const ApiVersion string = "{{.Info.Version}}"

func Fail(err error) gin.H {
	return gin.H{
		"fail": true,
		"msg":  err.Error(),
		"v": ApiVersion,
	}
}

func Success(data any) gin.H {
	return gin.H{
		"fail": false,
		"data": data,
		"v": ApiVersion,
	}
}

func RegisterRouter(r *gin.Engine, svctx svc.Svc) {
	middleware(&svctx, r)
	{{range .Route}}
	{{.Doc}}
	r.{{.Method}}("{{.Path}}", {{if .ValidToken}}validtoken.ValidToken(svctx.Config.PubKey, ApiVersion, {{end}}func(ctx *gin.Context) {
		var input proto.{{.Request}}
		{{if .ContainsMultipartFile}}
		var params struct {
			{{range .RequestFields}}{{.Name}} {{if .IsFile}}*multipart.FileHeader{{else}}{{if .IsBuiltinType}}proto.{{end}}{{.Type}}{{end}} {{.Tag}}
			{{end}}
		}
		if err := ctx.ShouldBind(&params); err != nil {
			ctx.JSON(http.StatusBadRequest, Fail(err))
			return
		}
		{{range .RequestFields}}{{if .IsFile}}
		if params.{{.Name}} != nil {
			if f, err := params.{{.Name}}.Open(); err != nil {
				ctx.JSON(http.StatusBadRequest, Fail(err))
				return
			} else {
				input.{{.Name}}.Filename = params.{{.Name}}.Filename
				input.{{.Name}}.Header = params.{{.Name}}.Header
				input.{{.Name}}.Size = params.{{.Name}}.Size
				input.{{.Name}}.File = f
			}
		}{{else}}
		input.{{.Name}} = params.{{.Name}}{{end}}{{end}}
		{{else}}if err := ctx.ShouldBind(&input); err != nil {
			ctx.JSON(http.StatusTeapot, Fail(err))
			return
		}
		{{end}}
		resp, err := logic.{{.FuncName}}(&svc.Session{
			Svc: svctx,
			Ctx: context.Background(),
		}, &input)
		if err != nil {
			ctx.JSON(http.StatusInternalServerError, Fail(err))
			return
		}
		{{if .ResponseHasFile}}{{range .ResponseFields}}
		defer resp.{{.Name}}.Close()
		ctx.Writer.Header().Add("Content-Type", resp.{{.Name}}.ContentType)
		io.Copy(ctx.Writer, &resp.{{.Name}})
		{{end}}{{else}}ctx.JSON(http.StatusOK, Success(resp)){{end}}
	}{{if .ValidToken}}){{end}})
	{{end}}
}
