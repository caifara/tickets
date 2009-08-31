require "rubygems"
require File.expand_path(File.dirname(__FILE__) + '/../vendor/lighthouse-api/lib/lighthouse')
require "growl"
require "ruby-debug"

require File.expand_path(File.dirname(__FILE__) + '/tickets/core')

require File.expand_path(File.dirname(__FILE__) + '/../config/config')

if $debug
  class ActiveResource::Connection
    # Creates new Net::HTTP instance for communication with
    # remote service and resources.
    def http
      http = Net::HTTP.new(@site.host, @site.port)
      http.use_ssl = @site.is_a?(URI::HTTPS)
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl
      http.read_timeout = @timeout if @timeout
      #Here's the addition that allows you to see the output
      http.set_debug_output $stderr
      return http
    end
  end
end


require File.expand_path(File.dirname(__FILE__) + '/tickets/cli')