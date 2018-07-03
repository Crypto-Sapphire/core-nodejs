import {Container}   from '@eater/emerald'
import ConfigLoader  from './config-loader'
import dotenv        from 'dotenv'
import winston       from 'winston'
import {join}        from 'path'

export default class App
	providers: new Map

	constructor: (@container = new Container) ->


	run: (dir) ->
		# ----------------------------------------
		# Fase 1: Load the environment variables
		# from a .env file
		dotenv.load()


		# ----------------------------------------
		# Fase 2: Load the config file
		config = ConfigLoader.load join(dir, 'config')

		@container.instance 'config', config


		# ----------------------------------------
		# Fase 3: Create the logger instance
		logger = new winston.Logger {
			level: config.logging.level
		}

		drivers = config.logging.drivers

		if drivers.includes 'sentry'
			Sentry = require 'winston-raven-sentry'
			logger.add Sentry, config.logging.sentry

		if drivers.includes 'console'
			logger.add winston.transports.Console

		@container.instance 'logger', logger


		# ----------------------------------------
		# Fase 4: construct the service providers
		try
			for [key, path] in Object.entries(config.app.services)
				ServiceProvider = require path
				@providers.set key, ServiceProvider

				ServiceProvider.register @container

				@container.define key, =>
					provider = new ServiceProvider(@container)
					provider.attachTraits()
					await provider.boot()

					provider

		catch error
			logger.error error

			# This means every uncaught error will exit the application
			process.exit(1)
