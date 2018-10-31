# SRCH_CLI
# Test IMS Global LTI Resource Search provider
require 'json'
require 'rest_client'
require 'optparse'
require 'base64'
require 'uri'

def base64_url_encode(str)
  Base64.encode64(str).tr('+/', '-_').gsub(/\s/, '')#.gsub(/=+\z/, '')
end

def get_token(username,id,secret,tokenurl=nil,authorization=nil,form_encoded=nil)
  if authorization.nil?
    str = "#{id}:#{secret}"
    auth="Basic " + base64_url_encode(str)
    p "Auth string #{auth}"
  else
    auth="Basic " + authorization
  end
  if form_encoded
    # handle the way IMS conformance server expects form encoded data
    header = {"Content-Type"=> "application/x-www-form-urlencoded","Authorization"=>auth}
    # this is also technically valid OAuth: put into body
    data = {grant_type: "client_credentials",scope: "http://www.imsglobal.org/ltirs"}
    # they dont seem to want user name?
    # data["username"]=username if username and username.size>0
    encoded=URI.encode_www_form(data)
  else
    header = {content_type: "application/json",AUTHORIZATION: auth}
    # this is also technically valid OAuth: put into body
    data = {}
    data["username"]= username if username and username.size>0
    encoded=data.to_json
  end
  puts "Header is #{header}"
  p "Posting encoded #{encoded} to #{tokenurl}"
  result=RestClient.post tokenurl, encoded, header
end

id = ENV["CLIENT_ID"]
secret = ENV["CLIENT_SECRET"]
auth = nil
user = nil
form_encoded = nil
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
  opt.on('-a','--auth AUTHORIZATION') { |o|
    options[:auth] = o
    auth = options[:auth]
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
    p "Token URL #{tokenurl}"
  }
  opt.on('-f','--form') { |o|
    options[:form] = o
    form_encoded = options[:form]
    p "Form encoded #{form_encoded}"
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
    criteria = criteria + "publisher='"+options[:type]+"'"

  }
  opt.on('-o','--objective NAME_OR_GUID_OR_CASEITEMURI') { |o|
    options[:objective] = o
    criteria = criteria
    if criteria.size > 0
      criteria = criteria + " AND "
    end
    if not options[:objective]=~/\s/
      if options[:objective]=~/\//  # / indicates URI
        criteria = criteria + "learningObjectives.caseItemUri='" + options[:objective] + "'"
      elsif options[:objective]=~/\./ # indicates human readable name
        criteria = criteria + "learningObjectives.targetName='" + options[:objective] + "'"
      else
        criteria = criteria + "learningObjectives.caseItemGUID='" + options[:objective] + "'"
      end
    else
      p "Learning objectives can't have whitespace"
    end
  }
  opt.on('-x','--expand_objectives CASEPROVIDERURL') { |o|
    if criteria.size > 0
      criteria = criteria + " AND "
    end
    options[:expand]=o
    criteria = criteria + "extensions.expandObjectives':'"+ options[:expand] +"'"
  }
  opt.on('-z','--sort FIELD') { |o|
    options[:sort]=o
  }
  opt.on('-l','--subjects') { |o|
    options[:subjects]=o
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

result = get_token(user,id,secret,tokenurl,auth,form_encoded)
resp = JSON.parse(result)
token = resp["access_token"]
p "Token: #{token}"

headers = { :content_type => 'application/json', :authorization => "Bearer #{token}"}

if options[:subjects]
  url = base + "/ims/rs/v1p0/subjects"
else # search
  url = base + "/ims/rs/v1p0/resources"
  url = url + "?fields=id,ltiLink,url,description,name"  # don't return all the fields
  url = url + "&sort="+ options[:sort] + "&orderBy=asc" if options[:sort]
  if criteria and criteria.size>0
    url = url + "&filter=" + CGI.escape(criteria)
  end
end
p "Hitting URL: #{url}"

response=RestClient.get(url.to_s,headers)
result=JSON.parse(response)
if options[:subjects]
  p "# matching subjects: #{numresources}"
  for i in 0...numresources do
    subjects=result['subjects']
    s=subjects[i]
    p "#{s}" if s
  end
else
  resources=result['resources']
  numresources=response.headers[:x_total_count].to_i
  p "# matching resources: #{numresources}"
  p "Name,Description,LTILink,URL"
  for i in 0...numresources do
    r=resources[i]
    p "#{r['name']}\t#{r['url']}\t#{r['description']}\n" if r
  end
end
