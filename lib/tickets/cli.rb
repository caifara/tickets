case ARGV[0]
when "growl"
  OurTickets.read_config
  o = OurTickets.new($queries)
  o.show
when "setup"
  o = OurTickets.setup
else
  OurTickets.read_config
  @o = OurTickets.new($queries)
  @o.show(false)
  @o.start_irb
end
  