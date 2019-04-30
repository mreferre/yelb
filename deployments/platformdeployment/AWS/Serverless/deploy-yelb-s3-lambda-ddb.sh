#!/bin/bash

# Massimo Re Ferre' massimo@it20.info

# Creating the CF stack
# This CF template deploys prepares the DDB table and deploys the Lambdas w/ the API GW
aws cloudformation create-stack --template-body file://./yelb-lambda-ddb.yaml --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND --stack-name yelb-lambda-ddb --region us-west-2

# Waiting for the CF stack to come on line
aws cloudformation wait stack-create-complete --region us-west-2 --stack-name yelb-lambda-ddb 

# Setting env variables
export apigwid=$(aws apigateway get-rest-apis --region us-west-2 | jq -c '.items[] | select(.name | contains("yelb-lambda-ddb"))' | jq .id --raw-output)
export yelbappendpoint="https://"$apigwid".execute-api.us-west-2.amazonaws.com"

# Creating a temporary directory
mkdir tmp-$apigwid

# Downloading the source web site + customization to point to the CF stack 
aws s3 cp s3://yelb-ui-serverless ./tmp-$apigwid --recursive 
sed -i "s@https://yelb-appserver-endpoint-whatever-that-is.com@$yelbappendpoint@g" ./tmp-$apigwid/env.js 

# Creating the S3 web hosting bucket 
aws s3 mb s3://yelb-ui-$apigwid --region us-west-2
aws s3 website s3://yelb-ui-$apigwid/ --index-document index.html
echo '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Allow Public Access to All Objects",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::'yelb-ui-$apigwid'/*"
    }
  ]
}' > ./tmp-$apigwid/policy.json
aws s3api put-bucket-policy --bucket yelb-ui-$apigwid --policy file://./tmp-$apigwid/policy.json

# Copying the web site to the web hosting bucket
aws s3 cp ./tmp-$apigwid s3://yelb-ui-$apigwid/ --recursive

# Link to the web hosting bucket
echo "///"
echo "You can now connect to http://yelb-ui-"$apigwid".s3-website-us-west-2.amazonaws.com"
echo "///"
