package router

import (
	"{{.Package.Name}}/svc"

	"github.com/gin-gonic/gin"
)
{{if .ContainsValidToken}}
func hasKey(redisClient *redis.Client) validtoken.HasKeyFunc {
	return func(key string) bool {
		return redisClient.Get(context.Background(), key).Err() == nil
	}
}
{{end}}
func logger(svc *svc.Svc) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		defer svc.Logger.Sync()
		ctx.Next()
	}
}

func middleware(svc *svc.Svc, r *gin.Engine) {
	r.Use(logger(svc))
}
