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
    #s3 = boto3.client("s3")
    
    #for bucket in s3.list_buckets()["Buckets"]:
    #    print(bucket["Name"])

    s3res = boto3.resource('s3')
    bucket = s3res.Bucket('friends-capstone-infra-s3-images')
    for obj in bucket.objects.all():
        print(obj.key)
        

def friends_capstone_notification_lambda(event, context):

    response = sns_trigger(event)

    #print(event["recipientName"])
    #print(event["recipientEmail"])
    #print(event["imagePath"])

    s3_bucket_get()

    return response