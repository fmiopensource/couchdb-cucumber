# requires
require 'cucumber/formatter/unicode'
require 'rest_client'
require 'json'
require 'logger'

# server, including usr, pwd, url, port
COUCH_SERVER = 'http://127.0.0.1:5984'

# set up a default logger
LOGGER = Logger.new('cucumber.log')
LOGGING = true # make false to turn it off