package router

import (
{{if .ContainsValidToken}}
	"context"
	"github.com/go-redis/redis/v8"
	"gitlab.qingyuantop.top/financial_freedom_league/validtoken"{{end}}
	"gitlab.qingyuantop.top/financial_freedom_league/traceid"
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

func injectTraceID(svc *svc.Svc) gin.HandlerFunc {
	generator := traceid.NewGenerator()
	return func(ctx *gin.Context) {
		traceid := ctx.GetHeader("traceid")
		if traceid == "" {
			traceid = generator.GenTraceID()
		}
		ctx.Set("traceid", traceid)
		ctx.Next()
	}
}

func middleware(svc *svc.Svc, r *gin.Engine) {
	r.Use(injectTraceID(svc))
	r.Use(logger(svc))
}
