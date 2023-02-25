# zero-api

## INSTALL
```bash
go install github.com/cuishu/zero-api@latest
```

## 使用方法

**创建golang项目**
```bash
mkdir project && cd project
go mod init github.com/cuishu/api
```
**生成 api 模板文件**
```bash
zero-api -api
```
zero-api 会根据 go.mod 里定义的 package 生成 ```.api``` 文件

**生成项目模板**
```.api```文件修改完成后，执行
```
zero-api -f 你的 .api 文件
```

**业务逻辑在logic, 是需要关注的部分**

**包含```// Code generated by zero-api. DO NOT EDIT.```的文件是不可修改的文件，再次生成的时候```zero-api```会覆盖文件的内容**