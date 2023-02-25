package logic

import (
	"{{.Package.Name}}/svc"
	"time"

	"github.com/gin-gonic/gin"
)

func {{.FuncName}}(sess *svc.Svc) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		time.Sleep(time.Minute)
	}
}
