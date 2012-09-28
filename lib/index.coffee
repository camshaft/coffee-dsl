fs = require "fs"
coffee = require "coffee-script"
_ = require "underscore"

parse = (str, options)->
  str = """
  return (()->
    #{str.replace('\n','\n\t')}
  ).call(locals)
  """
  js = coffee.compile str, bare: true
  "with (locals || {}) {\n#{js}\n}"

exports.dsl = (defaults = {})->
  template = {}

  template.cache = {}
  template.locals = defaults

  template.compile = (str, options={})->
    fn = parse str, options

    fn = new Function 'locals', fn

    (locals)->
      fn(locals)

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
      fn null, tmpl _.extend template.locals, options
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
    template.locals[key] = value

  template
