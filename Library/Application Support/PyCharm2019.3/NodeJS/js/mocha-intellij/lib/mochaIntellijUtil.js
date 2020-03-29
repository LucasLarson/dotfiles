var fs = require('fs')
  , path = require('path')
  , processStdoutWrite = process.stdout.write.bind(process.stdout)
  , processStderrWrite = process.stderr.write.bind(process.stderr)
  , MOCHA = 'mocha';

var doEscapeCharCode = (function () {
  var obj = {};

  function addMapping(fromChar, toChar) {
    if (fromChar.length !== 1 || toChar.length !== 1) {
      throw Error('String length should be 1');
    }
    var fromCharCode = fromChar.charCodeAt(0);
    if (typeof obj[fromCharCode] === 'undefined') {
      obj[fromCharCode] = toChar;
    }
    else {
      throw Error('Bad mapping');
    }
  }

  addMapping('\n', 'n');
  addMapping('\r', 'r');
  addMapping('\u0085', 'x');
  addMapping('\u2028', 'l');
  addMapping('\u2029', 'p');
  addMapping('|', '|');
  addMapping('\'', '\'');
  addMapping('[', '[');
  addMapping(']', ']');

  return function (charCode) {
    return obj[charCode];
  };
}());

function isAttributeValueEscapingNeeded(str) {
  var len = str.length;
  for (var i = 0; i < len; i++) {
    if (doEscapeCharCode(str.charCodeAt(i))) {
      return true;
    }
  }
  return false;
}

function escapeAttributeValue(str) {
  if (!isAttributeValueEscapingNeeded(str)) {
    return str;
  }
  var res = ''
    , len = str.length;
  for (var i = 0; i < len; i++) {
    var escaped = doEscapeCharCode(str.charCodeAt(i));
    if (escaped) {
      res += '|';
      res += escaped;
    }
    else {
      res += str.charAt(i);
    }
  }
  return res;
}

/**
 * @param {Array.<string>} list
 * @param {number} fromInclusive
 * @param {number} toExclusive
 * @param {string} delimiterChar one character string
 * @returns {string}
 */
function joinList(list, fromInclusive, toExclusive, delimiterChar) {
  if (list.length === 0) {
    return '';
  }
  if (delimiterChar.length !== 1) {
    throw Error('Delimiter is expected to be a character, but "' + delimiterChar + '" received');
  }
  var addDelimiter = false
    , escapeChar = '\\'
    , escapeCharCode = escapeChar.charCodeAt(0)
    , delimiterCharCode = delimiterChar.charCodeAt(0)
    , result = ''
    , item
    , itemLength
    , ch
    , chCode;
  for (var itemId = fromInclusive; itemId < toExclusive; itemId++) {
    if (addDelimiter) {
      result += delimiterChar;
    }
    addDelimiter = true;
    item = list[itemId];
    itemLength = item.length;
    for (var i = 0; i < itemLength; i++) {
      ch = item.charAt(i);
      chCode = item.charCodeAt(i);
      if (chCode === delimiterCharCode || chCode === escapeCharCode) {
        result += escapeChar;
      }
      result += ch;
    }
  }
  return result;
}

var toString = {}.toString;

/**
 * @param {*} value
 * @return {boolean}
 */
function isString(value) {
  return isStringPrimitive(value) || toString.call(value) === '[object String]';
}

/**
 * @param {*} value
 * @return {boolean}
 */
function isStringPrimitive(value) {
  return typeof value === 'string';
}

function safeFn(fn) {
  return function () {
    try {
      return fn.apply(this, arguments);
    } catch (ex) {
      const message = ex.message || '';
      const stack = ex.stack || '';
      warn(stack.indexOf(message) >= 0 ? stack : message + '\n' + stack);
    }
  };
}

function warn(message) {
  const str = 'warn  mocha-intellij: ' + message + '\n';
  try {
    processStderrWrite(str);
  }
  catch (ex) {
    try {
      processStdoutWrite(str);
    }
    catch (ex) {
      // do nothing
    }
  }
}

function writeToStdout(str) {
  processStdoutWrite(str);
}

function writeToStderr(str) {
  processStderrWrite(str);
}

/**
 * Requires inner mocha module.
 *
 * @param {string} pathRelativeToMochaPackageDir  Path to inner mocha module relative to mocha package root directory,
 *                                e.g. <code>"./lib/utils"</code> or <code>"./lib/reporters/base.js"</code>
 * @returns {*} loaded module
 */
function requireMochaModule(pathRelativeToMochaPackageDir) {
  var mainFile = process.argv[1];
  var packageRootDir = findPackageRootDir(mainFile);
  if (packageRootDir == null) {
    throw Error('mocha-intellij: cannot require "%s": unable to find package root for "%s"',
                pathRelativeToMochaPackageDir, mainFile);
  }
  if (path.basename(packageRootDir) === MOCHA) {
    return require(path.join(packageRootDir, pathRelativeToMochaPackageDir));
  }
  try {
    return require(path.join(packageRootDir, pathRelativeToMochaPackageDir));
  }
  catch (e) {
    var mochaPackageDir = findMochaDependency(packageRootDir);
    if (mochaPackageDir == null) {
      throw Error('mocha-intellij: cannot require "%s": not found mocha dependency for "%s"',
                  pathRelativeToMochaPackageDir, packageRootDir);
    }
    return require(path.join(mochaPackageDir, pathRelativeToMochaPackageDir));
  }
}

function findMochaDependency(packageDir) {
  var mochaPackageDir = path.join(packageDir, 'node_modules', MOCHA);
  if (directoryExistsSync(mochaPackageDir)) {
    return mochaPackageDir;
  }
  var dir = packageDir;
  while (dir != null) {
    mochaPackageDir = path.join(dir, MOCHA);
    if (directoryExistsSync(mochaPackageDir)) {
      return mochaPackageDir;
    }
    var parent = path.resolve(dir, '..');
    if (dir === parent) {
      return null;
    }
    dir = parent;
  }
  return null;
}

function directoryExistsSync(dir) {
  try {
    var stat = fs.statSync(dir);
    return stat != null && stat.isDirectory();
  }
  catch (e) {
    return false;
  }
}
/**
 * Find package's root directory traversing the file system up.
 *
 * @param   {string} startDir Starting directory or file located in the package
 * @returns {?string}         The package's root directory, or null if not found
 */
function findPackageRootDir(startDir) {
  var dir = path.resolve(startDir);
  while (dir != null) {
    if (path.basename(dir) === 'node_modules') {
      return null;
    }
    var packageJson = path.join(dir, 'package.json');
    if (fs.existsSync(packageJson)) {
      return dir;
    }
    var parent = path.resolve(dir, '..');
    if (dir === parent) {
      return null;
    }
    dir = parent;
  }
  return null;
}

/**
 * It's suggested that every Mocha reporter should inherit from Mocha Base reporter.
 * See https://github.com/visionmedia/mocha/blob/master/lib/reporters/base.js
 *
 * At least Base reporter is needed to add and update IntellijReporter.stats object that is used by growl reporter.
 * @returns {?function}  The base reporter, or undefined if not found
 */
function requireBaseReporter() {
  const baseReporterPath = './lib/reporters/base.js';
  try {
    const Base = requireMochaModule(baseReporterPath);
    if (typeof Base === 'function') {
      return Base;
    }
    console.error('warn  mocha-intellij: base reporter (' + baseReporterPath + ') is not a function');
  } catch (e) {
    console.error('warn  mocha-intellij: cannot load base reporter from ' + baseReporterPath, e);
  }
}

exports.escapeAttributeValue = escapeAttributeValue;
exports.joinList = joinList;
exports.isString = isString;
exports.isStringPrimitive = isStringPrimitive;
exports.safeFn = safeFn;
exports.writeToStdout = writeToStdout;
exports.writeToStderr = writeToStderr;
exports.requireMochaModule = requireMochaModule;
exports.requireBaseReporter = requireBaseReporter;
