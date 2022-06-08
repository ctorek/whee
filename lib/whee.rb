require 'colorize'
require 'optparse'

class Main
  # global options
  @@options = {
    :team => nil,
    :name => nil,
    :year => nil,
    :connect => false,
    :build => false
  }

  def parse_options
    OptionParser.new do |opts|
      # team number
      opts.on("-t", "--team=TEAM", Integer, "Team number to connect to")
    
      # network name
      opts.on("-n", "--name=NAME", String, "Network name excluding team number")
    
      # year for wpilib jdk
      opts.on("-y", "--year=YEAR", Integer, "WPILib version to use JDK from")

      # only connect to robot
      opts.on("-c", "--connect", "Only connect and not deploy")

      # build instead of deploy
      opts.on("-b", "--build", "Only build and not deploy")
    end.parse!(into: @@options)
  end

  # checks whether current directory is a wpilib project
  def wpilib_proj? 
    File.exist?(".\\.wpilib\\wpilib_preferences.json")
  end

  # sets default options based on ./.wpilib/wpilib_preferences.json
  def wpilib_pref
    require 'json'
    
    # no error checking because this method is only called after `wpilib_proj?`
    preferences = JSON.parse(File.read(".\\.wpilib\\wpilib_preferences.json"))

    @@options[:year] = preferences["projectYear"]
    @@options[:team] = preferences["teamNumber"]
  end

  # refresh list of networks available
  def netsh_refresh
    # disconnect from current to force refresh
    %x(netsh wlan disconnect)
    
    # sleep until refresh
    sleep 3
  end

  def run
    # ensure wpilib project
    if !wpilib_proj?
      STDERR.puts "File '.\\.wpilib\\wpilib_preferences.json' not found.".colorize(:light_red)
      exit(1)
    else
      # set options from wpilib proj
      wpilib_pref 
    end

    # run command line options parser
    parse_options

    # store current network before disconnect from refresh
    prev_ssids = %x(netsh wlan show interface).lines.collect do |line|
      # remove extra whitespace from each line
      line.gsub(/[\s]+/, " ").strip
    end.filter do |line|
      # find current ssid
      line.start_with?(/SSID/)
    end
    
    # remove start from string
    prev_ssid = (prev_ssids[0] || "").gsub(/(SSID : )/, "")

    # refresh list of networks
    netsh_refresh

    # output of netsh
    networks = %x(netsh wlan show networks).lines.filter do |line|
      # check if line is a network ssid
      line.start_with?(/SSID [\d]+/)
    end.collect do |line|
      # remove start from string
      line.strip.gsub(/SSID [\d]+ : /, "")
    end

    # exit if netsh fails
    if $?.success?
      STDERR.puts "Netsh failed with a non-zero exit code.".colorize(:light_red)
      exit(1)
    end

    # team and name are set by options if present otherwise default regex
    team = (@@options[:team].nil?) ? '^[\d]{3,4}' : "^(#{@@options[:team].to_s[0..3]})"
    name = (@@options[:name].nil?) ? '[\w]*$' : "_(#{@@options[:name].strip})$"
    frc_regexp = Regexp.new(team + name)

    # check which networks match the frc radio name regex
    networks.filter! do |network|
      frc_regexp.match?(network) 
    end

    # exit if no robot network to connect to
    if networks.empty?
      STDERR.puts "No robot network found to connect to.".colorize(:light_red)

      # reconnect to previous network
      if !prev_ssids.empty?
        # only reconnect if previously connected
        %x(netsh wlan connect ssid=#{prev_ssid} name=#{prev_ssid})
      end
      exit(1)
    end

    # index of desired network
    index = 0

    # prompt user if more than one option is present after regex
    if networks.length > 1
      puts "Multiple networks found:\n".colorize(:light_blue)
      
      # print out each index and option
      networks.each_index do |index|
        puts "[#{index+1}] #{networks[index]}"
      end

      # get user input
      print "\nEnter index of network to connect to: "
      index = gets.chomp.to_i - 1

      # exit if incorrect index
      if index < 0 || index > networks.length - 1
        STDERR.puts "Index out of bounds.".colorize(:light_red)
        exit(1)
      end
    end

    # connect to the desired network
    %x(netsh wlan connect ssid=#{networks[index]} name=#{networks[index]})

    if $?.success?
      puts "Successfully connected to robot network.".colorize(:light_green)

      # exit if connect-only mode is set
      if @@options[:connect]
        exit(0)
      end
    else
      STDERR.puts "Failed to connect to robot network.".colorize(:light_red)
      exit(1)
    end

    # year for jdk location
    year = @@options[:year] || Time.now.year.to_s
    dir = "C:\\Users\\Public\\wpilib\\#{year}\\jdk"

    # check if jdk exists
    if !Dir.exists?(dir)
      STDERR.puts "Invalid year provided. JDK not found.".colorize(:light_red)
      exit(1)
    end

    # set gradle wrapper java home
    ENV['JAVA_HOME'] = dir
    
    # run gradle deploy
    begin
      deploy = %x(gradlew.bat #{@@options[:build] ? "build" : "deploy"})
    rescue Errno::ENOENT
      # rescue and exit if gradle wrapper isn't found
      STDERR.puts "Gradle wrapper not found. Make sure this is a WPILib project directory.".colorize(:light_red)
      exit(1)
    end

    # deploy or build
    mode = @@options[:build] ? "Build" : "Deploy"
   
    # check if deploy failed
    if $?.success?
      STDERR.puts "#{mode} failed. Error below:".colorize(:light_red)
      puts deploy
      exit(1)
    end

    # successful deploy
    puts "#{mode} successful.".colorize(:light_green)
  end
end
