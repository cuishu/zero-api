package generator

import "github.com/cuishu/zero-api/api"

func GenerateProto(spec *api.Spec) {
	genFileOverwrite("proto/proto.go", spec.Template.Proto, spec)
}
