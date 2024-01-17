include .env
export

ARTIFACTS_DIR=build
DEPLOYMENT_ZIP_PATH=deployment.zip

S3_BUCKET=letsremote-$(NODE_ENV)-web-website-assets
ASSETS_PREFIX=https://$(S3_BUCKET).s3.$(AWS_REGION).amazonaws.com
LAMBDA_NAME=letsremote-$(NODE_ENV)-web-website
LAMBDA_ARN=arn:aws:lambda:$(AWS_REGION):$(AWS_ACCOUNT_ID):function:$(LAMBDA_NAME)

install:
	npm install

build:
	echo "Building for $(NODE_ENV)"
	npm run build
	cp -r public/. .next/standalone/public
	cp -r .next/standalone/. $(ARTIFACTS_DIR)
	cp run.sh $(ARTIFACTS_DIR)

deploy-assets:
	echo "deploying assets to $(S3_BUCKET)"
	aws --profile $(AWS_PROFILE) s3 cp ./.next/static s3://${S3_BUCKET}/_next/static --recursive
	aws --profile $(AWS_PROFILE) s3 cp ./public s3://${S3_BUCKET}/_next/public --recursive

clean:
	rm -rf $(ARTIFACTS_DIR)
	rm -rf $(DEPLOYMENT_ZIP_PATH)

zip:
	cd ./$(ARTIFACTS_DIR) && zip -r ../$(DEPLOYMENT_ZIP_PATH) .

deploy-lambda:
	make zip
	aws lambda update-function-code --function-name $(LAMBDA_ARN) --zip-file fileb://$(DEPLOYMENT_ZIP_PATH) --region=$(AWS_REGION)

deploy:
	make deploy-assets
	make deploy-lambda

build-and-deploy:
	make clean
	make build
	make deploy