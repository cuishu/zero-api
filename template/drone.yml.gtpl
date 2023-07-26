kind: pipeline
type: docker
name: default

steps:
- name: build
  image: golang
  commands:
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
