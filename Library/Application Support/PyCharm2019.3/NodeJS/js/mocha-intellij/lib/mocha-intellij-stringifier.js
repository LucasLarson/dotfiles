var util = require('./mochaIntellijUtil');

/**
 * @param {*} value
 * @return {string}
 */
function stringify(value) {
  var str;
  try {
    var mochaUtils = util.requireMochaModule('./lib/utils');
    if (mochaUtils != null && typeof mochaUtils.stringify === 'function') {
      str = mochaUtils.stringify(value);
    }
  }
  catch (e) {
    // do nothing
  }
  if (util.isString(str)) {
    return str;
  }
  str = failoverStringify(value);
  if (util.isString(str)) {
    return str;
  }
  return 'Oops, something went wrong: IDE failed to stringify ' + typeof value;
}

/**
 * @param {*} value
 * @return {string}
 */
function failoverStringify(value) {
  var normalizedValue = deepCopyAndNormalize(value);
  if (normalizedValue instanceof RegExp) {
    return normalizedValue.toString();
  }
  if (normalizedValue === undefined) {
    return 'undefined';
  }
  return JSON.stringify(normalizedValue, null, 2);
}

function isObject(val) {
  return val === Object(val);
}

function deepCopyAndNormalize(value) {
  var cache = [];
  return (function doCopy(value) {
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
        return doCopy(element);
      });
    }

    if (isObject(value)) {
      var keys = Object.keys(value);
      keys.sort();
      var ret = {};
      keys.forEach(function (key) {
        ret[key] = doCopy(value[key]);
      });
      return ret;
    }

    return value;
  })(value);
}

exports.stringify = stringify;
