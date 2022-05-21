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

# output of netsh
networks = %x(netsh wlan show networks).lines.filter do |line|
  # check if line is a network ssid
  line.start_with?(/SSID [\d]+/)
end.collect do |line|
  # remove start from string
  line.strip.gsub(/SSID [\d]+ : /, "")
end

# netsh exit code
error = %x(echo %errorlevel%).strip.to_i

# exit if netsh fails
if error != 0
  puts "Netsh failed with a non-zero exit code."
  exit(1)
end

# team and name are set by options if present otherwise default regex
team = (@options[:team].nil?) ? '^[\d]{3,4}' : "^(#{@options[:team].to_s[0..3]})"
name = (@options[:name].nil?) ? '[\w]*$' : "_(#{@options[:name]})$"

frc_regexp = Regexp.new(team + name)
