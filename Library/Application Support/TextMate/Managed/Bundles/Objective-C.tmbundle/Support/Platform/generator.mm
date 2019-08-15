#import <clang-c/Index.h>
#import <Foundation/Foundation.h>
#import <getopt.h>
#import <sysexits.h>
#import <stdio.h>
#import <string>
#import <regex>
#import <string.h>
#import <map>
#import <set>

static char const* const kAppVersion = "1.0";

#ifndef COMPILE_DATE
#define COMPILE_DATE "YYYY-MM-DD"
#endif

static void visit (CXTranslationUnit tu, std::function<void(std::string const&, CXCursorKind, CXPlatformAvailability const*, std::string const&, CXCursor)> callback)
{
	std::set<CXCursorKind> const desiredCursorKinds = { CXCursor_StructDecl, CXCursor_EnumDecl, CXCursor_TypedefDecl, CXCursor_FunctionDecl, CXCursor_ObjCProtocolDecl, CXCursor_ObjCInterfaceDecl, CXCursor_VarDecl, CXCursor_EnumConstantDecl };
	clang_visitChildrenWithBlock(clang_getTranslationUnitCursor(tu), ^(CXCursor cursor, CXCursor parent){
		CXCursorKind kind = clang_getCursorKind(cursor);
		if(desiredCursorKinds.find(kind) == desiredCursorKinds.end())
			return CXChildVisit_Recurse;

		CXString name = clang_getCursorSpelling(cursor);
		std::string const symbol = clang_getCString(name);
		clang_disposeString(name);
		if(symbol.empty() || symbol.front() == '_')
			return clang_getCursorKind(cursor) == CXCursor_EnumDecl ? CXChildVisit_Recurse : CXChildVisit_Continue;

		CXSourceRange range = clang_getCursorExtent(cursor);
		CXSourceLocation location = clang_getRangeStart(range);
		CXFile file;
		clang_getFileLocation(location, &file, nullptr, nullptr, nullptr);
		CXString filename = clang_getFileName(file);
		std::string const header = clang_getCString(filename) ?: "";
		clang_disposeString(filename);

		CXPlatformAvailability* available = nullptr;
		CXPlatformAvailability availability[4]; // macOS, iOS, watchOS, tvOS
		int n = clang_getCursorPlatformAvailability(cursor, nullptr, nullptr, nullptr, nullptr, &availability[0], sizeof(availability) / sizeof(availability[0]));
		for(int i = 0; i < n && !available; ++i)
		{
			if(strcmp("macos", clang_getCString(availability[i].Platform)) == 0)
				available = &availability[i];
		}

		callback(symbol, kind, available, header, cursor);

		return clang_getCursorKind(cursor) == CXCursor_EnumDecl ? CXChildVisit_Recurse : CXChildVisit_Continue;
	});
}

template <typename _InputIter>
std::string strings_to_regexp (_InputIter first, _InputIter last)
{
	struct node_t
	{
		void add_string (std::string::const_iterator first, std::string::const_iterator last)
		{
			if(first == last)
			{
				_terminate = true;
			}
			else
			{
				auto it = _nodes.find(*first);
				if(it == _nodes.end())
					it = _nodes.emplace(*first, node_t()).first;
				it->second.add_string(++first, last);
			}
		}

		void to_s (std::string& out) const
		{
			if(_nodes.empty())
				return;

			out += _terminate || _nodes.size() > 1 ? "(?:" : "";
			bool first = true;
			for(auto const& pair : _nodes)
			{
				if(!std::exchange(first, false))
					out += '|';
				out += pair.first;
				pair.second.to_s(out);
			}
			out += _terminate ? ")?" : (_nodes.size() > 1 ? ")" : "");
		}

	private:
		std::map<char, node_t> _nodes;
		bool _terminate = false;
	};

	node_t n;
	for(auto it = first; it != last; ++it)
		n.add_string(it->begin(), it->end());

	std::string res;
	n.to_s(res);
	return res;
}

static BOOL update_grammar (NSString* grammarPath, std::map<std::string, std::set<std::string>> const& functions, std::map<std::string, std::set<std::string>> const& protocols, std::map<std::string, std::set<std::string>> const& other, NSString* comment)
{
	NSMutableArray* patternRules  = [NSMutableArray new];
	NSMutableArray* functionRules = [NSMutableArray new];
	NSMutableArray* protocolRules = [NSMutableArray new];

	for(auto const& pair : functions)
	{
		NSString* match = [NSString stringWithFormat:@"\\b%@\\b", @(strings_to_regexp(pair.second.begin(), pair.second.end()).c_str())];
		[functionRules addObject:@{
			@"match" : [NSString stringWithFormat:@"(\\s*)(%@)", match],
			@"captures" : @{
				@"1" : @{ @"name" : @"punctuation.whitespace.support.function.leading" },
				@"2" : @{ @"name" : @(pair.first.c_str()) }
			}
		}];
	}

	for(auto const& pair : protocols)
	{
		NSString* match = [NSString stringWithFormat:@"\\b%@\\b", @(strings_to_regexp(pair.second.begin(), pair.second.end()).c_str())];
		[protocolRules addObject:@{ @"name" : @(pair.first.c_str()), @"match" : match }];
	}

	for(auto const& pair : other)
	{
		NSString* match = [NSString stringWithFormat:@"\\b%@\\b", @(strings_to_regexp(pair.second.begin(), pair.second.end()).c_str())];
		[patternRules addObject:@{ @"name" : @(pair.first.c_str()), @"match" : match }];
	}

	if(NSMutableDictionary* plist = [NSMutableDictionary dictionaryWithContentsOfFile:grammarPath])
	{
		plist[@"comment"] = comment ?: @"Generated";
		plist[@"patterns"] = patternRules;
		NSMutableDictionary* repos = [NSMutableDictionary dictionaryWithDictionary:@{
			@"functions" : @{ @"patterns" : functionRules },
		}];
		if(protocolRules.count)
			repos[@"protocols"] = @{ @"patterns" : protocolRules };
		plist[@"repository"] = repos;
		return [plist writeToFile:grammarPath atomically:YES];
	}
	return NO;
}

static void update_summary (char const* summaryPath, std::map<std::string, std::set<std::string>> const& functions, std::map<std::string, std::set<std::string>> const& protocols, std::map<std::string, std::set<std::string>> const& other, NSString* comment)
{
	std::map<std::string, std::map<std::string, std::set<std::string>> const&> const types =
	{
		{ "Functions", functions },
		{ "Protocols", protocols },
		{ "Other",     other     },
	};

	if(FILE* fp = fopen(summaryPath, "w"))
	{
		if(comment)
			fprintf(fp, "%s\n\n", [comment UTF8String]);

		for(auto const& type : types)
		{
			if(type.second.empty())
				continue;

			fprintf(fp, "# %s\n", type.first.c_str());
			for(auto const& pair : type.second)
			{
				fprintf(fp, "\n## %s\n\n", pair.first.c_str());
				for(auto const& function : pair.second)
					fprintf(fp, "- `%s`\n", function.c_str());
			}
			fprintf(fp, "\n");
		}
		fclose(fp);
	}
}

static void version (FILE* io)
{
	fprintf(io, "%1$s %2$s (" COMPILE_DATE ")\n", getprogname(), kAppVersion);
}

static void usage (FILE* io)
{
	version(io);
	fprintf(io,
		"Usage: %1$s [-o<file>t<file>s<file>s<suffix>chv] source\n"
		"\n"
		"Options:\n"
		" -o, --grammar      The tmGrammar file to generate/update.\n"
		" -t, --text         Write all symbols to this file in a readable format.\n"
		" -S, --sdk          Path to Xcode SDK.\n"
		" -s, --suffix       Suffix to append to scopes, e.g. `.objc`.\n"
		" -c, --cocoa        Generate grammar for Objective-C frameworks.\n"
		" -h, --help         Show this information.\n"
		" -v, --version      Print version information.\n"
		"\n", getprogname());
}

int main (int argc, char const* argv[])
{
	extern char* optarg;
	extern int optind;
	extern int optreset;

	static struct option const longopts[] = {
		{ "grammar",          required_argument,   0,      'o'   },
		{ "text",             required_argument,   0,      't'   },
		{ "sdk",              required_argument,   0,      'S'   },
		{ "suffix",           required_argument,   0,      's'   },
		{ "cocoa",            no_argument,         0,      'c'   },
		{ "help",             no_argument,         0,      'h'   },
		{ "version",          no_argument,         0,      'v'   },
		{ 0,                  0,                   0,      0     }
	};

	char const* grammarPath = nullptr;
	char const* textPath    = nullptr;
	char const* sdkPath     = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk";
	char const* suffix      = nullptr;
	bool isObjectiveC       = false;

	int ch;
	while((ch = getopt_long(argc, (char**)argv, "o:t:S:s:chv", longopts, NULL)) != -1)
	{
		switch(ch)
		{
			case 'o': grammarPath = optarg; break;
			case 't': textPath = optarg;    break;
			case 'S': sdkPath = optarg;     break;
			case 's': suffix = optarg;      break;
			case 'c': isObjectiveC = true;  break;
			case 'h': usage(stdout);        return EX_OK;
			case 'v': version(stdout);      return EX_OK;
			case '?': /* unknown option */  return EX_USAGE;
			case ':': /* missing option */  return EX_USAGE;
			default:  usage(stderr);        return EX_USAGE;
		}
	}

	argc -= optind;
	argv += optind;

	if(argc != 1)
	{
		fprintf(stderr, "%s: Wrong number of argumetns, expected 1 but got %d\n", getprogname(), argc);
		return EX_USAGE;
	}

	char const* sourcePath = argv[0];

	if(access(sourcePath, R_OK) != 0)
	{
		perror("error reading source");
		return EX_USAGE;
	}

	if(access(sdkPath, R_OK) != 0)
	{
		perror("error reading SDK");
		return EX_USAGE;
	}

	CXIndex index = clang_createIndex(0, 0);
	char const* args[] = { "-std=c++1y", "-stdlib=libc++", "--sysroot", sdkPath };
	CXTranslationUnit tu = clang_parseTranslationUnit(index, sourcePath, args, sizeof(args) / sizeof(args[0]), nullptr, 0, CXTranslationUnit_None);

	std::map<CXCursorKind, char const*> cursorTypes =
	{
		{ CXCursor_StructDecl,        "support.type"           },
		{ CXCursor_EnumDecl,          "support.type"           },
		{ CXCursor_TypedefDecl,       "support.type"           },
		{ CXCursor_FunctionDecl,      "support.function"       },
		{ CXCursor_VarDecl,           "support.variable"       },
		{ CXCursor_EnumConstantDecl,  "support.constant"       },
		{ CXCursor_ObjCProtocolDecl,  "support.other.protocol" },
		{ CXCursor_ObjCInterfaceDecl, "support.class"          },
	};

	struct { bool objC; std::string scope; std::regex pattern; } const headerTypes[] =
	{
		{ false, ".clib",         std::regex(".*/(alloca|ctype|_?locale|math|_?select|setjmp|signal|stdarg|stddef|stdint|stdio|stdlib|string|strings|time|types|unistd|sys/(fcntl|resource|select|types|wait)|_types/.*)\\.h$") },
		{ false, ".pthread",      std::regex(".*/_?pthread(/.*|\\.h)")           },
		{ false, ".os",           std::regex(".*/(OSByteOrder|gethostuuid)\\.h") },
		{ false, ".dispatch",     std::regex(".*/dispatch/.*")                   },
		{ false, ".quartz",       std::regex(".*/CoreGraphics\\.framework/.*")   },
		{ false, ".mac-classic",  std::regex(".*/MacTypes\\.h")                  },
		{ false, ".cf",           std::regex(".*/CoreFoundation\\.framework/.*") },
		{ true,  ".run-time",     std::regex(".*?/objc/(?:objc|runtime|NSObjCRuntime).h") },
		{ true,  ".cocoa",        std::regex(".*?/(?:AddressBook|AppKit|ExceptionHandling|Foundation|WebKit)\\.framework/(?!.*\\.framework/).*") },
	};

	std::map<std::string, std::set<std::string>> functions;
	std::map<std::string, std::set<std::string>> protocols;
	std::map<std::string, std::set<std::string>> other;

	if(isObjectiveC)
	{
		other = {
			{ "storage.type.objc",       { "instancetype" } },
			{ "storage.type.cocoa.objc", { "IBOutlet", "IBAction", "IBInspectable", "IB_DESIGNABLE" } } // NSNibDeclarations.h
		};
	}

	visit(tu, [&](std::string const& symbol, CXCursorKind kind, CXPlatformAvailability const* available, std::string const& header, CXCursor cursor){
		for(auto const& match : headerTypes)
		{
			if(isObjectiveC != match.objC || !std::regex_match(header, match.pattern))
				continue;

			std::string scope = cursorTypes[kind];
			scope += match.scope;

			if(available && available->Deprecated.Major == 10)
				scope = "invalid.deprecated." + std::to_string(available->Deprecated.Major) + "." + std::to_string(available->Deprecated.Minor) + "." + scope;
			else if(available && available->Introduced.Major == 10 && available->Introduced.Minor > 7)
				scope += "." + std::to_string(available->Introduced.Major) + "." + std::to_string(available->Introduced.Minor);

			if(suffix)
				scope += suffix;

			if(kind == CXCursor_FunctionDecl)
				functions[scope].insert(symbol);
			else if(kind == CXCursor_ObjCProtocolDecl)
				protocols[scope].insert(symbol);
			else
				other[scope].insert(symbol);

			break;
		}
	});

	NSString* comment = [NSString stringWithFormat:@"This file was generated with clang-C using %@", [@(sdkPath) lastPathComponent]];
	if(grammarPath && !update_grammar(@(grammarPath), functions, protocols, other, comment))
	{
		fprintf(stderr, "%s: error updating %s\n", getprogname(), grammarPath);
		return EX_IOERR;
	}

	if(textPath)
		update_summary(textPath, functions, protocols, other, comment);

	return EX_OK;
}
