# SRCH_CLI
# Test IMS Global LTI Resource Search provider
require 'json'
require 'rest_client'
require 'optparse'
require 'base64'

def base64_url_encode(str)
  Base64.encode64(str).tr('+/', '-_').gsub(/\s/, '')#.gsub(/=+\z/, '')
end


def get_token(username,id,secret,tokenurl=nil)
  str = "#{id}:#{secret}"
  #str = 'MTE5NDg5OTM3ODgxNjU3MTdVT180MzI2OmM2MTU4NmQyNDk4NTI2NjY3MzViY2FjZDA5YmQwNjE3ZTIyMzQxM2E3ZDBlNjg1NzYzOGU4ZTk2ZGIxMGZjYmI='
  auth="Basic " + base64_url_encode(str)
  header = {"AUTHORIZATION"=> auth,"grant_type"=>"client_credentials"}

  p "My auth string #{auth}"
  vk="Basic MTE5NDg5OTM3ODgxNjU3MTdVT180MzI2OmM2MTU4NmQyNDk4NTI2NjY3MzViY2FjZDA5YmQwNjE3ZTIyMzQxM2E3ZDBlNjg1NzYzOGU4ZTk2ZGIxMGZjYmI="
  p "VK auth string #{vk}"
  #data   = {"client_id"=>id, "secret"=>secret,"AUTHORIZATION"=>auth ,"grant_type"=>"client_credentials"}
  #data["username"]=username if username and username.size>0
  #p "Posting #{data} to #{tokenurl}"
  puts "header is #{header}"
  result=RestClient.post tokenurl, data.to_json, header

end

id = ENV["CLIENT_ID"]
secret = ENV["CLIENT_SECRET"]
user = ENV["CLIENT_USER"]
base=ENV["PARTNER_BASE_URI"]
tokenurl = "#{base}/oauth/get_token"

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
    user=options[:user]
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
  opt.on('-b','--base BASE') { |o|
    options[:base] = o
    base = options[:base]
  }
  opt.on('-t','--token TOKENURL') { |o|
    options[:token] = o
    base = options[:token]
    tokenurl = options[:token]
  }
end.parse!

p "Options: #{options}"
if options.size == 0
  p "Usage: ruby srch_cli.rb <options> "
  exit
end

url = base + "/ims/rs/v1p0/resources"
url = url + "?fields=id,ltiLink,url,description,name"  # don't return all the fields
if criteria and criteria.size>0
  url = url + "&filter=" + CGI.escape(criteria)
end

result = get_token(user,id,secret,tokenurl)
resp = JSON.parse(result)
token = resp["access_token"]
#token="9243e801-a10e-499e-ab01-ea5316b6b4f1"
p "Token: #{token}"

headers = { :content_type => 'application/json', :authorization => "Bearer #{token}"}
p "Hitting URL: #{url}"
response=RestClient.get(url.to_s,headers)
result=JSON.parse(response)
resources=result['resources']
p "Headers returned: #{response.headers.inspect.to_s}"
p "# resources: #{response.headers[:x_total_count]}"
