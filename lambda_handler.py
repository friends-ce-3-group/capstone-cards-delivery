import json
import boto3


def ${lambda_handler_function}(event, context):

    inputs = json.loads(event['body'])
    inputs["Lambda function ARN"] = context.invoked_function_arn
    inputs["CloudWatch log group name"] = context.log_group_name

    client = boto3.client('sns')
    
    response = client.publish (
        TopicArn = "${sns_topic_arn}",
        Message = json.dumps({'default': inputs}),
        MessageStructure = 'json'
    )
    
    return response