#!/usr/bin/env bash

echo "${PWD} as the current folder"

# Common variables
S3_BUCKET_NAME = "test-bucket"
DYNAMO_TABLE_NAME="test-table"
KINESIS_STREAM_NAME="__ddb_stream_${DYNAMO_TABLE_NAME}" # auto generated

# Create S3 bucket first
awslocal s3api create-bucket --bucket ${S3_BUCKET_NAME}

# Create DynamoDB + DynamoDb stream (has a KDS on that)
awslocal dynamodb create-table \
    --table-name ${DYNAMO_TABLE_NAME} \
    --key-schema AttributeName=id,KeyType=HASH \
    --attribute-definitions AttributeName=id,AttributeType=S \
    # --region ap-southeast-1 \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --stream-specification StreamEnabled=true,StreamViewType=NEW_AND_OLD_IMAGES


# Create firehose
awslocal firehose create-delivery-stream \
  --delivery-stream-name ${KINESIS_STREAM_NAME}\
  --delivery-stream-type KinesisStreamAsSource \
  --kinesis-stream-source-configuration "KinesisStreamARN=arn:aws:kinesis:us-east-1:000000000000:stream/__ddb_stream_test-table,RoleARN=arn:aws:iam::000000000000:role/Firehose-Reader-Role"

echo "Done creating resources!!!"
