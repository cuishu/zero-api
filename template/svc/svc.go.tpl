package svc

import "{{.Package.Name}}/config"

type Svc struct {
	Config *config.Config
}

func NewSvc(conf *config.Config) Svc {
	return Svc{
		Config: conf,
	}
}
