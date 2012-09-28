
should = require "should"

cdsl = require ".."

describe "CoffeeScript DSL View Engine", ->
  it "should return a DSL template", ->

    testDsl = cdsl.dsl()
    should.exist testDsl.render
    should.exist testDsl.renderFile


  it "should render a simple DSL", (done)->

    testDsl = cdsl.dsl()

    testDsl.set "test", (value)->
      value

    expected = "Hello World"

    testDsl.render "@test '#{expected}'", (error, result)->
      should.not.exist error
      should.exist result
      result.should.equal expected
      done()


  it "should render a complex DSL", (done)->

    testDsl = cdsl.dsl()

    expected = "Hello World"

    testDsl.set "test", (fun)->
      fun.call
        hello: (value)->
          "Hello #{value}"

    tmpl = """
    @test ->
      @hello "World"
    """

    testDsl.render tmpl, (error, result)->
      should.not.exist error
      should.exist result
      result.should.equal expected
      done()
