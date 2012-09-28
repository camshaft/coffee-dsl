CoffeeScript DSL View Engine
============================

Want to make an awesome view engine in CoffeeScript? Try this:

```coffee
# my-dsl.coffee
cdsl = require "coffee-dsl"
myDSL = cdsl.dsl()

myDSL.set "root", (fun)->
  fun.call
    hello: (value)->
      "Hello #{value}"

module.exports = myDSL
```

```coffee
# my-view.coffee

@root ->
  @hello "World"
```

```coffee
# main.coffee
myDSL = require "my-dsl"

myDSL.renderFile "my-view.coffee", (error, result)->
  console.log result
```

This will render `Hello World`.

The real power comes when we want to build complex objects in a simple way. Look at [cscj](https://github.com/CamShaft/cscj) for an example.

Testing
-------

```sh
npm install -d
npm test
```
