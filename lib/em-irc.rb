require 'rubygems'
require 'eventmachine'

module EM::P::IRC
  VERSION = "0.0.1"
  ROOT = File.expand_path(File.dirname(__FILE__))  
  SUBMODULES = ["message", "client", "channel"]
end

EM::IRC = EM::P::IRC

EM::P::IRC::SUBMODULES.each do |i|
  require File.join(EM::P::IRC::ROOT, "em-irc", i)
end
