package proto

import (
	"encoding/json"
	"fmt"
	"time"
	"gitlab.qingyuantop.top/financial_freedom_league/httputils"
	"gitlab.qingyuantop.top/financial_freedom_league/traceid"
)

type Client struct {
	Host    string
	Timeout time.Duration
	client  httputils.HttpClient
}

func NewClient(host string, timeout time.Duration) Client {
	return Client{
		Host:    host,
		Timeout: timeout,
		client:  httputils.NewHttpClient(timeout),
	}
}
{{range .Route}}
{{.Doc}}
func (client Client) {{.FuncName}}(ctx traceid.TraceContext, input {{.Request}}) (*{{.Response}}, error) {
	headers := make(httputils.Headers)
	headers["traceid"] = ctx.TraceId(){{if .ValidToken}}
	headers["X-Token"] = ctx.Token(){{end}}

	var resp struct {
		Fail bool `json:"fail"`
		Mesg string `json:"msg"`
		Data {{.Response}}
	}

	url := client.Host + "{{.Path}}"
	{{if eq .Method "GET"}}
	params := ""
	{{range .RequestFields}}params += fmt.Sprintf("{{.TagName}}=%v&", input.{{.Name}})
	{{end}}
	if params != "" {
		url += "?" + params
	}
	{{if .ResponseHasFile}}readCloser, contentType, err := client.client.DoRequest(url, "{{.Method}}", headers, nil)
    {{else}}readCloser, _, err := client.client.DoRequest(url, "{{.Method}}", headers, nil)
    {{end}}
	if err != nil {
		return nil, err
	}
	{{else}}
	{{if .ContainsMultipartFile}}
	var params httputils.MultipartParams
    var isFile bool
	{{range .RequestFields}} {{if .IsFile}}isFile = true{{else}}isFile = false{{end}}
	params = append(params, httputils.MultipartParam{
		FieldName: "{{.TagName}}",
		IsFile: isFile,
		Filename: input.File.Filename,
		Reader: &input.File,
	})
	{{end}}
	{{if .ResponseHasFile}}readCloser, contentType,  err := client.client.DoMultipartRequest()
	{{else}}readCloser, err := client.client.DoMultipartRequest(url, "{{.Method}}", headers, params){{end}}
	{{else}}readCloser, _, err := client.client.DoRequest(url, "{{.Method}}", headers, &input)
	{{end}}if err != nil {
		return nil, err
	}
	{{end}}
	{{if .ResponseHasFile}}resp.Data.File.From(readCloser, contentType)
	{{else}}defer readCloser.Close()
	if err := json.NewDecoder(readCloser).Decode(&resp); err != nil {
		return nil, err
	}
	{{end}}
	return &resp.Data, nil
}
{{end}}
