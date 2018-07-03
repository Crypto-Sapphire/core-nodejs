import requireDir from 'require-dir'

export default class ConfigLoader

	@load: (dir)->
# Before loading the config files we define a global
# env helper function. And we save the old env func.
		oldFunc = global.env
		global.env = ConfigLoader.env

		# Load the config file
		config = requireDir dir, {recurse: true}
		Object.freeze config

		# Restore the old env func
		global.env = oldFunc

		return config

	@env: (name, defaultValue)->
		value = process.env[name]
		if typeof value is 'undefined'
			return defaultValue

		if value is 'true' or value is 'TRUE'
			return true

		if value is 'false' or value is 'FALSE'
			return false

		if !isNaN value
			return Number value

		if value is 'null' or value is 'NULL'
			return null

		return value
