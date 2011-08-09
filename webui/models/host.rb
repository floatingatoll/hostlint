###############################################################################
# host
###############################################################################
require "models/base"

module Dash::Models
  class Host < Base
    OK = "OK"
    FAIL = "FAIL"

    @@checks = Set.new
    @@check_map = {}

    class << self
      def hosts_failing (check)
        @@check_map[check][FAIL]||[]
      end
      def hosts_succeeding (check)
        @@check_map[check][OK]||[]
      end

      def checks
        @@checks
      end
      def check_map
        @@check_map
      end
      def find_by_name_and_cluster(name, cluster)
        Host.each do |host_name, host|
          next unless host_name = name
          return host if host.cluster == cluster
        end
        return nil
      end

      def find_by_cluster(cluster)
        ret = []
        Host.each do |name, host|
          ret << host if host.cluster == cluster
        end
        return ret
      end
    end

    attr_reader :host_name, :checks, :cluster, :status_map, :report, :report_time

    def check (check)
      @checks.find { |c| c.name == check }
    end

    def checks_failing
      @status_map[FAIL]
    end

    def checks_succeeding
      @status_map[OK]
    end

    # hacks
    def name
      @hostname
    end

    def to_s
      @hostname
    end

    def initialize(yaml)
      # needed to disambiguate
      super(yaml[:host]+'.'+yaml[:cluster])
      @hostname = yaml[:host]
      @cluster = yaml[:cluster]
      @report = yaml
      @checks = report[:checks].map { |c| Check.new(c) }
      @status_map = {}
      @checks.each do |c|
        @status_map[c.status] ||= []
        @status_map[c.status] << c

        @@check_map[c.name]||= {}
        @@check_map[c.name][c.status]||= []
        @@check_map[c.name][c.status] << self

        @@checks << c.name
      end
      @report_time = yaml[:date]
    end

    def key
      "#{@cluster}#{@name}"
    end

    def eql?(other)
      key == other.key
    end

    def ==(other)
      key == other.key
    end

    # fixme @params is always empty right now
    def <=>(other)
      if @params[:host_sort] == "builtin"
        return key <=> other.key
      elsif @params[:host_sort] == "numeric"
        regexp = /\d+/
        match = @name.match(regexp)
        match2 = other.name.match(regexp)
        if match.pre_match != match2.pre_match
          return match.pre_match <=> match2.pre_match
        else
          return match[0].to_i <=> match2[0].to_i
        end
      else
        # http://www.bofh.org.uk/2007/12/16/comprehensible-sorting-in-ruby
        sensible = lambda do |k|
          k.to_s.split(
                 /((?:(?:^|\s)[-+])?(?:\.\d+|\d+(?:\.\d+?(?:[eE]\d+)?(?:$|(?![eE\.])))?))/ms
                 ).map { |v| Float(v) rescue v.downcase }
        end
        return sensible.call(self) <=> sensible.call(other)
      end
    end

    def hash
      key.hash
    end

  end # Dash::Models::Host
end # Dash::Models

###############################################################################
