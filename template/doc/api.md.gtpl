# {{.Name}}接口文档

{{.Document}}

**作者:** {{.Info.Author}}
**版本:** {{.Info.Version}}

{{range .Apis}}
### {{.Document}}

**输入参数**
|名称|类型|校验规则|说明|
|:-:|:-:|:-:|:-:|
{{range .Params}}|{{.Name}}|{{.Type}}|{{.Validate}}|{{.Comment}}|
{{end}}

**返回值**
|名称|类型|说明|
|:-:|:-:|:-:|
{{range .Response}}|{{.Name}}|{{.Type}}|{{.Comment}}|
{{end}}

{{end}}