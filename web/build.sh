#!/bin/bash -e
# Building the website for lambda deployment
$ARTIFACTS_DIR=.build-standalone

npm install
npm build

# Copy artifacts for deployment
cp -r .next/standalone/. $ARTIFACTS_DIR
cp run.sh $ARTIFACTS_DIR