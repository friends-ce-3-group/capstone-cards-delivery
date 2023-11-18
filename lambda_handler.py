import json
import boto3
import os

def sns_trigger(event):
    client = boto3.client('sns')
    
    out = {} 
    out['default'] = json.dumps(event)

    response = client.publish (
        TopicArn = "${sns_topic_arn}",
        Message = json.dumps(out),
        MessageStructure = 'json'
    )

    return response

def s3_bucket_get():
    s3 = boto3.client('s3')
    
    buckets = s3.list_buckets()

    print(json.dumps(buckets))


def ${lambda_handler_function}(event, context):

    response = sns_trigger(event)

    print(event["recipientName"])
    print(event["recipientEmail"])
    print(event["imagePath"])

    s3_bucket_get()

    return response


