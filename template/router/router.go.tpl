// Code generated by zero-api. DO NOT EDIT.

package router

import (
	"{{.Package.Name}}/logic"
	"{{.Package.Name}}/proto"
	"{{.Package.Name}}/svc"
	"context"{{if .ContainsMultipartFile}}
	"mime/multipart"{{else}}{{end}}{{if .ResponseFile}}
	"io"{{end}}
	"net/http"
{{if .ContainsValidToken}}
	
	"gitlab.qingyuantop.top/financial_freedom_league/validtoken"{{end}}
	"github.com/gin-gonic/gin"
)

const ApiVersion string = "{{.Info.Version}}"

type failData struct {
	Fail    bool   `json:"fail"`
	Mesg    string `json:"msg"`
	Version string `json:"v"`
}

func Fail(err error) failData {
	return failData{
		Fail:    true,
		Mesg:    err.Error(),
		Version: ApiVersion,
	}
}

type successData struct {
	Fail    bool   `json:"fail"`
	Data    any    `json:"data"`
	Version string `json:"v"`
}

func Success(data any) successData {
	return successData{
		Fail:    false,
		Data:    data,
		Version: ApiVersion,
	}
}

func RegisterRouter(r *gin.Engine, svctx svc.Svc) {
	middleware(&svctx, r){{if .ContainsValidToken}}
	validTokenConfig := validtoken.Config{
		PublicKey: svctx.Config.PublicKey,
		ApiVersion: ApiVersion,
		HasKey: hasKey(svctx.Redis),
	}{{end}}
	{{range .Route}}
	{{.Doc}}
	r.{{.Method}}("{{.Path}}", {{if .ValidToken}}validtoken.ValidToken(&validTokenConfig, {{end}}func(ctx *gin.Context) {
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
			ctx.JSON(http.StatusBadRequest, Fail(err))
			return
		}
		{{end}}
		resp, err := logic.{{.FuncName}}(&svc.Session{
			Svc: svctx,
			Context: context.Background(),{{if .ValidToken}}
			UserID: ctx.GetInt64("user_id"),{{end}}
			TraceID: ctx.GetString("traceid"),
		}, &input)
		if err != nil {
			if e, ok := err.(proto.Error); ok {
				ctx.JSON(e.Code, Fail(e))
			} else {
				ctx.JSON(http.StatusTeapot, Fail(err))
			}
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
