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
      @status = params[:status]
      unless [Host::OK, Host::FAIL].member?(@status)
        raise "unknown status #{@status}"
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
        @checks = Host.checks.find_all { |c| c.to_s =~ regexp }
        erb :"search_all"
      when "1" # hosts
        @match_hosts = @hosts.find_all { |h| h.name =~ regexp }
        erb :"search_host"
      when "2" # checks
        @banner = ""
        @checks = @hosts.map do |h|
          [h, h.checks.find_all { |c| c.match(regexp) }]
        end.find_all { |h, c| c }
        erb :"search_checks"
      when "3" # failing
        @banner = "failing"
        @checks = @hosts.map do |h|
          [h, h.checks.find_all { |c| c.status == Host::FAIL && c.match(regexp) }]
        end.find_all { |h, c| c.size > 0 }
        erb :"search_checks"
      when "4" # succeeding
        @banner = "succeeding"
        @checks = @hosts.map do |h|
          [h, h.checks.find_all { |c| c.status == Host::OK && c.match(regexp) }]
        end.find_all { |h, c| c.size > 0 }
        erb :"search_checks"
      end
    end

  end
end

puts "let's get rready to rrrumble!"
Rack::Handler::Mongrel.run(Dash::App, :Port => 9998)

###############################################################################
