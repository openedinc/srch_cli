# SRCH_CLI
# Test IMS Global LTI Resource Search provider
require 'json'
require 'rest_client'
require 'optparse'

def get_token(username,id,secret)
  base=ENV["PARTNER_BASE_URI"]
  oauth_base=base
  p "Base URL: #{oauth_base}"
  url    = "#{base}/oauth/get_token"
  header = {content_type: "application/json"}
  data   = {"username"=>username,"client_id"=>id, "secret"=>secret }
  p "Posting #{data} to #{url}"
  result=RestClient.post url, data.to_json, header
end

id = ENV["CLIENT_ID"]
secret = ENV["CLIENT_SECRET"]
options = {}
criteria=""
OptionParser.new do |opt|
  opt.on('-s','--search SEARCH') { |o|
    options[:search] = o
    criteria= criteria + "search~'"+options[:search]+"'"
  }
  opt.on('-t','--type TYPE') { |o|
    options[:type] = o
    criteria = criteria + " AND learningResourceType='"+options[:type]+"'"
  }
  opt.on('-u','--user USER') { |o|
    options[:user] = o
  }
  opt.on('-p','--publisher PUBLISHER') { |o|
    options[:publisher] = o
    criteria = criteria + " AND publisher='"+options[:publisher]+ "'"
  }

  opt.on('-i','--id CLIENT_ID') { |o|
    options[:id] = o
    id = options[:id]
  }
  opt.on('-k','--secret CLIENT_SECRET') { |o|
    options[:secret] = o
    secret = options[:secret]
  }
end.parse!

p "Options: #{options}"
if options.size == 0
  p "Usage: ruby srch_cli.rb <options> "
  exit
end



url = ENV["PARTNER_BASE_URI"]+ "/resources"
url = url + "?fields=id,ltiLink,url,description,name"  # don't return all the fields
if criteria and criteria.size>0
  url = url + "&filter=" + CGI.escape(criteria)
end
user = "bluma@act.org"
user=options[:user] if options[:user]

result = get_token(user,id,secret)

resp = JSON.parse(result)
token = resp["access_token"]
p "Token: #{token}"

headers = { :content_type => 'application/json', :authorization => "Bearer #{token}"}
p "Hitting URL: #{url}"
response=RestClient.get(url.to_s,headers)
result=JSON.parse(response)
resources=result['resources']
p "Headers returned: #{response.headers.inspect.to_s}"
p "# resources: #{response.headers[:x_total_count]}"
