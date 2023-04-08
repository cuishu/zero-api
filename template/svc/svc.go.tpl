package svc

import (
	"{{.Package.Name}}/config"

	"go.uber.org/zap"
)

type Svc struct {
	Config *config.Config
	Logger *zap.SugaredLogger
}

func NewSvc(conf *config.Config) Svc {
	logger, err := zap.NewProduction()
	if err != nil {
		panic(err)
	}
	return Svc{
		Config: conf,
		Logger: logger.Sugar(),
	}
}
