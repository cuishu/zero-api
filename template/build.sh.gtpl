#!/bin/bash

if [ ! $1 ]; then
    echo "程序名为空"
    exit
elif [ ! $2 ]; then
    echo "docker registry地址为空"
    exit
fi

export CGO_ENABLED=0
name=$1
registry=$2
buildTime=`date "+%F %T"`

read v < VERSION
a=`echo $v|awk -F '.' '{print $1}'`
b=`echo $v|awk -F '.' '{print $2}'`
c=`echo $v|awk -F '.' '{print $3}'`
let "((c=c+1))"
version="$a.$b.$c"
echo $version > VERSION

go build -ldflags "-X 'main.Version=$version' -X 'main.BuildTime=$buildTime' -X 'main.GoVersion=`go version`'" -tags "netgo  jsoniter" .
podman build -t $registry/$name:$version .