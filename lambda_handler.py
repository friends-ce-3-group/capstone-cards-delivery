import boto3
import botocore
import os
import pathlib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
from botocore.exceptions import ClientError

CONST_IMAGE_SRC_PREFIX = "resized/" # the prefix path in the S3 bucket for all the images to be sent
CONST_TARGET_PATH_PREFIX = "/tmp/" # in the lambda filesystem, only this folder is writable
CONST_SENDER_EMAIL = "gooodgreets@gmail.com"

# def sns_trigger(event):
#     client = boto3.client('sns')
    
#     out = {} 
#     out['default'] = json.dumps(event)

#     response = client.publish (
#         TopicArn = "${sns_topic_arn}",
#         Message = json.dumps(out),
#         MessageStructure = 'json'
#     )

#     return response

def s3_bucket_get(image):
    image_path = CONST_IMAGE_SRC_PREFIX + image
    local_path = CONST_TARGET_PATH_PREFIX + image

    # notes: 
    # this lambda is in us-east-1, whereas friends-capstone-infra-s3-website is in us-west-2
    # cross-region s3 bucket access works out of the box

    bucket_name = '${s3_image_bucket_name}'

    s3 = boto3.resource('s3')
    bucket = s3.Bucket(bucket_name)
    for obj in bucket.objects.all():
        print(obj.key)
    
    try:
        bucket.download_file(image_path, local_path)
        return True, None
    except botocore.exceptions.ClientError as err:
        return False, str(err)
        

def send_email(recipient_email):
    ses = boto3.client('ses')
    response = ses.send_email(
        Source=CONST_SENDER_EMAIL,
        Destination={'ToAddresses': [recipient_email]},
        Message={
            'Subject': {'Data': "Hello"},
            'Body': {'Text': {'Data': "There is a card for you"}}
        }
    )
    print("Email sent! Message ID:", response['MessageId'])

    return response

def send_email_with_attachment(receipient_email):
    ses = boto3.client('ses')

    msg = MIMEMultipart()
    msg['Subject'] = "Hello"
    msg['From'] = CONST_SENDER_EMAIL
    msg['To'] = receipient_email
    msg.attach(MIMEText("There is a card for you"))

    # Attach the file
    attachment_filename = os.listdir(CONST_TARGET_PATH_PREFIX)[0]  # Replace with the actual filename
    with open(pathlib.Path(CONST_TARGET_PATH_PREFIX) / attachment_filename, 'rb') as attachment_file:
        attachment = MIMEApplication(attachment_file.read(), Name=attachment_filename)

    attachment['Content-Disposition'] = f'attachment; filename="{attachment_filename}"'
    msg.attach(attachment)

    try:
        response = ses.send_raw_email(
            Source=CONST_SENDER_EMAIL,
            Destinations=[receipient_email],
            RawMessage={'Data': msg.as_string()}
        )
        print("Email sent! Message ID:", response['MessageId'])

        return response

    except ClientError as e:
        print("Error sending email:", e)
        return str(e)


def friends_capstone_notification_lambda(event, context):

    # response = sns_trigger(event)

    print("recipientName:", event["recipientName"], "\n")
    print("recipientEmail", event["recipientEmail"], "\n")
    print("imagePath:" , event["imagePath"], "\n")
    
    print("---------------------------------------------------------")

    success, msg = s3_bucket_get(event["imagePath"])
    print(os.listdir(CONST_TARGET_PATH_PREFIX))

    print("---------------------------------------------------------")

    if success:
    
        print("Triggering SES")
        response = send_email_with_attachment(event["recipientEmail"])
        return response
    
    else:
        return msg