package svc

import (
	"context"
	"fmt"

	"github.com/go-redis/redis/v8"
	"qingyuantop.top/account/config"
)

func NewRedis(conf *config.RedisConfig) *redis.Client {
	rdb := redis.NewClient(&redis.Options{
		Addr:     conf.Host,
		Password: conf.Password,
		DB:       conf.DB,
	})
	if err := rdb.Ping(context.Background()).Err(); err != nil {
		fmt.Println(err)
		panic(err)
	}
	return rdb
}
