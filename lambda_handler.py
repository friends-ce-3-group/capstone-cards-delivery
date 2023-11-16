import json
import boto3


def ${lambda_handler_function}(event, context):

    client = boto3.client('sns')
    
    out = {} 
    out['default'] = json.dumps(event)

    response = client.publish (
        TopicArn = "${sns_topic_arn}",
        Message = json.dumps(out),
        MessageStructure = 'json'
    )
    
    return response