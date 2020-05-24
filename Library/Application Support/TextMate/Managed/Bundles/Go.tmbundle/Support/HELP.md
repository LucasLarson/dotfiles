# Setup
This bundle relies on amazing open source tooling for some functionality. These utilities can be installed with the following commands:

	go get -u github.com/nsf/gocode					# completion
	go get -u github.com/zmb3/gogetdoc				# documentation
	go get -u golang.org/x/tools/cmd/goimports		# import resolution/rewriting
	go get -u github.com/golang/lint/golint			# linting
	go get -u github.com/rogpeppe/godef				# goto definition
	go get -u github.com/alecthomas/gometalinter	# metalinting

You may override the following TextMate variables in the preferences (adjust paths to your own configuration). TextMate does not inherit the users environment unless it is launched from the command line. It may be necessary to set TM_GOPATH and GOROOT.

	TM_GO=/usr/local/bin/go
	TM_GOPATH=/Users/myuser/go
	TM_GOCODE=/Users/myuser/bin/gocode
	TM_GOGETDOC=/Users/myuser/bin/gogetdoc
	TM_GOFMT=/Users/myuser/bin/gofmt # or /Users/myuser/bin/goimports
	TM_GOIMPORTS=/Users/myuser/bin/goimports
	TM_GOLINT=/Users/myuser/bin/golint
	TM_GODEF=/Users/myuser/bin/godef
	TM_GOMETALINTER=/Users/myuser/bin/gometalinter

# Further Help
The full documentation is available on [GitHub](https://github.com/syscrusher/golang.tmbundle/blob/master/README.md), including commands and snippets.