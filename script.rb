require 'json'
require 'net/http'
require 'uri'

uri = URI.parse(ENV['SLACK_INCOMING_WEBHOOK_URL'])

https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true

req = Net::HTTP::Post.new(uri.request_uri)
req['Content-Type'] = 'application/json'
req.body = { text: 'Hello, Nomad!' }.to_json

https.request(req)
