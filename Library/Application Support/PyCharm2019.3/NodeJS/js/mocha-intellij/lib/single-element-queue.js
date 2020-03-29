/**
 * @constructor
 * @param {Function} processor
 */
function SingleElementQueue(processor) {
  this.processor = processor;
  this.current = null;
}

SingleElementQueue.prototype.add = function (element) {
  if (this.current != null) {
    process.stderr.write("mocha-intellij: unexpectedly unprocessed element " + element);
    this.processor(this.current);
  }
  this.current = element;
};

SingleElementQueue.prototype.processAll = function () {
  if (this.current != null) {
    this.processor(this.current);
    this.current = null;
  }
};

SingleElementQueue.prototype.clear = function () {
  this.current = null;
};

module.exports = SingleElementQueue;
