require "yaml"

module Lighthouse
  class << self
    attr_accessor :user_id
  end
  
  class Ticket
    def to_growl(nr)      
      "#{me_string}#{nr} #{title[0..30]}..."
    end
    
    def to_string_with_nr(nr)
      "#{me_string}#{nr} #{title}"
    end
    
    def me_string
      if assigned_user_id == Lighthouse.user_id
        return "> "
      else
        return ""
      end
    end
  end
end

class OurTickets
  attr_writer :queries
  attr_reader :tickets_by_query
  attr_reader :tickets
  CONFIG_FILENAME = ".tickets_config.yaml"
  
  def initialize(queries)
    @tickets_by_query = {}
    @queries = queries
    @tickets = []
    
    @queries.each do |title, query|
      tickets = Lighthouse::Ticket.find(:all, :params => query)
      
      @tickets_by_query[title] = tickets
      @tickets += tickets
    end
  end
  
  def show(growl=true)
    message = ""
    
    nr = 0
    @tickets_by_query.each do |title, tickets|
      if tickets.length > 0
        message << "#{title}: #{tickets.length} tickets\n\n"
        message <<  tickets.collect do |t| 
          if growl
            t.to_growl(nr+tickets.index(t))
          else
            t.to_string_with_nr(nr+tickets.index(t))
          end
          
        end.join("\n")
        message << "\n\n"
      end
      
      nr += tickets.length
    end
    
    if growl
      Growl.notify {
        self.message = message
        sticky!
        self.title = "Tickets"
      }
    else
      puts message
    end
  end
  
  def start_irb
    require "irb"
    IRB.start_session self
  end
  
  def open(nr)
    `open #{@tickets[nr.to_i].url}`
    "opening '#{@tickets[nr.to_i].title}' in browser"
  end
  
  def info(nr)
    puts @tickets[nr.to_i].original_body
    
    "Info on '#{@tickets[nr.to_i].title}'"
  end
  
  def self.setup
    puts
    
    puts "This gem is an easy way to stay up to date with your lighthouse tickets through one or more queries."
    puts
        
    puts "I've put a .tickets_config.yaml file into your home directory"
    puts "You will have to alter it to use your own info."
        
    puts 
    
    output_file_name = $debug ? ".tickets_config_testing.yaml" : CONFIG_FILENAME
    
    FileUtils.cp("#{ROOT}/lib/tickets/tickets_config_example.yaml", "#{ENV["HOME"]}/#{output_file_name}")
  end
  
  def self.read_config
    begin
      config_yaml = YAML.load(File.read("#{ENV['HOME']}/#{CONFIG_FILENAME}"))
    
      Lighthouse.account  =  config_yaml["account"]
      Lighthouse.token    =  config_yaml["token"]
      Lighthouse.user_id  =  config_yaml["user_id"]

      $queries            =  config_yaml["queries"]
      $debug              =  config_yaml["debug"]
      
    rescue Errno::ENOENT
      puts "whoeps, you should run 'tickets setup' first ..."
      exit
    end
  end
end