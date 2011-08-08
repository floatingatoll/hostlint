#!/usr/bin/env ruby
###############################################################################
# hostlint-server
###############################################################################
require "rubygems"
require "namespace"

require "rack"
require "sinatra/base"
require "helpers"
require "models"
require "thread"
require "set"
require "rubyfixes"

# map of STATUS => host::check
module Dash
  class App < Sinatra::Base
    include Dash::Models
    helpers Dash::Helpers
    set :run, true
    set :root, File.dirname(__FILE__)
    set :static, true
    set :logging, true

    reports = []
    hosts = Set.new
    clusters = Set.new
    @@reports = []
    @@statindex = {}

    post '/' do
      puts 'processing data...'
      reports << request.body.string
      reports.each do |y|
        r = YAML.load(y)
        hosts << Host.new(r)
        clusters << r[:cluster]
        @@reports << r
      end
      reports.pop
    end

    before do
      @request_time = Time.now
      @hosts = hosts
      @clusters = clusters
      @stats = @@statindex
      @reports = @@reports
    end

    get '/' do
      erb :view
    end

    get '/check/:check/?' do
      raise "check not found #{params[:check]}" unless Host.check_map[params[:check].to_sym]
      @check = params[:check].to_sym
      erb :check
    end

    get '/host/:cluster/:host/?' do
      @host = Host.find_by_name_and_cluster(params[:host], params[:cluster])
      @report = @@reports.find { |r| r[:host] == params[:host] }
      erb :host
    end

    get '/host/:cluster/:host/:check/?' do
      "fixme"
    end

    get '/cluster/:cluster/?' do
      erb :cluster
    end

    get '/status/:status/?' do
      erb :status
    end

  end
end

puts "let's get rready to rrrumble!"
Rack::Handler::Mongrel.run(Dash::App, :Port => 9998)

###############################################################################
