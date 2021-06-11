import os

def lambda_handler(event, context):
    print("Greetings from Lambda!")

    return {
        "statusCode": 200
    }