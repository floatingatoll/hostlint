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

    post '/' do
      puts 'processing data...'
      reports << request.body.string
      reports.each do |y|
        r = YAML.load(y)
        hosts << Host.new(r)
        clusters << r[:cluster]
      end
      reports.pop
    end

    before do
      @request_time = Time.now
      @hosts = hosts
      @clusters = clusters
    end

    get '/' do
      erb :view
    end

    # fixme include timetamp in filename
    get '/yaml/:cluster/:host' do
      content_type "text/x-yaml"
      Host.find_by_name_and_cluster(params[:host], params[:cluster]).report.to_yaml
    end

    get '/check/:check/?' do
      raise "check not found #{params[:check]}" unless Host.check_map[params[:check].to_sym]
      @check = params[:check].to_sym
      erb :check
    end

    get '/host/:cluster/:host/?' do
      @host = Host.find_by_name_and_cluster(params[:host], params[:cluster])
      erb :host
    end

    get '/host/:cluster/:host/:check/?' do
      "fixme"
    end

    get '/cluster/:cluster/?' do
      erb :cluster
    end

    get '/status/:status/?' do
      unless [Host::OK, Host::FAIL].member?(params[:status])
        raise "unknown status #{params[:status]}"
      end
      erb :status
    end

    get '/search' do
      regexp = Regexp.new(params["keyword"], Regexp::IGNORECASE)
      case params["cat"]
      when "0" # all
        @reports = @hosts.map do |h|
          [h, h.checks.find_all { |c| c.match(regexp) }]
        end.find_all { |h, c| c }
        @match_hosts = @hosts.find_all { |h| h.name =~ regexp }
        @checks = Host.checks.find_all { |h| h.to_s =~ regexp }
        erb :"search_all"
      when "1" # hosts
        @match_hosts = @hosts.find_all { |h| h.name =~ regexp }
        erb :"search_host"
      when "2" # checks
        @checks = Host.checks.find_all { |c| c.match(regexp) }
        erb :"search_checks"
      when "3" # failing
        params["keyword"]
      when "4" # succeeding
        params["keyword"]
      end
    end

  end
end

puts "let's get rready to rrrumble!"
Rack::Handler::Mongrel.run(Dash::App, :Port => 9998)

###############################################################################
