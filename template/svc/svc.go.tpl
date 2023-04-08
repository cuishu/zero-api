package svc

import (
	"{{.Package.Name}}/config"

	"go.uber.org/zap"
)

type Svc struct {
	Config *config.Config
	Logger *zap.SugaredLogger
}

func newLogger() *zap.SugaredLogger {
	logger, err := zap.NewProduction()
	if err != nil {
		panic(err)
	}
	return logger.Sugar()
}

func NewSvc(conf *config.Config) Svc {
	return Svc{
		Config: conf,
		Logger: newLogger(),
	}
}
