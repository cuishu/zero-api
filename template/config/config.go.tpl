package config

import (
	"os"

	"gopkg.in/yaml.v3"
)

type Etcd struct {
	Hosts []string `yaml:"hosts"`
}

type Config struct {
	PubKey string      `yaml:"pubkey"`
	Listen string      `yaml:"listen"`
	Etcd   Etcd        `yaml:"etcd"`
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
