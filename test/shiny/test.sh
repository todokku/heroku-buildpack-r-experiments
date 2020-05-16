#!/bin/bash

web_url=$(heroku apps:info -j | jq -r '.app.web_url')
wss_url=${web_url/http/ws}

curl -v ${web_url} -o page.html
curl -v ${web_url}shared/shiny.css -o tmp.css
curl -v ${web_url}shared/shiny.min.js -o tmp.js

# test the websocket
# cat test.json | timeout --signal=INT 5 websocat -v -t ${wss_url}websocket/ --
