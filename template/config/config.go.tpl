package config

import (
	"os"

	"gopkg.in/yaml.v3"
)

type Etcd struct {
	Hosts []string `yaml:"hosts"`
}

type Redis struct {
	Host     string `yaml:"host"`
	DB       int    `yaml:"db"`
	Password string `yaml:"password"`
}

type Postgres struct {
	Host     string `yaml:"host"`
	Port     int    `yaml:"port"`
	User     string `yaml:"user"`
	Password string `yaml:"password"`
	DBName   string `yaml:"dbname"`
}

type Config struct {
	PublicKey string   `yaml:"public_key"`
	Listen    string   `yaml:"listen"`
	Etcd      Etcd     `yaml:"etcd"`
	Redis     Redis    `yaml:"redis"`
	Postgres  Postgres `yaml:"postgres"`
}

func NewConfig(filename string) (*Config, error) {
	var conf Config
	data, err := os.ReadFile(filename)
	if err != nil {
		return nil, err
	}
	if err := yaml.Unmarshal(data, &conf); err != nil {
		return nil, err
	}
	return &conf, nil
}
