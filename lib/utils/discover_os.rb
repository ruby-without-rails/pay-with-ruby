require 'rbconfig'

module PayWithRuby
  module Utils
    # Module DiscoverOSUtil
    module DiscoverOS
      class << self
        def os
          case os_string
          when /mswin|msys|mingw|cygwin|bccwin|wince|emc/ then :windows
          when /darwin|mac os/ then :macosx
          when /linux/ then :linux
          when /solaris|bsd/ then :unix
          else raise StandardError, "Sistema Operacional não identificado: #{os_string.inspect}"
          end
        end

        def os_string
          RbConfig::CONFIG['host_os']
        end
      end
    end
  end
end
