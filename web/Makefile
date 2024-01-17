AWS_PROFILE=letsremote
ARTIFACTS_DIR=.build-standalone
REGION=eu-central-1
S3_BUCKET=letsremote-dev-web-website-assets
ASSETS_PREFIX=https://$(S3_BUCKET).s3.$(REGION).amazonaws.com

install:
	npm install

build:
	ASSETS_PREFIX=$(ASSETS_PREFIX) npm run build
	cp -r public/. .next/standalone/public
	cp -r .next/standalone/. $(ARTIFACTS_DIR)
	cp run.sh $(ARTIFACTS_DIR)

upload:
	make upload-assets

build-and-upload:
	make build
	make upload

upload-assets:
	aws --profile $(AWS_PROFILE) s3 cp ./.next/static s3://${S3_BUCKET}/_next/static --recursive
	aws --profile $(AWS_PROFILE) s3 cp ./public s3://${S3_BUCKET}/_next/public --recursive