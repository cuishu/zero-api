package router

import (
	"{{.Package.Name}}/svc"

	"github.com/gin-gonic/gin"
)

func getToken(key string) (string, error) {
	return "", nil
}

func logger(svc *svc.Svc) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		defer svc.Logger.Sync()
		ctx.Next()
	}
}

func middleware(svc *svc.Svc, r *gin.Engine) {
	r.Use(logger(svc))
}
