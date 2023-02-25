package api

type Route struct {
	Package  Package
	FuncName string
	Method   string
	Request  string
	Response string
	Path     string
	Doc      string
}
