
should = require "should"

cdsl = require ".."

describe "CoffeeScript DSL View Engine", ->

  describe "Template", ->

    it "should return a DSL template", ->

      testDsl = cdsl.dsl()
      should.exist testDsl.render
      should.exist testDsl.renderFile

  describe "Rendering", ->

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

  describe "Scoping", ->

    describe "Locals", ->

      testDsl = cdsl.dsl()

      locals =
        test: ()->
          "Testing"

      it "should be able to reference a local variable without '@'", (done)->

        testDsl.render "test()", locals, (error, result)->
          should.not.exist error
          should.exist result
          result.should.equal "Testing"
          done()

      it "shouldn't be able to reference a local variable with '@'", (done)->

        testDsl.render "@test()", locals, (error, result)->
          should.exist error
          error.message.should.equal "Object #<Object> has no method 'test'"
          done()

    describe "DSL Helpers", ->

      testDsl = cdsl.dsl()

      testDsl.set "test", (value)->
        value

      it "should be able to reference a helper variable with '@'", (done)->

        testDsl.render '@test "Testing"', (error, result)->
          should.not.exist error
          should.exist result
          result.should.equal "Testing"
          done()

      it "shouldn't be able to reference a helper without '@'", (done)->

        testDsl.render "test", (error, result)->
          should.exist error
          error.message.should.equal "test is not defined"
          done()
