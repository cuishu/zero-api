package generator

import "github.com/cuishu/zero-api/api"

func GenerateProto(spec *api.Spec) {
	genFileOverwrite("proto/proto.go", spec.Template.Proto, spec)
	genFileOverwrite("proto/builtin.go", spec.Template.Builtin, spec)
}
