/**
* 这里是 API 描述
*/
syntax = "v1"

info (
	title: // TODO: add title
	desc: // TODO: add description
	author: "cuishu"
	email: 
	version: v1.0.0
)

type (
	// 请求参数的详细描述
	addReq {
		// 每个filed都需要有注释
		Book  string `form:"book"`
		Price int64  `form:"price"`
		N []uint64 `form:"N"`
	}

	// 返回值
	addResp {
		Ok bool `json:"ok"`
	}
)

type (
	checkReq {
		Book string `form:"book"`
	}

	checkResp {
		Found bool  `json:"found"`
		Price int64 `json:"price"`
	}
)

/**
* service 需要有注释
*/
service {{.ShortName}} {
	// 每个api的注释
	@handler Add
	get /add (addReq) returns (addResp)
}