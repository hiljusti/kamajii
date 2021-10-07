# Kemal is a microservice framework. (Like Sinatra/Flask)
# Docs: https://kemalcr.com
require "kemal"
require "kamajii"

get "/" do |env|
  content = env.request.body

  request = content ? content.gets_to_end : "{}"

  env.response.content_type = "application/json"
  {message: "greetings", request: request}.to_json
end

post "/push/:stack" do |env|
  stack = env.params.url["stack"]
  content = env.request.body

  item = content ? content.gets_to_end : ""

  Kamajii.push stack, item

  env.response.content_type = "text/plain"
  env.response.status = HTTP::Status::CREATED
  "created"
end

get "/pop/:stack" do |env|
  stack = env.params.url["stack"]

  content = Kamajii.pop stack

  env.response.content_type = "text/plain"
  env.response.status = HTTP::Status::CREATED
  content
end

error 404 do |env|
  env.response.content_type = "application/json"
  {error: "USAGE: GET /"}.to_json
end

Kemal.run