TouchyEl = require './touchy/TouchyEl'

module.exports = class Touchy

	constructor: (@root) ->

		do @_listen

		@_activelyBeingTouched = no

		@_data = {}

	_listen: ->

		@root.addEventListener 'touchstart', (e) =>

			@_touchStart e

			e.stopPropagation()
			e.preventDefault()

		@root.addEventListener 'touchmove', (e) =>

			@_touchMove e

			e.stopPropagation()
			e.preventDefault()

		@root.addEventListener 'touchend', (e) =>

			@_touchEnd e

			e.stopPropagation()
			e.preventDefault()

	_reset: ->

		@_data = {}
		@_activelyBeingTouched = no

	_touchStart: (e) ->

		if @_activelyBeingTouched

			@_touchStartWhenActive e

		else

			@_start e

	_touchStartWhenActive: (e) ->

	_start: (e) ->

		mainTouch = e.touches[0]
		@_data.touchStartTime = Date.now()

		@_determineTargets mainTouch.target

		@_activelyBeingTouched = yes

	_touchEnd: (e) ->

		if e.touches.length is 0

			unless @_data.isMove?

				if Date.now() - @_data.touchStartTime < 250

					@_reportTap e

			else

				do @_endMove

			do @_reset

		else

			if @_data.isMove?

				@_handleEndForMove e

		return

	_reportTap: (e) ->

		if @_data.tapTarget?

			touch = e.changedTouches[0]

			@_data.tapTarget._fire 'tap', {x: touch.screenX, y: touch.screenY}

		return

	_touchMove: (e) ->

		unless @_data.howManyMoves?

			@_data.howManyMoves = 1

		else

			@_data.howManyMoves++

		if not @_data.isMove?

			if @_data.howManyMoves > 3

				@_data.isMove = yes

			else if Date.now() - @_data.touchStartTime >= 250

				@_data.isMove = yes

		if @_data.isMove?

			@_handleMove e

	_handleMove: (e) ->

		return unless @_data.moveTarget?

		unless @_data.startX?

			return @_initMoveFromEvent e

		x = (e.touches[0].pageX - @_data.startX)
		y = (e.touches[0].pageY - @_data.startY)

		@_data.lastMoveEvent =

			x: x - @_data.lastX
			y: y - @_data.lastY

			absX: x
			absY: y

		@_data.moveTarget._fire 'move', @_data.lastMoveEvent


		@_data.lastX = x
		@_data.lastY = y

		return

	_endMove: ->

		if @_data.moveTarget?

			@_data.moveTarget._fire 'move:end', @_data.lastMoveEvent

	_handleEndForMove: (e) ->

		return if e.changedTouches[0].identifier isnt @_data.id

		@_data.id = e.touches[0].identifier

		# And update the startX and startY
		@_data.startX = e.touches[0].pageX - (e.changedTouches[0].pageX - @_data.startX)
		@_data.startY = e.touches[0].pageY - (e.changedTouches[0].pageY - @_data.startY)


	_initMoveFromEvent: (e) ->

		# Hold the starting position
		@_data.startX = e.touches[0].pageX
		@_data.startY = e.touches[0].pageY

		@_data.lastX = 0
		@_data.lastY = 0

		# Remember id of the main touch
		@_data.id = e.touches[0].identifier


	_determineTargets: (node) ->

		loop

			break if node is window.document

			el = TouchyEl.get node

			unless @_data.tapTarget?

				if el.listensTo 'tap'

					@_data.tapTarget = el

			unless @_data.moveTarget

				if el.listensTo 'move'

					@_data.moveTarget = el

			break if @_data.tapTarget? and @_data.moveTarget?

			node = node.parentNode