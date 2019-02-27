# srch_cli

Command Line Interface for LTI® Resource Search
 
Test various capabilities exposed by IMS Global’s LTI ® Resource Search.  While this can be a useful tool in its own right,
the primary purpose of SRCH_CLI is to show the LTI Resource Search API can be used against multiple compliant 
LTI Resource Search Providers.  Please write to adam.blum@act.org with pull requests, questions and suggestions.  

Currently the LTI Resource Search spec is not yet published. While in this state please send me requests for access
to the Open API specification.

Usage: ruby srch_cli.rb 

Options:

* -i,--id CLIENT_ID - the client ID used to request a token
* -k,--secret CLIENT_SECRET - the client secret to request a token
* -a - full authorization token (not necessary if ID:secret are used separately)
* -u,--user USER - the user ID (generally email address) of the person requesting
* -b,--base BASE - the base URL to connect to for the /resources endpoint
* -t,--token TOKEN - the token URL to request a token from.  By default its BASE/oauth/get_token
* -f - form encoded payload for OAuth (required by IMS conformance systems)
* -s,--search SEARCH - search name (title), subject and description for specified keyword(s)
* -r,--search RESOURCETYPE - limit to specified resource types. See the IMS LTI Resource Search spec for valid types. 
* -p,--publisher PUBLISHER - limit to specified publisher
* -o,--objective NAME_OR_GUID_OR_CASEITEMURI - the human readable name or caseItemGUID or caseItemUri of the learning objective
* -n,--number NUMRESOURCES - the number of resources to return
 
Example: 

```
ruby srch_cli.rb -i cc18d57bc1ab578fc6003b5feaff5875e86648a59b5341122e5761b45a3e2257 
  -k 15ace16509692805e280c3d8eda0351d6a323ab9cbd17d1b1239026fb9e622ce  -b "https://resource-api-staging.herokuapp.com" 
  -t "https://partner-staging.opened.com/2/oauth/get_token" -u bluma@act.org -o K.CC.1 
```
 
[Adam Blum](mailto:adam.blum@act.org)

Learning Tools Interoperability® (LTI®) is a trademark of the IMS Global Learning Consortium, Inc. (www.imsglobal.org)



 
