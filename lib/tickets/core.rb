module Lighthouse
  class << self
    attr_accessor :user_id
  end
  
  class Ticket
    def to_growl(nr)
      "#{nr} #{title[0..30]}..."
    end
  end
end

class OurTickets
  attr_writer :queries
  attr_reader :tickets_by_query
  attr_reader :tickets
  
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
        message <<  tickets.collect { |t| t.to_growl(nr+tickets.index(t)) }.join("\n")
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
end