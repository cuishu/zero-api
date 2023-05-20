package api

type Route struct {
	Package               Package
	FuncName              string
	Method                string
	Request               string
	RequestFields         []Field
	Response              string
	Path                  string
	Doc                   string
	ContainsMultipartFile bool
}

func (route *Route) Check() {
	for _, field := range route.RequestFields {
		if field.IsFile {
			route.ContainsMultipartFile = true
			return
		}
	}
}
