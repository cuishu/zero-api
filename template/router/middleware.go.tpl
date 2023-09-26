package router

import (
{{if .ContainsValidToken}}
	"context"
	"github.com/go-redis/redis/v8"
	"gitlab.qingyuantop.top/financial_freedom_league/validtoken"{{end}}
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

func traceid(svc *svc.Svc) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		traceid := ctx.GetHeader("traceid")
		if traceid == "" {
			sfid, err := svc.Sonyflake.NextID()
			if err != nil {
				return
			}
			ctx.Set("traceid", strconv.FormatUint(sfid, 10))
		}
		ctx.Next()
	}
}

func middleware(svc *svc.Svc, r *gin.Engine) {
	r.Use(traceid(svc))
	r.Use(logger(svc))
}
