import json
import boto3


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



def ${lambda_handler_function}(event, context):

    response = sns_trigger(event)
    
    return response


