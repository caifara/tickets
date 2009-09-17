case ARGV[0]
when "growl"
  o = OurTickets.new($queries)
  o.show
when "setup"
  o = OurTickets.setup
else
  @o = OurTickets.new($queries)
  @o.show(false)
  @o.start_irb
end
  