# srch_cli

Command Line Interface for LTI® Resource Search
 
Test various capabilities exposed by IMS Global’s LTI ® Resource Search.
 
Usage: ruby srch_cli.rb <options>

* -i,--id CLIENT_ID - the client ID used to request a token
* -k,--secret CLIENT_SECRET - the client secret to request a token
* -u,--user USER - the user ID (generally email address) of the person requesting
* -b,--base BASE - the base URL to connect to for the /resources endpoint
* -t,--token TOKEN - the token URL to request a token from.  By default its BASE/oauth/get_token
 
Example: 

  ruby srch_cli.rb -i cc18d57bc1ab578fc6003b5feaff5875e86648a59b5341122e5761b45a3e2257 -k 15ace16509692805e280c3d8eda0351d6a323ab9cbd17d1b1239026fb9e622ce  -b "https://resource-api-staging.herokuapp.com" -t "https://partner-staging.opened.com/2/oauth/get_token" -u bluma@act.org -o K.CC.1
 
- adam.blum@act.org

Learning Tools Interoperability® (LTI®) is a trademark of the IMS Global Learning Consortium, Inc. (www.imsglobal.org)



 
