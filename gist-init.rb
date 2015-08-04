#!/usr/bin/env ruby

require "io/console"
require "json"
require "net/http"
require "optparse"

if File.exists?(".git") == false or `git log -1`.count("\n") == 0
  STDERR.puts "Please, initialize a Git repository and add some files to a commit"
  exit 1
end

#
# Extract options from command line, and ask missing values

Options = {
  user: nil,
  password: nil,
  description: nil,
  public: false
}

def ask(prompt, echo = true)
  STDOUT.print "#{prompt}: "
  STDOUT.flush
  if echo
    gets.strip
  else
    STDIN.noecho do
      r = gets.strip
      puts
      r
    end
  end
end

OptionParser.new do |opts|
  opts.banner = "Usage: gist-init [options]"

  opts.on("-p", "--public", "Create a public gist") do |v|
    Options[:public] = v
  end

  opts.on("-u", "--user [USER]", "GitHub user name") do |v|
    Options[:user] = v
  end

  opts.on("--password [PASSWORD]", "GitHub password") do |v|
    Options[:password] = v
  end

  opts.on("-d", "--description [DESCRIPTION]", "Gist description") do |v|
    Options[:description] = v
  end

end.parse!

if Options[:user].nil?
  default = `git config --get user.email`.strip
  user = ask("User [#{default}]")
  Options[:user] = user =~ /\S/ ? user : default
end

if Options[:password].nil?
  Options[:password] = ask("Password", false)
end

if Options[:description].nil?
  Options[:description] = ask("Description")
end

#
# Create Gist

response = Net::HTTP.start("api.github.com", 443, use_ssl: true) do |http_client|
  request = Net::HTTP::Post.new("/gists")
  request.basic_auth Options[:user], Options[:password]
  request.content_type = "application/json"
  request.body = {
      description: Options[:description],
      public: Options[:public],
      files: { dummy: { content: "dummy" }}
    }.to_json

  http_client.request(request)
end

if response.code.to_i != 201
  STDERR.puts "Invalid response #{response.code}:\n#{response.body}"
  exit 2
end

response = JSON.parse(response.body)

puts "Gist created: \033[1m#{response["html_url"]}\033[m"

#
# Add the new gist as a new origin. Force SSH

push_url = response["git_push_url"].sub(%r[\Ahttps://(.*?)/], "git@\\1:")
puts "Add \033[1m#{push_url}\033[m as \033[1morigin\033[m remote"
system "git", "remote", "add", "gist", push_url
if not $?.success?
  STDERR.puts "Failed to add remote"
  exit 1
end

exec "git", "push", "-f", "-u", "gist", "master"
