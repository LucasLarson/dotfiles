/**
 * Node.js application file that sends tests state updates to IntelliJ.
 */


function println(stream, message) {
    var done = stream.write(message + '\n');

    // this is the first time stdout got backed up
    if (!done && !stream.pendingWrite) {
        stream.pendingWrite = true;

        // magic sauce: keep node alive until stdout has flushed
        stream.once('drain', function () {
            stream.draining = false;
        });
    }
}

function printlnToStdErr(message) {
    println(process.stderr, message);
}

function printlnToStdOut(message) {
    println(process.stdout, message);
}

function extend(target, patch) {
    if (arguments.length > 2) {
        for (var a = 1; a < arguments.length; a++) {
            extend(target, arguments[a]);
        }
    } else {
        for (var i in patch) {
            if (patch.hasOwnProperty(i)) {
                target[i] = patch[i];
            }
        }
    }
    return target;
}

var tcManager = (function() {

    var escaper = (function() {

        function escapseChar(ch) {
            switch (ch) {
                case '\n': return 'n';
                case '\r': return 'r';
                case '\u0085': return 'x'; // next-line character
                case '\u2028': return 'l'; // line-separator character
                case '\u2029': return 'p'; // paragraph-separator character
                case '|': return '|';
                case '\'': return '\'';
                case '[': return '[';
                case ']': return ']';
                default: return 0;
            }
        }

        return {
            escapeStr: function(str) {
                var strLength = str.length;
                var out = "";
                var ch, escapedChar;
                for (var i = 0; i < strLength; i++) {
                    ch = str.charAt(i);
                    escapedChar = escapseChar(ch);
                    if (escapedChar !== 0) {
                        out += '|';
                        out += escapedChar;
                    } else {
                        out += ch;
                    }
                }
                return out;
            }
        }
    }());

    function createTCMessage(messageName, attrs) {
        var out = "##teamcity[" + messageName + " ";
        for (var key in attrs) {
            if (attrs.hasOwnProperty(key)) {
                var value = attrs[key];
                var escapedKey = escaper.escapeStr(key);
                var escapedValue = escaper.escapeStr(value);
                out += " " + escapedKey + "='" + escapedValue + "'";
            }
        }
        out += "]";
        return out;
    }

    /**
     * Returns a string that is a result of join of all strings from a testNameList array with a dot character.
     * @param testNameList {Array}
     */
    function testNameList2String(testNameList) {
        return testNameList.join('.');
    }

    function createNameObj(testNameList) {
        return {name: testNameList2String(testNameList)};
    }

    function createTestLocationData(relativeModuleName, testNameList) {
        function encode(str) {
            return str.replace(/:/g, '::').replace(/,/g, ':,');
        }
        var a = [relativeModuleName].concat(testNameList ? testNameList : []);
        var path = a.map(encode).join(',');
        return "nodeunit://" + path;
    }

    return {
        /**
         * @param moduleName {String}
         * @param relativeModulePath {String}
         * @param testSuiteNameList {Array?}
         */
        createTestSuiteStartedMessage: function(moduleName, relativeModulePath, testSuiteNameList) {
            var testNodeNameList = testSuiteNameList;
            if (!testNodeNameList) {
                testNodeNameList = [moduleName];
            }
            var attrs = createNameObj(testNodeNameList);
            attrs.locationHint = createTestLocationData(relativeModulePath, testSuiteNameList);
            return createTCMessage("testSuiteStarted", attrs);
        },
        /**
         * @param testSuiteNameList {Array}
         */
        createTestSuiteFinishedMessage: function(testSuiteNameList) {
            return createTCMessage("testSuiteFinished", createNameObj(testSuiteNameList));
        },
        /**
         * @param relativeModulePath {String}
         * @param testNameList {Array}
         */
        createTestStartedMessage: function(relativeModulePath, testNameList) {
            var attrs = createNameObj(testNameList);
            attrs.locationHint = createTestLocationData(relativeModulePath, testNameList);
            return createTCMessage("testStarted", attrs);
        },
        createTestFinishedMessage: function(testNameList, durationMillis) {
            var attrs = createNameObj(testNameList);
            if (typeof durationMillis === 'number') {
                attrs.duration = String(durationMillis);
            }
            return createTCMessage("testFinished", attrs);
        },
        createTestFailedMessage: function(testNameList, extraProperties) {
            var attributes = createNameObj(testNameList);
            attributes = extend(attributes, extraProperties);
            return createTCMessage("testFailed", attributes);
        }
    };
}());

function run(files) {

    function getSuiteNameListByTest(testNameList) {
        return testNameList.slice(0, testNameList.length - 1);
    }

    /**
     * Finishes test suites and starts new ones.
     *
     * @param nextStartedTestSuiteNameList {Array}
     */
    function handleTestSuiteStart(nextStartedTestSuiteNameList) {
        var lastStartedTestSuiteNameList = testRunState.currentTestSuiteNameList;
        var minLength = Math.min(lastStartedTestSuiteNameList.length, nextStartedTestSuiteNameList.length);
        var i;
        var message;
        var nameList;
        for (i = 0; i < minLength; i++) {
            if (lastStartedTestSuiteNameList[i] !== nextStartedTestSuiteNameList[i]) {
                break;
            }
        }

        nameList = lastStartedTestSuiteNameList.slice();
        while (nameList.length > i) {
            message = tcManager.createTestSuiteFinishedMessage(nameList);
            printlnToStdOut(message);
            nameList.pop();
        }
        while (nameList.length < nextStartedTestSuiteNameList.length) {
            nameList.push(nextStartedTestSuiteNameList[nameList.length]);
            message = tcManager.createTestSuiteStartedMessage(
                testRunState.moduleName,
                testRunState.relativeModulePath,
                nameList
            );
            printlnToStdOut(message);
        }
        testRunState.currentTestSuiteNameList = nextStartedTestSuiteNameList;
    }

    var testRunState = {
        moduleName: undefined,
        currentTestSuiteNameList: []
    };

    var opts = {
        moduleStart: function (absoluteFileName) {
            testRunState.moduleName = path.basename(absoluteFileName);
            testRunState.relativeModulePath = path.relative(process.cwd(), absoluteFileName);
            var message = tcManager.createTestSuiteStartedMessage(
                testRunState.moduleName,
                testRunState.relativeModulePath,
                null
            );
            printlnToStdOut(message);
        },
        moduleDone: function (absoluteFileName, assertions) {
            var moduleName = path.basename(absoluteFileName);
            handleTestSuiteStart([]);
            testRunState.moduleName = undefined;
            testRunState.relativeModulePath = undefined;
            var message = tcManager.createTestSuiteFinishedMessage([moduleName]);
            printlnToStdOut(message);
        },
        testStart: function (testNameList) {
            handleTestSuiteStart(getSuiteNameListByTest(testNameList));
            var message = tcManager.createTestStartedMessage(testRunState.relativeModulePath, testNameList);
            printlnToStdOut(message);
        },
        testDone: function (testNameList, assertions) {

            function createTestFailedMessage() {
                var failAttrs = {};
                if (!assertions.failures()) {
                    return null;
                }
                assertions.forEach(function (a) {
                    if (a.failed()) {
                        a = nodeunit_utils.betterErrors(a);
                        failAttrs.message = "";
                        var er = a.error;
                        if (er instanceof AssertionError && a.message) {
                            failAttrs.message = a.message;
                        }
                        if (typeof er.actual !== "undefined" && typeof er.expected != "undefined") {
                            var actualStr = stringify(er.actual)
                              , expectedStr = stringify(er.expected);
                            if (actualStr != null && expectedStr != null) {
                              failAttrs.actual = actualStr;
                              failAttrs.expected = expectedStr;
                            }
                        }
                        if (typeof er.expectedFilePath === 'string') {
                            failAttrs.expectedFile = er.expectedFilePath;
                        }
                        if (typeof er.actualFilePath === 'string') {
                            failAttrs.actualFile = er.actualFilePath;
                        }
                        failAttrs.details = er.stack.toString();
                    }
                });
                return tcManager.createTestFailedMessage(testNameList, failAttrs);
            }

            var testFailedMessage = createTestFailedMessage();
            if (!!testFailedMessage) {
                printlnToStdOut(testFailedMessage);
            }
            var testFinishedMessage = tcManager.createTestFinishedMessage(testNameList, assertions.duration);
            printlnToStdOut(testFinishedMessage);
        },
        log: function() {

        },
        done: function (assertions) {
        }
    };

    function collectAbsoluteTestFilePaths(relativeFilePaths) {

        function collectDirs(absoluteDirPath, dirList) {
            dirList.push(absoluteDirPath);
            fs.readdirSync(absoluteDirPath).forEach(function (entityName) {
                var absoluteChildPath = path.join(absoluteDirPath, entityName);
                if (fs.statSync(absoluteChildPath).isDirectory()) {
                  collectDirs(absoluteChildPath, dirList);
                }
            });
        }

        var files = [];

        relativeFilePaths.forEach(function (relativeFilePath) {
            var absoluteFilePath = path.join(process.cwd(), relativeFilePath);
            if (fs.statSync(absoluteFilePath).isDirectory()) {
                var absoluteDirPaths = [];
                collectDirs(absoluteFilePath, absoluteDirPaths);
                Array.prototype.push.apply(files, absoluteDirPaths);
            } else {
                files.push(absoluteFilePath);
            }
        });
        return files;
    }

    function testIt(absolutePaths) {
        function resolveAsyncModule() {
            return require(path.join(nodeunitModulePath, 'deps/async'));
        }
        var all_assertions = [];
        var types = nodeunit.types;
        var async = resolveAsyncModule();
        var options = types.options(opts);
        var start = new Date().getTime();

        if (!absolutePaths.length) {
            options.done(types.assertionList(all_assertions));
            return;
        }

        nodeunit_utils.modulePaths(absolutePaths, function (err, files) {
            if (err) throw err;
            async.concatSeries(
                files,
                function (file, cb) {
                    nodeunit.runModule(file, require(file), options, cb);
                },
                function (err, all_assertions) {
                    var end = new Date().getTime();
                    nodeunit.done();
                    options.done(types.assertionList(all_assertions, end - start));
                }
            );
        });
    }

    if (files && files.length) {
        var absolutePaths = collectAbsoluteTestFilePaths(files);
        testIt(absolutePaths);
    }
}

var path = require('path'),
    fs = require('fs'),
    nodeunit,
    nodeunit_utils,
    AssertionError,
    appArgs = (process.ARGV || process.argv).slice(2),
    nodeunitModulePath = appArgs[0];

try {
    nodeunit = require(nodeunitModulePath);
}
catch (e) {
    printlnToStdErr("Cannot find nodeunit module in '" + nodeunitModulePath + "' directory.");
    printlnToStdErr("There are two options for installing nodeunit:");
    printlnToStdErr("1. Clone / download nodeunit from https://github.com/caolan/nodeunit, then:");
    printlnToStdErr("   make && sudo make install");
    printlnToStdErr("2. Install via npm:");
    printlnToStdErr("   npm install nodeunit");
    printlnToStdErr("");

    printlnToStdErr("Make sure 'Nodeunit module' field in Nodeunit RunConfiguration points to a valid nodeunit module.");
}

nodeunit_utils = nodeunit.utils;
AssertionError = nodeunit.assert.AssertionError;

run(appArgs.slice(1));

function stringify(value) {
  if (value === null) {
    return 'null';
  }
  if (typeof value === 'undefined') {
    return 'undefined';
  }
  if (isString(value)) {
    return '"' + value.toString() + '"';
  }
  var normalizedValue = deepCopyAndNormalize(value);
  if (normalizedValue instanceof RegExp) {
    return normalizedValue.toString();
  }
  if (normalizedValue === undefined) {
    return 'undefined';
  }
  return JSON.stringify(normalizedValue, null, 2);
}

var toString = {}.toString;

function isString(value) {
  return typeof value === 'string' || toString.call(value) === '[object String]';
}

function isObject(val) {
  return val === Object(val);
}

function deepCopyAndNormalize(value) {
  var cache = [];
  return (function stringify(value) {
    if (value == null) {
      return value;
    }
    if (typeof value === 'number' || typeof value === 'boolean' || typeof value === 'string') {
      return value;
    }
    if (value instanceof RegExp) {
      return value;
    }

    if (cache.indexOf(value) !== -1) {
      return '[Circular reference found] Truncated by IDE';
    }
    cache.push(value);

    if (Array.isArray(value)) {
      return value.map(function (element) {
        return stringify(element);
      });
    }

    if (isObject(value)) {
      var keys = Object.keys(value);
      keys.sort();
      var ret = {};
      keys.forEach(function (key) {
        ret[key] = stringify(value[key]);
      });
      return ret;
    }

    return value;
  })(value);
}
