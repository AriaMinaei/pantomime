if typeof define isnt 'function' then define = require('amdefine')(module)

define ['./scrolls', '../touchy/el'], (Scrolls, TouchyEl) ->

	class Scrollable

		constructor: (@node) ->

			@_scrolls = new Scrolls @node

			@tel = TouchyEl.get @node

			@tel.on 'move', (pos) =>

				@_scrolls.drag pos.absX, pos.absY

			@tel.on 'move:end', =>

				@_scrolls.release()

			every 2500, =>

				do @recalculate

		recalculate: ->

			@_scrolls._scrollerY.space = @_scrolls._childEl.getBoundingClientRect().height