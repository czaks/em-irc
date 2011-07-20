module EM::P::IRC
  # Client class. Please override and use as follows:
  #
  # EM::run do
  #   EM::connect "sundance.6irc.net", 6667, MyIRCBot, :nick => "myircbot"
  # end
  #
  # Overridable methods (have one Message object in parameter unless told otherwise)
  # * post_init
  # * when_ready - called when connected to the IRC
  # * on_command - eg. on_privmsg or on_005 - called when got a given reply from server
  # * receive_line(string:line) - called when got a line from server
  # * receive_message - called on every 
  #
  # Remember to issue "super if defined?(super)", otherwise unpredictable things may happen
  class Client < EM::P::LineAndTextProtocol
    # Overridable default channel class (you can overload it and overload the channel events)
    attr_accessor :channel_class
    
    # Settings:
    # * :nick
    # * :ident
    # * :realname
    # * :server_password
    def initialize(settings)
      @settings = settings.dup
      @settings[:ident] ||= "em-irc"
      @settings[:nick] ||= "EM-IRC"
      @settings[:realname] ||= "EventMachine::Protocols::IRC"
      
      @channel_class = Channel
      
      @channels = []
      
      super if defined?(super)
    end
    
    # Login to the server (called by EventMachine when connected)
    def post_init
      send_message :PASS, @settings[:server_password] if @settings[:server_password]
      send_message :USER, @settings[:ident], "0", "0", @settings[:realname]
      send_message :NICK, @settings[:nick]
    end
    
    # Used for sending raw messages
    def send_line (line)
      send_data line.to_s
    end
    
    # Call like:
    # send_message :PRIVMSG, "#channel", "Hello world!"
    def send_message (*params)
      send_line Message.new(*params)
    end
    
    # Decodes gotten line - calls receive_message
    def receive_line (line)
      msg = Message.decode line
      
      receive_message msg
    end
    
    # Dispatches messages
    def receive_message (msg)
      fun = ("on_" << msg.command_string.downcase).to_sym
      
      send fun, msg if respond_to? fun
    end
    
    # Responds to pings
    def on_ping (msg)
      send_message :PONG, msg[0]
    end
    
    # Calls when_ready when gets ready
    def on_001 (msg)
      when_ready if respond_to? :when_ready
    end
  end
end