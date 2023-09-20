package svc

import (
	"fmt"

	"github.com/Pacific73/gorm-cache/cache"
	cacheConfig "github.com/Pacific73/gorm-cache/config"
	"github.com/go-redis/redis/v8"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"gorm.io/gorm/schema"
	"{{.Package.Name}}/config"
)

func NewPostgres(conf *config.Postgres) *gorm.DB {
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%d sslmode=disable TimeZone=Asia/Shanghai",
		conf.Host, conf.User, conf.Password, conf.DBName, conf.Port)
	db, err:= gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger:                                   logger.Default.LogMode(logger.Info),
		DisableForeignKeyConstraintWhenMigrating: true,
		NamingStrategy: schema.NamingStrategy{
			SingularTable: true,
			TablePrefix:   "",
		},
	})
    if err != nil {
        panic(err)
    }
    return db
}

func InitPostgresWithCache(conf *config.Postgres, redisClient *redis.Client) (*gorm.DB, error) {
	db, err := InitPostgres(conf)
	if err != nil {
		return nil, err
	}
	cache, _ := cache.NewGorm2Cache(&cacheConfig.CacheConfig{
		CacheLevel:           cacheConfig.CacheLevelAll,
		CacheStorage:         cacheConfig.CacheStorageRedis,
		RedisConfig:          cache.NewRedisConfigWithClient(redisClient),
		InvalidateWhenUpdate: true, // when you create/update/delete objects, invalidate cache
		CacheTTL:             5000, // 5000 ms
		CacheMaxItemCnt:      50,   // if length of objects retrieved one single time
		// exceeds this number, then don't cache
	})
	db.Use(cache)
	return db, nil
}
