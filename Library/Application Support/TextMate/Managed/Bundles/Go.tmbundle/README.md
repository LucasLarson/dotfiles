# golang.tmbundle
(a [TextMate 2](https://github.com/textmate/textmate) bundle for the [go programming language](https://golang.org))

## Features

- Syntax highlighting
- Run, build, test, and install packages
- Code completion with gocode
- View documentation with gogetdoc (Requires Go 1.6+)
- Formatting with gofmt
- Automatic imports with goimports
- Linting with golint
- Multiple linters supported with gometalinter
- Rename go identifiers with gorename
- Find symbol information with godef
- 45 snippets

## Installation
TextMate should detect .go files and load this bundle automatically. Syntax highlighting will work, but commands may not.

This bundle relies on amazing open source tooling for some functionality. These utilities can be installed with the following commands:

Command											| Use
-------											| ---
go get -u github.com/nsf/gocode					| Code completion
go get -u github.com/zmb3/gogetdoc				| Documentation
go get -u golang.org/x/tools/cmd/goimports		| Package import resolution/rewriting
go get -u github.com/golang/lint/golint			| Standard linter
go get -u github.com/alecthomas/gometalinter	| Combination of multiple linters
go get -u github.com/rogpeppe/godef				| goto definition
go get -u golang.org/x/tools/cmd/gorename		| Rename go identifiers

### TextMate Variables
TextMate does not inherit the users environment unless it is launched from the command line.
You may have to set TM_GOPATH and GOROOT inside of TextMate for all functionality to work.
You do not have to set TM_GOPATH if your GOPATH is ~/go and you are running [Go >1.8](https://golang.org/doc/go1.8#gopath).
You do not have to set GOROOT in most circumstances. See [here](https://dave.cheney.net/2013/06/14/you-dont-need-to-set-goroot-really) for more information.

You may override the following TextMate variables in the preferences, but most of these should be unnecessary (adjust paths to your own configuration):

Variable		| Suggested location
--------		| ------------------
TM_GO			| /usr/local/bin/go
TM_GOPATH		| /Users/myuser/go
GOROOT			| /usr/local/opt/go/libexec
TM_GOFMT		| /Users/myuser/go/bin/gofmt OR TM_GOFMT=/Users/myuser/go/bin/goimports for automatic import resolution on file save
TM_GOCODE		| /Users/myuser/go/bin/gocode
TM_GOGETDOC		| /Users/myuser/go/bin/gogetdoc
TM_GOIMPORTS	| /Users/myuser/go/bin/goimports
TM_GOLINT		| /Users/myuser/go/bin/golint
TM_GODEF		| /Users/myuser/go/bin/godef
TM_GOMETALINTER	| /Users/myuser/go/bin/gometalinter
TM_GORENAME		| /Users/myuser/go/bin/gorename

## Commands

Shortcut		|	Content
------- 		|	-------
Cmd-R			|	Compile and run the current file.
Cmd-Shift-R		|	Compile and test the current package.
Cmd-B			|	Build the current package.
Cmd-Shift-I		|	Install the current package.
Cmd-Shift-D		|	Open either a package listed in imports or a user-supplied package.
Ctrl-H			|	Show the Go HTML documentation for the currently-selected symbol.
Cmd-D			|	Go to the original definition of the currently selected symbol.
Ctrl-Shift-H	|	Reformat the document according to the Go style guidelines, automatically resolve imports.
Ctrl-Shift-L	|	Run 'go lint'
Ctrl-Shift-M	|	Run the default linters supplied by gometalinter
Ctrl-Shift-V	|	Run 'go vet'
Opt-ESC			|	Complete the symbol under the cursor.

## Snippets

### Simple Statements

Snippet		|	Content
------- 	|	-------
Cmd-i		|	'+iota+'
,			|	A pair ('first, second'), suitable for declaring result variables from a multi-return-value function or a map range loop.
<			|	Send/receive through a channel. Provides tab stops for the value and the channel name.
def			|	A default clause within a switch.
fmt			|	fmt.Println with tab stop for interface
fmt.		|	fmt.Printf with tab stops for string and interface
in			|	An empty interface type (i.e. matches anything).
imp			|	An import statement with optional alternative name.
imps		|	A multiple-import statement.
pkg			|	A package declaration including an optional comment block for packages other than 'main'.
ret			|	A return statement with optional return value.

### Initializers and Declarations

Snippet		|	Content
------- 	|	-------
:			|	A short-form variable initializer (i.e. 'name := value').
\[\]		|	A slice variable type; expands to '[]+type+', so is usable inside other snippets.
ch			|	A channel type.
con			|	A single constant declaration.
cons		|	A multiple constant declaration block.
fun			|	A function type definition statement.
inte		|	An interface definition with a single method.
mk			|	A make statement (used for creating & initializing channels, maps, etc.).
map			|	A map variable type; expands to 'map[+keytype+]+valuetype+'.
ew			|	A new statement (used to create & initialize structure types).
st			|	A struct definition with a single member.
type		|	A type declaration, with name and variable type as tab-stops.
types		|	A block with multiple type declarations.
var			|	Declare a variable with an optional initial value (long form, i.e. 'var x int = 10').
vars		|	A block of long-form variable declarations.

### Functions

Snippet		|	Content
------- 	|	-------
de			|	A deferred goroutine call (defines the function inline).
func		|	A plain (global) function declaration, with tab stops for name, parameters, and a single optional result.
funcv		|	A plain (global) function declaration, with tab stops for name, parameters, and multiple results.
go			|	An immediate goroutine call (defines the function inline).
init		|	A template for a module's +init()+ function, with a tab stop at its body.
main		|	A template for a +main()+ function with a tab stop at its body.
meth		|	Declares a function on a particular type, with additional tab stops for receiver name and type and a single optional result.
methv		|	Declares a function on a particular type, with additional tab stops for receiver name and type and multiple results.

### Control Statements

Snippet		|	Content
------- 	|	-------
case		|	A case clause, within a switch or select.
for			|	A for loop.
fori		|	A for loop with an index (similar to C for loops).
forr		|	A for loop iterating over a collection's full range.
if			|	An if statement, properly formatted (Go requires the use of {} on ifs, unlike C; this throws me sometimes).
sel			|	A select statement, for looping over channel conditions.
sw			|	A switch statement with an optional expression.

## Thanks

This repository is a fork from [Jim Dovey's bundle](https://github.com/AlanQuatermain/go-tmbundle) with additional improvements merged from around the community.
Changes from the original version (see git log for more details):

- Substantially improved syntax highlighting (thanks [nanoant](https://github.com/nanoant))
- Support for goimports and golint (thanks [fmccann](https://github.com/fmccann))
- Support for godef (thanks [taterbase](https://github.com/taterbase))
- Users can supply commands via ENV variables (TM\_GO\_DYNAMIC\_GOPATH, TM\_GO\_DYNAMIC\_PKG, TM\_GO\_DYNAMIC\_PKG\_PATH). The bundle will consult these commands if defined to dynamically change the gopath or package based on the current directory. (thanks [fmccann](https://github.com/fmccann))
- all non-run go commands operate on the current directory instead of per file if the package is not defined dynamically. (thanks [tg](https://github.com/tg)).
- run and build work on unsaved files (thanks [tg](https://github.com/tg))
- added print, println, printf, and fprintf snippets; improved struct snippet (thanks 
[jish](https://github.com/jish))
- HiDPI completion icons (thanks [nanoant](https://github.com/nanoant))
- Bug fixes and improvements (thanks [msoap](https://github.com/msoap))
- Improved, expanded documentation coverage (thanks [syscrusher](https://github.com/syscrusher))
- Completion support for GOPATH and current package (thanks [syscrusher](https://github.com/syscrusher))
- bugfixes (thanks everyone!)

[Jim Dovey](https://github.com/AlanQuatermain) deserves everyone's gratitude for his hard work on this bundle. The following are his original attributions:
>Much of the current infrastructure was created by [Martin Kühl](http://github.com/mkhl), who is a significantly more seasoned TextMate bundle developer than I, and to whom I am eternally grateful.

>Support for Go 1.0 was provided by [Jeremy Whitlock](http://github.com/whitlockjc) and [Michael Sheets](http://github.com/infininight), with additional code and fixes from [Sylvain Defresne](http://github.com/sdefresne), [liuyork](http://github.com/liuyork), and [Alexey Palazhchenko](http://github.com/AlekSi).

>Thanks be to lasersox and Infininight over at the [#textmate room on IRC](irc://irc.freenode.net/textmate) for all their help in cleaning up this here bundle, and for helping me to optimize my regex use in the language grammar.
Thanks to Martin Kühl for his extensive additions to this project's snippets and commands. Also Infininight's work on updating the bundle to use the TextMate's new Ruby interface and Jeremy & Sylvain's work on supporting Go 1.0 has been invaluable. Their assistance and stewardship while I've been deep in the world of Objective-C is very much appreciated.

Happy coding :)
