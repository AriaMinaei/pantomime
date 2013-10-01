if typeof define isnt 'function' then define = require('amdefine')(module)

define [
	'./utility/object'
], (object) ->

	class Pantomime

		@_defaultOptions:

			root: if window? then window.document else null

		constructor: (options) ->

			@_options = object.override @_defaultOptions, options

			@_root = @_options.root

		gaze: ->

