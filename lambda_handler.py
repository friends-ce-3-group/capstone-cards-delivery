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
    local_prefix = "/tmp/" # in the lambda filesystem, only this folder is writable

    image_path = s3_prefix + image
    local_path = local_prefix + image

    # notes: 
    # this lambda is in us-east-1, whereas friends-capstone-infra-s3-website is in us-west-2
    # cross-region s3 bucket access works out of the box
    bucket_name = '${s3_image_bucket_name}'

    s3 = boto3.resource('s3')
    bucket = s3.Bucket(bucket_name)
    # for obj in bucket.objects.all():
    #     print(obj.key)

    try:
        bucket.download_file(image_path, local_path)
    except botocore.exceptions.ClientError as err:
        print(str(err))
        

def ${lambda_handler_function}(event, context):

    response = sns_trigger(event)

    s3_bucket_get(event["imagePath"])

    print(os.listdir("/tmp/"))

    return response