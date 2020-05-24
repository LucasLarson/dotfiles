#!/usr/bin/env bash
if [ -z "${GOPATH}" ]; then
	export GOPATH="${TM_GOPATH}"
fi
