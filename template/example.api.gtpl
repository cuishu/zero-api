/**
* 这里是 API 描述
*/

info (
	author: {{.CurrentUser}}
	email: required@mail.com
	version: v1.0.0
)

// 请求参数的详细描述
type AddReq {
	// 每个filed都需要有注释
	Book  string `form:"book"`
	Price int64  `form:"price"`
	N []uint64 `form:"N"`
}

// 返回值
type AddResp {
	Ok bool `json:"ok"`
}


type CheckReq {
	Book string `form:"book"`
}

type CheckResp {
	Found bool  `json:"found"`
	Price int64 `json:"price"`
}

/**
* service 需要有注释
*/
service {{.ShortName}} {
	// 每个api的注释
	@handler Add
	get /add (AddReq) returns (AddResp)
}