import boto3
import json


# Lambda Handler
def lambda_handler(event, context): 
    print("Executing lambda_handler function")
    print("lambda_handler - event => ", event)
    print("lambda_handler - context => ", context)

    return get_response(200)

def get_response(status_code, result=""):
    print("Executing get_response({}) function".format(status_code))

    body = {}
    body["code"] = status_code

    if status_code == 200:
        body["result"] = result
    elif status_code == 400:
        body["result"] = "Bad Request. {}".format(result)
    elif status_code == 404:
        body["result"] = "Not Found"
    elif status_code == 500:
        body["result"] = result

    response = {}
    response["statusCode"] = status_code
    response["isBase64Encoded"] = False
    headers = {}
    headers["Content-Type"] = "application/json"
    headers["Access-Control-Allow-Origin"] = "*"
    response["headers"] = headers
    response["body"] = json.dumps(body, default=str)

    return response