# SRCH_CLI
# Test IMS Global LTI Resource Search provider
require "json"
require "rest_client"

def get_token(username)
  base=ENV["PARTNER_BASE_URI"]
  oauth_base=base
  p "Fixed base #{oauth_base}"
  url    = "#{base}/oauth/get_token"
  header = {content_type: "application/json"}
  data   = {"username"=>username,"client_id"=>ENV["CLIENT_ID"], "secret"=>ENV["CLIENT_SECRET"] }
  result=RestClient.post url, data.to_json, header
end

url= ENV["PARTNER_BASE_URI"]+ "/resources"
client_id="cc18d57bc1ab578fc6003b5feaff5875e86648a59b5341122e5761b45a3e2257"
secret="15ace16509692805e280c3d8eda0351d6a323ab9cbd17d1b1239026fb9e622ce"

user = "bluma@act.org"
result = get_token(user)
resp = JSON.parse(result)
token = resp["access_token"]

p "Token: #{token}"

headers = { :content_type => 'application/json', :authorization => "Bearer #{token}"}
p "Hitting #{url}"
response=RestClient.get(url.to_s,headers)
result=JSON.parse(response)
resources=result['resources']
p "# resources: #{resources.size}"
