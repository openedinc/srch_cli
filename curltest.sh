curl --request POST \
--url https://oauth2server.imsglobal.org/oauth2server/clienttoken \
--header 'Authorization: Basic YWN0Lm9yZzpoeHN4XDh+J0EmQUUqcC8m' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode 'scope=http://www.imsglobal.org/ltirs' \
--verbose
