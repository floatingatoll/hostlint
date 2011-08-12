###############################################################################
# base
###############################################################################

module Dash::Models
  class Base
    @@objects = Hash.new { |h, k| h[k] = Hash.new }
    attr_reader :name

    def initialize(name, params={})
      @name = name
      @params = params
      @@objects[self.class.to_s][name] = self
    end

    def self.find(name)
      return @@objects[self.name][name] rescue []
    end

    def self.each(&block)
      h = @@objects[self.name] rescue {}
      h.each { |k, v| yield(k, v) }
    end

    def self.all
      return @@objects[self.name].values
    end

    def [](key)
      return @params[key] rescue []
    end

    def to_s
      return @name
    end

    def <=>(other)
      return to_s <=> other.to_s
    end

  end # Dash::Models::Base
end # Dash::Models

###############################################################################
