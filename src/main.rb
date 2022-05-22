require 'optparse'

# global options
@options = {}

OptionParser.new do |opts|
  # team number
  opts.on("-t", "--team=TEAM", Integer, "Team number to connect to") do |team|
    @options[:team] = team
  end

  # network name
  opts.on("-n", "--name=NAME", String, "Network name excluding team number") do |name|
    @options[:name] = name.strip
  end

  # year for wpilib jdk
  opts.on("-y", "--year=YEAR", Integer, "WPILib version to use JDK from") do |year|
    @options[:year] = year
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

# check which networks match the frc radio name regex
networks.filter! do |network|
  frc_regexp.match?(network) 
end

# exit if no robot network to connect to
if networks.empty?
  puts "No robot network found to connect to."
  exit(2)
end

# prompt user if more than one option is present after regex
if networks.length > 1
  puts "Multiple networks found:\n"
  
  # print out each index and option
  networks.each_index do |index|
    puts "[#{index+1}] #{networks[index]}"
  end

  # get user input
  print "\nEnter index of network to connect to: "
  index = gets.chomp.to_i - 1

  # exit if incorrect index
  if index < 0 || index > networks.length - 1
    puts "Index out of bounds."
    exit(1)
  end
end
