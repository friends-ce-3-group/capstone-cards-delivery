import json
import boto3
import botocore
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

def s3_bucket_get(image):
    s3_prefix = "originals/"
    local_prefix = "tmp/"

    image_path = s3_prefix + image
    local_path = local_prefix + image

    s3 = boto3.resource('s3')
    bucket = s3.Bucket('${s3_image_bucket_name}')
    for obj in bucket.objects.all():
        print(obj.key)

    print(":")
    print(":")
    print(":")
    print("Trying to dl:")
    
    try:
        s3.Bucket('${s3_image_bucket_name}').download_file(image_path, local_path)
    except botocore.exceptions.ClientError as err:
        print(str(err))
        

def ${lambda_handler_function}(event, context):

    response = sns_trigger(event)

    print("recipientName:", event["recipientName"], "\n")
    print("recipientEmail", event["recipientEmail"], "\n")
    print("imagePath:" , event["imagePath"], "\n")
    print(":")
    print(":")
    print(":")

    s3_bucket_get(event["imagePath"])

    return response