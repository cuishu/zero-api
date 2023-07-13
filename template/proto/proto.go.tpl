// Code generated by zero-api. DO NOT EDIT.

package proto

{{if .ContainsFile}}import (
	"io"
	"net/textproto"
)
{{end}}
{{if .ContainsFile}}
type File struct {
	Filename string
	Header   textproto.MIMEHeader
	Size     int64
	File     io.ReadCloser
}

func (f *File) Read(p []byte) (n int, err error) {
	return f.File.Read(p)
}

func (f *File) Close() error {
	return f.File.Close()
}
{{else}}{{end}}
{{range .Types}}
{{.Documents}}
type {{.Name}} struct {
{{range .Fields}}	{{.Documents}}
	{{.Name}} {{.Type}} {{.Tag}}
{{end}}}
{{end}}