export default class Trait
	@ignore: []

	constructor: (@provider, @container) ->

	@use: (...items) ->
		get: (...args) =>
			{name, symbol, exports} = @get(args...)

			translated = {}

			set = (from, to = from) =>
				if from not of exports
					throw new Error("No item #{from} in Trait(#{name})")

				translated[to] = exports[from]


			for item in items
				if typeof item == 'string'
					set(item)

				if Array.isArray(item)
					items.push(item...)

				if typeof item == 'object'
					for [from, to] in Object.entries(item)
						set(from, to)

			return {
				name
				symbol
				exports: translated
			}


	@as: (as) ->
		get: (...args) =>
			{name, symbol, exports} = @get(args...)

			newExports = {}

			newExports[as] = exports

			return {
				name: name
				symbol
				exports: newExports
			}

	@getSymbol: ->
		if 'symbol' not of this
			@symbol = Symbol(@name)

		@symbol

	@get: (provider, container) ->
		trait = new this provider, container
		# this is used to get the defined functions in the class
		traitExports = Object.getOwnPropertyNames(Object.getPrototypeOf(trait))
			.filter((a) => a not in @ignore and a != 'constructor')

		return {
			name: @name
			symbol: @getSymbol()
			exports: traitExports.reduce(
				(carry, item) =>
					carry[item] = trait[item].bind(trait)
					carry
			,
				{}
			)
		}
