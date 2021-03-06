#!/bin/bash

set -e
# set -x # debug

HEROKU_STACK=${1:-18}
BRANCH=${2:-heroku-18}

topic() {
  echo "-----> $*"
}

indent() {
  sed -u 's/^/       /'
}

topic "Running $(basename $(pwd)) test..."

# create a temporary directory and copy the test application
dir=$(mktemp -d)

# copy test sources
cp -r . $dir > /dev/null
pushd $dir > /dev/null

echo $(pwd) | indent

# commit to git for push to heroku
git init > /dev/null
git config user.name "Test"
git config user.email "test@example.com"
echo "*.log" >> .gitignore
git add --all
git commit -m "initial" --no-gpg-sign > /dev/null

# create the app with shell buildpack
heroku create --stack heroku-${HEROKU_STACK} \
              --buildpack https://github.com/virtualstaticvoid/heroku-buildpack-r-experiments.git#${BRANCH} 2>&1 | indent

# get app name (so it can be destroyed)
app=$(heroku apps:info -j | jq -r '.app.name')

# uncomment for debugging
# heroku config:set BUILDPACK_DEBUG=1

# test the deployment
topic "Deploying test"
git push heroku master 2>&1 | indent

# wait for release to complete
heroku ps:wait --wait-interval=20 2>&1 | indent

# R test?
if [ -f "test.R" ]; then
  topic "Running 'test.R'..."
  heroku run R --no-save --file=test.R 2>&1 | indent
fi

# shell test?
if [ -f "test.sh" ]; then
  topic "Running 'test.sh'..."
  bash test.sh 2>&1 | indent
fi

topic "Test completed. Check outputs for any errors."

# clean up
heroku destroy $app --confirm $app > /dev/null

popd &> /dev/null
rm -rf $dir
