package svc

import 
(
	"github.com/go-redis/redis/v8"
	"{{.Package.Name}}/config"

	"go.uber.org/zap"
)

type Svc struct {
	Config *config.Config
	Logger *zap.SugaredLogger
	Redis  *redis.Client
	DB     *gorm.DB
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
