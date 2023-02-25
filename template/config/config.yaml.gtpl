service_name: comment.rpc
listen: 0.0.0.0:5678
etcd:
  hosts:
    - 127.0.0.1:2379

db:
  host: mongodb://localhost:27017
  username: admin
  password: "123456"
  database: mall
  collections:
    comment: comment
    like: like
    collect: collect

redis:
  # host: 192.168.3.8:6379
  host: 127.0.0.1:6379
  db: 1
  password:
