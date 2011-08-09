###############################################################################
# check
###############################################################################

module Dash::Models
  class Check
    attr_reader :name, :status, :body
    def initialize(yaml)
      @name = yaml.keys.first
      @status = yaml.values.first[:status]
      @body = yaml.values.first[:body]
    end
    def match (regexp)
      @name =~ regexp ||
        @status =~ regexp ||
        @body =~ regexp
    end
  end
end

###############################################################################
