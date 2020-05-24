package _αβx9

// https://github.com/syscrusher/golang.tmbundle/issues/36#issuecomment-250866224
func OkayReturn(x int) (string, error) {
	return "", nil
}

func BrokenNewlineReturn(name string) (string,
	error) {
	return "",
		nil
}

// https://github.com/syscrusher/golang.tmbundle/issues/36#issuecomment-250847018
type x struct{}

func (xx *x) OkayParam(a int) {
	return
}

func (xx *x) BrokenParenthesesParam(a func()) {
	return
}

func BrokenParenthesesParam2(a func()) {
	return
}

func (xx *x) OkayBracketParam(a interface{}) {
	return
}

func (xx *x) BrokenBracketParam(a struct{}) {
	return
}

func BrokenBracketParam2(a struct{}) {
	return
}

// https://github.com/syscrusher/golang.tmbundle/issues/36#issuecomment-260472685
func typeVarsOkay() {
	var typeVars []int
	typeVars = append(typeVars, 1)
}

func typeVarsBroken() {
	var typeVars []int
	v := struct{ a int }{1}
	typeVars = append(typeVars, v.a)
}
