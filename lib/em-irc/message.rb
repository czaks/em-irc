module EM::P::IRC
  # Example usage:
  # k = Message.decode
  # puts "#{k.command.to_s} sent by #{k.nick} (#{k.ident}@#{k.host})"
  # k.each { |i| puts "Parameter: #{i}" }
  # puts "First parameter: #{k.params[0]}"
  class Message
    attr_accessor :nick, :ident, :host
    attr_accessor :command
    attr_accessor :params
    
    attr_accessor :has_data
    
    class << self
      def decode msg
        #p msg
        msg = msg.chomp
        who = nil
        if msg[0] == ?:
          who, msg = msg.split " ", 2
          who.sub! ':', ''
        end
        
        msg, data = msg.split(" :", 2)
        params = msg.split " "
        params << data if data
        
        nick, ident, host = nil, nil, nil
        
        if who
          nick, ident, host = who.split(/[!@]/, 3)
        end
        
        command = params.shift.downcase
        if command =~ /^[0-9]+$/
          command = command.to_i
        else
          command = command.to_sym
        end
        
        m = Message.new
        m.nick = nick
        m.ident = ident
        m.host = host
        m.params = params
        m.command = command
        
        m.has_data = !!data
        
        m
      end
    end
    
    def initialize(*params)
      if params.size == 0
        return
      end
      
      self.nick = params.shift if params[0].class != Symbol and params[0].class != Fixnum
      
      if params[0].class != Symbol and params[0].class != Fixnum
        self.ident = params.shift
        self.host = params.shift
      end
      
      self.command = params.shift
      self.params = params
    end
    
    def encode
      #p self
      params = self.params.dup
      if params.size > 0 and has_data != false
        text = params.pop
        if text =~ / |^:/ or has_data == true
          text = ":" + text
        end
        params.push text
      end
      
      msg = ""
      
      nickstr = nil
      if nick
        nickstr = nick
        if ident and host
          nickstr << "!#{ident}@#{host}"
        end
        
        msg << ":" << nickstr << " "
      end
      
      msg << command_string
      
      if params.size > 0
        msg << " " << params.join(" ")
      end
      
      #p msg
      msg << "\r\n"
    end
    
    def command_string
      scommand = command
      if command.class == Fixnum
        if command <= 9
          scommand = "00" << command.to_s
        elsif command <= 99
          scommand = "0" << command.to_s
        end
      end
      
      scommand.to_s.upcase
    end
    
    def to_s
      encode
    end
    
    include Enumerable
    
    def each &block
      params.each &block
    end
    
    def [](id)
      params[id]
    end
    
    def []=(id, val)
      params[id] = val
    end
  end
end
