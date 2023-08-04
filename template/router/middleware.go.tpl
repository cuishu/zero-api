package router

import (
	"{{.Package.Name}}/svc"

	"github.com/gin-gonic/gin"
)

func logger(svc *svc.Svc) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		defer svc.Logger.Sync()
		ctx.Next()
	}
}

// 处理跨域请求,支持options访问
func Cors() gin.HandlerFunc {
	return func(c *gin.Context) {
		method := c.Request.Method

		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE, UPDATE")
		c.Header("Access-Control-Allow-Headers", "*")
		c.Header("Access-Control-Expose-Headers", "Content-Length, Access-Control-Allow-Origin, Access-Control-Allow-Headers, Cache-Control, Content-Language, Content-Type")
		c.Header("Access-Control-Allow-Credentials", "true")

		//放行所有OPTIONS方法
		if method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
		}
		// 处理请求
		c.Next()
	}
}

func middleware(svc *svc.Svc, r *gin.Engine) {
	r.Use(logger(svc))
	r.Use(Cors())
}
