package.path = "?.lua;?/init.lua;" .. package.path
import resume, yield, yieldto, bypass from require "lift"

describe 'lift', ->
	before_each ->
		export co = coroutine.create ->
			yield("foo", "bar")

	it 'passes a nil target when yielding', ->
		ok, target, a, b = coroutine.resume(co)
		assert.is.nil target
		assert.equal a, "foo"
		assert.equal b, "bar"

	it 'hides the target parameter when resuming', ->
		ok, a, b = resume(co)
		assert.equal a, "foo"
		assert.equal b, "bar"

	it 'lifts values through when yielding to target', ->
		top = coroutine.running()
		outer = coroutine.create ->
			inner = coroutine.create ->
				yield("foo", "bar")
				yieldto(top, "FOO", "BAR")
			yield select 2, resume inner
			resume inner
		ok, a, b = resume outer
		assert.equal a, "foo"
		assert.equal b, "bar"
		ok, a, b = resume outer
		assert.equal a, "FOO"
		assert.equal b, "BAR"
	
	it 'allows bypassing to normal coroutine.resume call', ->
		outer = coroutine.create ->
			inner = coroutine.create ->
				bypass("foo", "bar")
			resume inner
		ok, a, b = coroutine.resume outer
		assert.true ok
		assert.equal "foo", a
		assert.equal "foo", a
