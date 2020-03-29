var intellijUtil = require('./mochaIntellijUtil')
  , hasOwnProperty = Object.prototype.hasOwnProperty;

function getRoot(suiteOrTest) {
  var node = suiteOrTest;
  while (!node.root) {
    node = node.parent;
  }
  return node;
}

function findRoot(runner) {
  if (runner.suite != null) {
    return getRoot(runner.suite)
  }
  if (runner.test != null) {
    return getRoot(runner.test)
  }
  return null;
}

function processTests(node, callback) {
  node.tests.forEach(function (test) {
    callback(test);
  });
  node.suites.forEach(function (suite) {
    processTests(suite, callback);
  });
}

function forEachTest(runner, callback) {
  var root = findRoot(runner);
  if (!root) {
    intellijUtil.writeToStderr("[IDE integration] Cannot find mocha tree root node");
  }
  else {
    processTests(root, callback);
  }
}

function finishTree(tree) {
  tree.root.children.forEach(function (node) {
    node.finishIfStarted();
  });
}

var INTELLIJ_TEST_NODE = "intellij_test_node";
var INTELLIJ_SUITE_NODE = "intellij_suite_node";

/**
 * @param {Object} test mocha test
 * @returns {TestNode}
 */
function getNodeForTest(test) {
  if (hasOwnProperty.call(test, INTELLIJ_TEST_NODE)) {
    return test[INTELLIJ_TEST_NODE];
  }
  return null;
}

/**
 * @param {Object} test mocha test
 * @param {TestNode} testNode
 */
function setNodeForTest(test, testNode) {
  test[INTELLIJ_TEST_NODE] = testNode;
}

/**
 * @param {Object} suite mocha suite
 * @returns {TestSuiteNode}
 */
function getNodeForSuite(suite) {
  if (hasOwnProperty.call(suite, INTELLIJ_SUITE_NODE)) {
    return suite[INTELLIJ_SUITE_NODE];
  }
  return null;
}

/**
 * @param {Object} suite mocha suite
 * @param {TestSuiteNode} suiteNode
 */
function setNodeForSuite(suite, suiteNode) {
  suite[INTELLIJ_SUITE_NODE] = suiteNode;
}

module.exports.forEachTest = forEachTest;
module.exports.finishTree = finishTree;

module.exports.getNodeForTest = getNodeForTest;
module.exports.setNodeForTest = setNodeForTest;

module.exports.getNodeForSuite = getNodeForSuite;
module.exports.setNodeForSuite = setNodeForSuite;
