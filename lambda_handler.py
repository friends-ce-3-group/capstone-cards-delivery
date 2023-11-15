import json
import boto3

def process_raw_query(qstr):
    qstr = [i for i in qstr.split("&")]
    qdict = {}
    for q in qstr:
        vars = q.split("=")
        qdict[vars[0]]=vars[1]
    return qdict

def ${lambda_handler_function}(event, context):

    inputs = process_raw_query(event["rawQueryString"])
    inputs["Lambda function ARN"] = context.invoked_function_arn
    inputs["CloudWatch log group name"] = context.log_group_name

    client = boto3.client('sns')
    
    response = client.publish (
        TopicArn = "${sns_topic_arn}",
        Message = json.dumps({'default': inputs}),
        MessageStructure = 'json'
    )
    
    json_response = {
        'statusCode': 200,
        'body': json.dumps(inputs)
    }

    return json_response