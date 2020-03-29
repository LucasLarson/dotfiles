var Tree = require('./mochaIntellijTree')
  , util = require('./mochaIntellijUtil')
  , treeUtil = require('./mochaTreeUtil')
  , stringifier = require('./mocha-intellij-stringifier')
  , SingleElementQueue = require('./single-element-queue');

/**
 * @param {Tree} tree
 * @param test mocha test object
 * @returns {TestSuiteNode}
 */
function findOrCreateAndRegisterSuiteNode(tree, test) {
  var suites = getSuitesFromRootDownTo(test.parent);
  var parentNode = tree.root, suiteId;
  for (suiteId = 0; suiteId < suites.length; suiteId++) {
    var suite = suites[suiteId];
    var suiteName = suite.title;
    var childNode = treeUtil.getNodeForSuite(suite);
    if (!childNode) {
      var locationPath = getLocationPath(parentNode, suiteName);
      childNode = parentNode.addTestSuiteChild(suiteName, 'suite', locationPath, test.file);
      childNode.register();
      treeUtil.setNodeForSuite(suite, childNode);
    }
    parentNode = childNode;
  }
  return parentNode;
}

function getSuitesFromRootDownTo(suite) {
  var suites = [];
  var s = suite;
  while (s != null && !s.root) {
    suites.push(s);
    s = s.parent;
  }
  suites.reverse();
  return suites;
}

/**
 * @param {TestSuiteNode} parent
 * @param {string} childName
 * @returns {string}
 */
function getLocationPath(parent, childName) {
  var names = []
    , node = parent
    , root = node.tree.root;
  while (node !== root) {
    names.push(node.name);
    node = node.parent;
  }
  names.reverse();
  names.push(childName);
  return util.joinList(names, 0, names.length, '.');
}

function extractErrInfo(err) {
  var message = err.message || ''
    , stack = err.stack;
  if (!util.isString(stack) || stack.trim().length == 0) {
    return {
      message: message
    }
  }
  var index = stack.indexOf(message);
  if (index >= 0) {
    message = stack.slice(0, index + message.length);
    stack = stack.slice(message.length);
    var nl = '\n';
    if (stack.indexOf(nl) === 0) {
      stack = stack.substring(nl.length);
    }
  }
  return {
    message : message,
    stack : stack
  }
}

/**
 * @param {Tree} tree
 * @param test mocha test object
 * @returns {TestNode}
 */
function registerTestNode(tree, test) {
  var testNode = treeUtil.getNodeForTest(test);
  if (testNode != null) {
    throw Error("Test node has already been associated!");
  }
  var suiteNode = findOrCreateAndRegisterSuiteNode(tree, test);
  var locationPath = getLocationPath(suiteNode, test.title);
  testNode = suiteNode.addTestChild(test.title, 'test', locationPath, test.file);
  testNode.register();
  treeUtil.setNodeForTest(test, testNode);
  return testNode;
}

/**
 * @param {Tree} tree
 * @param test mocha test object
 * @returns {TestNode}
 */
function startTest(tree, test) {
  var testNode = treeUtil.getNodeForTest(test);
  if (testNode == null) {
    testNode = registerTestNode(tree, test);
  }
  testNode.start();
  return testNode;
}

/**
 *
 * @param {TestNode} testNode
 * @param {*} err
 */
function addStdErr(testNode, err) {
  if (err != null) {
    if (util.isString(err)) {
      testNode.addStdErr(err);
    }
    else {
      var errInfo = extractErrInfo(err);
      if (errInfo != null) {
        var out = errInfo.message || errInfo.stack;
        if (errInfo.message && errInfo.stack) {
          out = errInfo.message + '\n' + errInfo.stack;
        }
        testNode.addStdErr(out);
      }
    }
  }
}

/**
 * @param {Tree} tree
 * @param {Object} test mocha test object
 * @param {Object} err mocha error object
 * @param {SingleElementQueue} [finishingQueue]
 */
function finishTestNode(tree, test, err, finishingQueue) {
  var testNode = treeUtil.getNodeForTest(test);
  if (finishingQueue != null) {
    const passed = testNode != null && testNode === finishingQueue.current && testNode.outcome === Tree.TestOutcome.SUCCESS;
    if (passed && err != null) {
      // do not deliver passed event if this test is failed now
      finishingQueue.clear();
    }
    else {
      finishingQueue.processAll();
    }
  }

  if (testNode != null && testNode.isFinished()) {
    /* See https://youtrack.jetbrains.com/issue/WEB-10637
       A test can be reported as failed and passed at the same test run if a error is raised using
         this.test.error(new Error(...));
       At least all errors should be presented to a user. */
    addStdErr(testNode, err);
    return;
  }
  testNode = startTest(tree, test);
  if (err) {
    var expected = getOwnProperty(err, 'expected');
    var actual = getOwnProperty(err, 'actual');
    var expectedStr = null, actualStr = null;
    if (err.showDiff !== false && expected !== actual && expected !== undefined) {
      if (util.isStringPrimitive(expected) && util.isStringPrimitive(actual)) {
        // in compliance with mocha's own behavior
        //   https://github.com/mochajs/mocha/blob/v3.0.2/lib/reporters/base.js#L204
        //   https://github.com/mochajs/mocha/commit/d55221bc967f62d1d8dd4cd8ce4c550c15eba57f
        expectedStr = expected.toString();
        actualStr = actual.toString();
      }
      else {
        expectedStr = stringifier.stringify(expected);
        actualStr = stringifier.stringify(actual);
      }
    }
    var errInfo = extractErrInfo(err);
    testNode.setOutcome(Tree.TestOutcome.FAILED, test.duration, errInfo.message, errInfo.stack,
                        expectedStr, actualStr,
                        getOwnProperty(err, 'expectedFilePath'), getOwnProperty(err, 'actualFilePath'));
  }
  else {
    var status = test.pending ? Tree.TestOutcome.SKIPPED : Tree.TestOutcome.SUCCESS;
    testNode.setOutcome(status, test.duration, null, null, null, null, null, null);
  }
  if (finishingQueue != null) {
    finishingQueue.add(testNode);
  }
  else {
    testNode.finish(false);
  }
}

/**
 * @param {object} obj javascript object
 * @param {string} key object own key to retrieve
 * @return {*}
 */
function getOwnProperty(obj, key) {
  var value;
  if (Object.prototype.hasOwnProperty.call(obj, key)) {
    value = obj[key];
  }
  return value;
}

/**
 * @param {Object} test mocha test object
 * @return {boolean}
 */
function isHook(test) {
  return test.type === 'hook';
}

/**
 * @param {Object} test mocha test object
 * @return {boolean}
 */
function isBeforeAllHook(test) {
  return isHook(test) && test.title && test.title.indexOf('"before all" hook') === 0;
}

/**
 * @param {Object} test mocha test object
 * @return {boolean}
 */
function isBeforeEachHook(test) {
  return isHook(test) && test.title && test.title.indexOf('"before each" hook') === 0;
}

/**
 * @param {Tree} tree
 * @param {Object} suite mocha suite
 * @param {string} cause
 */
function markChildrenFailed(tree, suite, cause) {
  suite.tests.forEach(function (test) {
    var testNode = treeUtil.getNodeForTest(test);
    if (testNode != null) {
      finishTestNode(tree, test, {message: cause});
    }
  });
}

function getCurrentTest(ctx) {
  return ctx != null ? ctx.currentTest : null;
}

function handleBeforeEachHookFailure(tree, beforeEachHook, err) {
  var done = false;
  var currentTest = getCurrentTest(beforeEachHook.ctx);
  if (currentTest != null) {
    var testNode = treeUtil.getNodeForTest(currentTest);
    if (testNode != null) {
      finishTestNode(tree, currentTest, err);
      done = true;
    }
  }
  if (!done) {
    finishTestNode(tree, beforeEachHook, err);
  }
}

/**
 * @param {Object} suite mocha suite object
 */
function finishSuite(suite) {
  var suiteNode = treeUtil.getNodeForSuite(suite);
  if (suiteNode == null) {
    throw Error('Cannot find suite node for ' + suite.title);
  }
  suiteNode.finish(false);
}

const BaseReporter = util.requireBaseReporter();
if (BaseReporter) {
  require('util').inherits(IntellijReporter, BaseReporter);
}

function IntellijReporter(runner) {
  if (BaseReporter) {
    BaseReporter.call(this, runner);
  }
  var tree;
  // allows to postpone sending test finished event until 'afterEach' is done
  var finishingQueue = new SingleElementQueue(function (testNode) {
    testNode.finish(false);
  });

  runner.on('start', util.safeFn(function () {
    tree = new Tree(function (str) {
      util.writeToStdout(str);
    });
    tree.writeln('##teamcity[enteredTheMatrix]');
    tree.testingStarted();

    var tests = [];
    treeUtil.forEachTest(runner, function (test) {
      var match = true;
      if (runner._grep instanceof RegExp) {
        match = runner._grep.test(test.fullTitle());
      }
      if (match) {
        tests.push(test);
      }
    });

    tree.writeln('##teamcity[testCount count=\'' + tests.length + '\']');
    tests.forEach(function (test) {
      registerTestNode(tree, test);
    });
  }));

  runner.on('suite', util.safeFn(function (suite) {
    var suiteNode = treeUtil.getNodeForSuite(suite);
    if (suiteNode != null) {
      suiteNode.start();
    }
  }));

  runner.on('test', util.safeFn(function (test) {
    finishingQueue.processAll();
    startTest(tree, test);
  }));

  runner.on('pending', util.safeFn(function (test) {
    finishingQueue.processAll();
    finishTestNode(tree, test, null, finishingQueue);
  }));

  runner.on('pass', util.safeFn(function (test) {
    finishTestNode(tree, test, null, finishingQueue);
  }));

  runner.on('fail', util.safeFn(function (test, err) {
    if (isBeforeEachHook(test)) {
      finishingQueue.processAll();
      handleBeforeEachHookFailure(tree, test, err);
    }
    else if (isBeforeAllHook(test)) {
      finishingQueue.processAll();
      finishTestNode(tree, test, err);
      markChildrenFailed(tree, test.parent, test.title + " failed");
    }
    else {
      finishTestNode(tree, test, err, finishingQueue);
    }
  }));

  runner.on('suite end', util.safeFn(function (suite) {
    finishingQueue.processAll();
    if (!suite.root) {
      finishSuite(suite);
    }
  }));

  runner.on('end', util.safeFn(function () {
    finishingQueue.processAll();
    tree.testingFinished();
    tree = null;
  }));

}

module.exports = IntellijReporter;
