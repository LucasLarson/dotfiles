The code in this directory is used to generate `Platform.tmLanguage`.

It requires `libclang` and the clang C includes. This can be obtained by installing `llvm`:

	brew install llvm

There is a `Makefile` which builds the `generator` executable and will also update `Platform.tmLanguage` in the C and Objective-C bundles.

Before running `make` you should clone the respective bundles:

```shell
cd ~/Library/Application\ Support/TextMate/Bundles
git clone "git@github.com:textmate/c.tmbundle"
git clone "git@github.com:textmate/objective-c.tmbundle"
```

## How it Works

We parse either `includes.c` or `includes.mm` (based on the `--cocoa` flag) using clang’s C interface.

Once the file has been parsed we traverse the parse tree and harvest enumerations, functions, variable declarations, etc.

For each symbol we check the path of the file path (from where the symbol came) against a list of regular expressions, this determines how to name the scope, and also means that if the file is not matched by any of our regular expressions, the symbol is left out.

Here is an excerpt from the table:

```c
struct { bool objC; std::string scope; std::regex pattern; } const headerTypes[] =
{
	{ false, ".pthread",     std::regex(".*/_?pthread(/.*|\\.h)")                    },
	{ false, ".dispatch",    std::regex(".*/dispatch/.*")                            },
	{ false, ".quartz",      std::regex(".*/CoreGraphics\\.framework/.*")            },
	{ false, ".mac-classic", std::regex(".*/MacTypes\\.h")                           },
	{ false, ".cf",          std::regex(".*/CoreFoundation\\.framework/.*")          },
	{ true,  ".run-time",    std::regex(".*?/objc/(?:objc|runtime|NSObjCRuntime).h") },
	⋮
};
```

If you want to add more symbols to the generated `Platform.tmLanguage` file then you need to edit this table and you may also need to add new include statements to one or both of the `includes.{c,mm}` files.
