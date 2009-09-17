ROOT = File.dirname(__FILE__) + "/.."

require "rubygems"
require "lighthouse-api"
require "growl"
require 'irb'
 
# thanks James Kilton, now i do not need to require ruby-debug anymore
# http://jameskilton.com/2009/04/02/embedding-irb-into-your-ruby-application/
module IRB # :nodoc:
  def self.start_session(binding)
    unless @__initialized
      args = ARGV
      ARGV.replace(ARGV.dup)
      IRB.setup(nil)
      ARGV.replace(args)
      @__initialized = true
    end
 
    workspace = WorkSpace.new(binding)
 
    irb = Irb.new(workspace)
 
    @CONF[:IRB_RC].call(irb.context) if @CONF[:IRB_RC]
    @CONF[:MAIN_CONTEXT] = irb.context
 
    catch(:IRB_EXIT) do
      irb.eval_input
    end
  end
end

require File.expand_path("#{ROOT}/lib/tickets/core")

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


require File.expand_path("#{ROOT}/lib/tickets/cli")