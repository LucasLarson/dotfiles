#!/usr/bin/env sh
Describe "Sample specfile"
  Describe "hello()"
    hello() {
      echo # "hello $1"
    }

    It "puts greeting, but not implemented"
      Pending "You should implement hello function"
      When call hello world
      The output should eq "hello world"
    End
  End
End
