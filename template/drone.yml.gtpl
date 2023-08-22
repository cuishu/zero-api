kind: pipeline
type: docker
name: default

steps:
- name: build
  image: golang
  volumes:
    - name: gopath
      path: /gopath
  commands:
  - export GOPATH=/gopath
  - go env -w GOPROXY=https://goproxy.cn,direct
  - export CGO_ENABLED=0
  - go build -tags netgo
- name: build image
  image: plugins/docker
  privileged: true
  settings:
    repo: {{.Package.Name}}
    auto_tag: true
    registry: gitlab.qingyuantop.top
    username:
      from_secret: username
    password:
      from_secret: password
- name: deploy
  image: appleboy/drone-ssh
  settings:
    host: deploy.server
    username:
      from_secret: ssh_user
    password:
      from_secret: ssh_passwd
    port: 22
    command_timeout: 5m
    script:
      - cd /root/deploy
      - docker-compose pull {{.Package.ShortName}}
      - docker-compose up -d
  volumes:
    - name: hosts
      path: /etc/hosts
volumes:
  - name: hosts
    host:
      path: /etc/hosts
  - name: gopath
    host:
      path: /root/gopath
