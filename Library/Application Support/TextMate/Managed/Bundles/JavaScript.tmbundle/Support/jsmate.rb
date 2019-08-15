#!/usr/bin/env ruby18

require "#{ENV['TM_SUPPORT_PATH']}/lib/exit_codes"
require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"

module JavaScript

  # All arrays populated below were from Mozilla's JavaScript Reference: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference
  #
  # None of the non-standard stuff is supported below but a case could be made to do so

  # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/$term
  GLOBAL_CONSTRUCTORS = [
    'Array',
    'Boolean',
    'Date',
    'Error',
    'EvalError',
    'Function',
    'Iterator',
    'Number',
    'Object',
    'RangeError',
    'ReferenceError',
    'RegExp',
    'String',
    'SyntaxError',
    'TypeError',
    'URIError'
  ]

  # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/$term
  GLOBAL_FUNCTIONS = [
    'decodeURI',
    'decodeURIComponent',
    'encodeURI',
    'encodeURIComponent',
    'eval',
    'isFinite',
    'isNaN',
    'parseFloat',
    'parseInt'
  ]

  # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/$term
  GLOBAL_OBJECTS = [
    'Infinity',
    'Intl',
    'JSON',
    'Math',
    'NaN',
    'undefined',
    'null'
  ]

  # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/$term
  OPERATORS = [
    'delete',
    # 'function', # Handled below as a statement (The page has links to the Function constructor and the function operator)
    'get',
    'in',
    'instanceof',
    'let',
    'new',
    'set',
    'this',
    'typeof',
    'void'
    # 'yield', # Handled below as a statement
  ]

  # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/$term
  STATEMENTS = [
    'break',
    'catch', # try...catch
    'const',
    'continue',
    'debugger',
    'do', # do...while
    'else', # if...else
    'for',
    'function',
    'if', # if...else
    'label',
    'let',
    'return',
    'switch',
    'throw',
    'try', # try...catch
    'var',
    'while',
    'with',
    'yield'
  ]

  def JavaScript::documentationForWord
    rawTerm = STDIN.read.strip
    term, *subTerm = rawTerm.split(/\./)
    url = nil

    if GLOBAL_CONSTRUCTORS.include?(term) or GLOBAL_FUNCTIONS.include?(term) or GLOBAL_OBJECTS.include?(term)
      url = 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/'
      term += '/' + subTerm.join('/') unless subTerm.empty?
    elsif OPERATORS.include?(term)
      url = 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/'
    elsif STATEMENTS.include?(term)
      url = 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/'

      case term
        when 'try', 'catch' then term = 'try...catch'
        when 'do', 'while'  then term = 'do...while'
        when 'if', 'else'   then term = 'if...else'
      end
    end

    unless url.nil?
      url += term

      TextMate.exit_show_html("<meta http-equiv='Refresh' content='0;URL=#{url}'>")
    else
      TextMate.exit_show_tool_tip("Unable to find documentation for term: #{rawTerm}")
    end
  end
end