#!/bin/bash

web_url=$(heroku apps:info -j | jq -r '.app.web_url')

curl -v "${web_url}echo?msg=Hello%20World!"
curl -v -d "a=10" -d "b=2" ${web_url}sum
curl -v ${web_url}plot -o plot.png
