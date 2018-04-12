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
  auth="Basic " + base64_url_encode(str)
  p "Auth string #{auth}"
  header = {content_type: "application/json",AUTHORIZATION: auth}
  data = {"client_id"=>id, "secret"=>secret}
  data["username"]=username if username and username.size>0
  puts "Header is #{header}"
  #p "Posting #{data} to #{tokenurl}"
  result=RestClient.post tokenurl, data.to_json, header
end

id = ENV["CLIENT_ID"]
secret = ENV["CLIENT_SECRET"]
user = ENV["CLIENT_USER"]
base=ENV["PARTNER_BASE_URI"]
tokenurl = "#{base}/oauth/get_token"
numresources = 10

options = {}
criteria=""
OptionParser.new do |opt|

  opt.on('-i','--id CLIENT_ID') { |o|
    options[:id] = o
    id = options[:id]
  }
  opt.on('-k','--secret CLIENT_SECRET') { |o|
    options[:secret] = o
    secret = options[:secret]
  }
  opt.on('-u','--user USER') { |o|
    options[:user] = o
    user=options[:user]
  }
  opt.on('-b','--base BASE') { |o|
    options[:base] = o
    base = options[:base]
    tokenurl = "#{base}/oauth/get_token" if options[:token].nil?
  }
  opt.on('-t','--token TOKENURL') { |o|
    options[:token] = o
    tokenurl = options[:token]
  }

  # add various search criteria to filter
  opt.on('-s','--search SEARCH') { |o|
    options[:search] = o
    if criteria.size > 0
      criteria = criteria + " AND "
    end
    criteria= criteria + "search~'"+options[:search]+"'"
  }
  opt.on('-r','--resourcetype TYPE') { |o|
    options[:type] = o
    if criteria.size > 0
      criteria = criteria + " AND "
    end
    criteria = criteria + "learningResourceType='"+options[:type]+"'"
  }
  opt.on('-p','--publisher PUBLISHER') { |o|
    options[:publisher] = o
  }
  opt.on('-o','--objective NAME_OR_GUID_OR_CASEITEMURI') { |o|
    options[:objective] = o
    criteria = criteria
    if criteria.size > 0
      criteria = criteria + " AND "
    end
    if not options[:objective]=~/\s/
      if options[:objective]=~/./ # indicates human readable name
        criteria = criteria + "learningObjectives={['targetName':'" + options[:objective]+ "']}"
      elsif options[:objective]=~/\//  # / indicates URI
        criteria = criteria + "learningObjectives={['caseItemUri':'" + options[:objective]+ "']}"
      else
        criteria = criteria + "learningObjectives={['caseItemGUID':'" + options[:objective]+ "']}"
      end
    else
      p "Learning objectives can't have whitespace"
    end
  }

  # limit or sort results
  opt.on('-n','--number NUMRESOURCES') { |o|
    options[:number] = o
    numresources = options[:numresources]
  }
end.parse!
p "Search criteria: #{criteria}"

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
p "Token: #{token}"

headers = { :content_type => 'application/json', :authorization => "Bearer #{token}"}
p "Hitting URL: #{url}"
response=RestClient.get(url.to_s,headers)
result=JSON.parse(response)
resources=result['resources']
p "# matching resources: #{response.headers[:x_total_count]}"
#p "Name\tDescriptionL\tLTILink\tURL"
for i in (0..numresources) do
  r=resources[i]
  p "#{r['name']}\t#{r['url']}\t#{r['description']}\n"
end
