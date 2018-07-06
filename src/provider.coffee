export default class Provider
	use: new Set()

	constructor: (@container)->
		# container bindings
		@get = @container.get.bind @container
		@c = @container
		@g = @c.g

	linkedTraits: {}

	traits: (...args) ->
		for arg in args
			@use.add(arg)

	attachTraits: ->
		for trait of @use
			@addTrait trait

	register: ->
	boot: ->

	addTrait: (traitDef) ->
		trait = traitDef.get this, @container

		@linkedTraits[trait.symbol] = trait

		for [key, value] in Object.entries(trait.exports)
			if key of this
				if 'trait' of this[key]
					err = "#{key} is already defined in Provider(#{@constructor.name}) by Trait(#{@linkedTraits[this[key].trait].name})"
				else
					err = "#{key} is already defined by Provider(#{@constructor.name})"

				throw new Error(
					"While exporting properties of Trait(#{trait.name}) encountered error: #{err}"
				)


			Object.defineProperty this, key, {
				value
			}

