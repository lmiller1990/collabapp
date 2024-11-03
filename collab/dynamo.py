import boto3
import json

dynamodb = boto3.resource("dynamodb", region_name="ap-southeast-2")
s3 = boto3.client("s3", region_name="ap-southeast-2")
bucket = "collab-documents-qy5z7203"

# Reference your table

table = dynamodb.Table("collab")  # type: ignore


def create_document(s3_key: str, shared_with_emails: str, text: str):
    """
    s3_key: uuid to use as idenitifer in s3
    shared_with_emails: csv of emails
    text: the content of the s3 document
    """

    table.put_item(Item={"id": s3_key, "shared_with": shared_with_emails})

    s3.put_object(
        Bucket=bucket,
        Key=s3_key,
        Body=json.dumps({"text": text}),
        ContentType="application/json",
    )


def fetch_document_by_id(s3_key: str):
    """
    Fetches a record from DynamoDB and associated S3 document
    s3_key maps both to Dynamo row **and** S3 document!
    """
    try:
        response = table.get_item(Key={"id": s3_key})
        item = response.get("Item")
        if not item:
            print(f"No item found with id: {s3_key}")
            return None, None
    except Exception as e:
        print(f"Error fetching from DynamoDB: {e}")
        return None, None

    try:
        s3_response = s3.get_object(Bucket=bucket, Key=s3_key)
        s3_content = s3_response["Body"].read().decode("utf-8")
    except Exception as e:
        print(f"Error fetching from S3: {e}")
        return item, None

    return item, s3_content
