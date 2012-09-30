fs = require "fs"
coffee = require "coffee-script"

parse = (str, options)->
  # We'll need to find out if we can set what gets put in .call(this).
  # It needs to be .call(locals)
  str = """
  return (()->
    #{replaceAll(str,"\n", "\n  ")}
  ).call(helpers)
  """
  js = coffee.compile str, bare: true
  "with (locals || {}) {\n#{js}\n}"

exports.dsl = (defaultHelpers = {})->
  template = {}
  template.helpers = defaultHelpers
  template.cache = {}

  template.compile = (str, options={})->
    fn = parse str, options

    fn = new Function 'helpers', 'locals', fn

    (locals)->
      fn(template.helpers, locals)

  template.render = (str, options, fn)->
    if typeof options is 'function'
      fn = options
      options = {}

    if options.cache and not options.filename
      return fn new Error "the 'filename' option is required for caching"

    try
      path = options.filename
      tmpl = if options.cache\
        then template.cache[path] or (template.cache[path] = template.compile(str, options))\
        else template.compile str, options
      fn null, tmpl options
    catch e
      fn e

  template.renderFile = (path, options, fn)->
    key = "#{path}:string"
    if typeof options is 'function'
      fn = options
      options = {}

    try
      options.filename = path
      str = if options.cache\
        then template.cache[key] or (template.cache[key] = fs.readFileSync(path, 'utf8'))\
        else fs.readFileSync(path, 'utf8')
      template.render str, options, fn
    catch e
      fn e

  # Express Support
  template.__express = template.renderFile

  template.set = (key, value)->
    template.helpers[key] = value

  template

# http://fagnerbrack.com/en/2012/03/27/javascript-replaceall/
# Faster than str.replace
replaceAll = (str, token, newToken, ignoreCase) ->
  i = -1
  _token = undefined
  if typeof token is "string"
    _token = (if ignoreCase is true then token.toLowerCase() else `undefined`)
    str = str.substring(0, i)
             .concat(newToken)
             .concat(str.substring(i + token.length)) while (i = ((if _token isnt `undefined` then str.toLowerCase().indexOf(_token, (if i >= 0 then i + newToken.length else 0)) else str.indexOf(token, (if i >= 0 then i + newToken.length else 0))))) isnt -1
  str
