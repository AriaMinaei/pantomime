module.exports = class TouchyEl

	@_ids: []

	@get: (el) ->

		if el instanceof TouchyEl then return el

		if id = el.getAttribute('touchy-id')

			return TouchyEl.getById id

		TouchyEl._ids.push newEl = new TouchyEl el, TouchyEl._ids.length

		newEl

	@getById: (id) ->

		@_ids[id]

	constructor: (@node, @id) ->

		@_listeners = {}

		@node.setAttribute 'touchy-id', @id

		@_listensTo =

			move: no

			tap: no

	listensTo: (what) ->

		if @_listensTo[what]? then return @_listensTo[what] else return no

	on: (eventName, listener) ->

		if eventName is 'move'

			@_listensTo.move = yes

		else if eventName is 'tap'

			@_listensTo.tap = yes

		unless @_listeners[eventName]?

			@_listeners[eventName] = []

		@_listeners[eventName].push listener

		@

	_fire: (eventName, data) ->

		listeners = @_listeners[eventName]

		return unless listeners?

		for listener in listeners

			listener.call @, data

		@