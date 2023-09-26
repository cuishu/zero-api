package router

import (
	"io"

	"github.com/gin-gonic/gin"
	"gitlab.qingyuantop.top/financial_freedom_league/idphoto/svc"
	"go.uber.org/zap"
)

type BodyLogger struct {
	gin.ResponseWriter
	io.ReadCloser
	ctx         *gin.Context
	r           io.ReadCloser
	w           io.Writer
	l           *zap.SugaredLogger
	contentType string
	body        string
}

func NewBodyLogger(ctx *gin.Context, logger *zap.SugaredLogger) *BodyLogger {
	return &BodyLogger{
		ctx:         ctx,
		r:           ctx.Request.Body,
		w:           ctx.Writer,
		l:           logger,
		contentType: ctx.ContentType(),
	}
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

func (logger *BodyLogger) Info() {
	logger.l.Infow("request",
		"body", logger.body,
		"uri", logger.ctx.Request.URL,
		"method", logger.ctx.Request.Method,
		"Content-Type", logger.contentType,
		"traceid", logger.ctx.GetString("traceid"))
	logger.body = ""
}

func logger(svc *svc.Svc) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		defer svc.Logger.Sync()
		ctx.ContentType()
		bodyLogger := NewBodyLogger(ctx, svc.Logger)
		ctx.Request.Body = bodyLogger
		ctx.Next()
		bodyLogger.Info()
	}
}
