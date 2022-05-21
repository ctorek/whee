require 'optparse'

# global options
@options = {}

OptionParser.new do |opts|
  # verbose
  opts.on("-v", "--verbose", "Show extra info") do
    @options[:verbose] = true
  end

  # team number
  opts.on("-t", "--team=TEAM", Integer, "Team number to connect to") do |team|
    @options[:team] = team
  end

  # network name
  opts.on("-n", "--name=NAME", String, "Network name excluding team number") do |name|
    @options[:name] = name.strip
  end
end.parse!

# regex for network name
network_regexp = Regexp.new('[\d]{3,4}[_\D]*')

puts (@options[:team].to_s + "_" + @options[:name]).match?(network_regexp) 
