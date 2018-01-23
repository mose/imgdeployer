require 'sinatra'
require 'sinatra/json'
require File.expand_path '../lib/aws.rb', __FILE__

configure do
  set :erb, layout: :_layout
  enable :sessions
  # just for dev with shotgun
  set    :session_secret, "whatever suits you"
end

get '/' do
  if session[:apikey]
    @logged = true
    @created = !!session[:instance]
    erb :index
  else
    erb :login
  end
end

post '/login' do
  session[:apikey] = params['key']
  session[:apisec] = params['sec']
  redirect '/'
end

get '/logout' do
  session.delete(:apikey)
  session.delete(:apisec)
  session.delete(:instance)
  redirect '/'
end

# js calls --------------

def action(name, delete = false)
  content_type :json
  if session[:apikey]
    aws = Manager::AWS.new session[:apikey], session[:apisec], session[:instance]
    json aws.send(name)
  else
    json error: "no API key defined"
  end
end

post '/create' do
  content_type :json
  if session[:apikey]
    aws = Manager::AWS.new session[:apikey], session[:apisec], session[:instance]
    id = aws.create
    if id['error']
      json id
    else
      session[:instance] = id
      json message: "Creation in progress"
    end
  else
    json error: "no API key defined"
  end
end

post '/start' do
  action :start
end

post '/restart' do
  action :restart
end

post '/stop' do
  action :stop
end

post '/terminate' do
  action :terminate, true
end

post '/info' do
  content_type :json
  # logger.info session.inspect
  if session[:instance]
    aws = Manager::AWS.new session[:apikey], session[:apisec], session[:instance]
    # logger.info aws.instance_status.to_h.inspect
    json state: aws.instance.state.to_h,
         status: aws.instance_status.instance_statuses[0].to_h,
         public_ip_address: aws.instance.public_ip_address
  else
    json no_instance: true
  end
end

post '/forget' do
  session.delete(:instance)
  json message: 'ok'
end
