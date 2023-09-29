package router

import (
	"io"
	"strings"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"{{.Package.Name}}/svc"
	"go.uber.org/zap"
)

type BodyLogger struct {
	gin.ResponseWriter
	io.ReadCloser
	ctx             *gin.Context
	r               io.ReadCloser
	w               io.Writer
	l               *zap.SugaredLogger
	contentType     string
	body            string
	resp            string
	respContentType string
	deltaT          time.Duration
}

var loggerPool = sync.Pool{
	New: func() any {
		return &BodyLogger{}
	},
}

func NewBodyLogger(ctx *gin.Context, logger *zap.SugaredLogger) *BodyLogger {
	bl := loggerPool.Get().(*BodyLogger)
	bl.ctx = ctx
	bl.r = ctx.Request.Body
	bl.w = ctx.Writer
	bl.l = logger
	bl.contentType = ctx.ContentType()
	bl.body = ""
	bl.ResponseWriter = ctx.Writer
	bl.resp = ""
	bl.respContentType = ""
	return bl
}

func (logger *BodyLogger) Read(p []byte) (int, error) {
	n, err := logger.r.Read(p)
	if logger.contentType == "application/json" || logger.contentType == "application/xml" {
		logger.body += string(p[:n])
	}
	return n, err
}

func (logger *BodyLogger) Close() error {
	return logger.r.Close()
}

func (logger *BodyLogger) Write(b []byte) (int, error) {
	if logger.respContentType == "" {
		logger.respContentType = logger.ctx.Writer.Header().Get("Content-Type")
	}
	if strings.Contains(logger.respContentType, "application/json") {
		logger.resp += string(b)
	}
	return logger.ResponseWriter.Write(b)
}

func (logger *BodyLogger) Info() {
	logger.l.Infow("request",
		"body", logger.body,
		"uri", logger.ctx.Request.URL,
		"method", logger.ctx.Request.Method,
		"Content-Type", logger.ctx.ContentType(),
		"remote_ip", logger.ctx.RemoteIP(),
		"traceid", logger.ctx.GetString("traceid"))
	logger.l.Infow("response",
		"body", logger.resp,
		"status", logger.ctx.Writer.Status(),
		"Content-Type", logger.respContentType,
		"traceid", logger.ctx.GetString("traceid"),
		"t", logger.deltaT)
}

func logger(svc *svc.Svc) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		defer svc.Logger.Sync()
		startTime := time.Now()
		bodyLogger := NewBodyLogger(ctx, svc.Logger)
		ctx.Request.Body = bodyLogger
		ctx.Writer = bodyLogger
		ctx.Next()
		bodyLogger.deltaT = time.Since(startTime)
		bodyLogger.Info()
		loggerPool.Put(bodyLogger)
	}
}
