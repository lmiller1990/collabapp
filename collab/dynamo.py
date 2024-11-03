import boto3
import json

dynamodb = boto3.resource("dynamodb", region_name="ap-southeast-2")
s3 = boto3.client("s3", region_name="ap-southeast-2")
bucket = "collab-documents-qy5z7203"

# Reference your table

table = dynamodb.Table("collab")  # type: ignore


def create_document(s3_key: str, shared_with_emails: str, text_content: str):
    # Convert the list of emails to a CSV string
    shared_with_csv = ",".join(shared_with_emails)

    # Put item in table
    table.put_item(Item={"id": s3_key, "shared_with": shared_with_csv})

    # Convert text_content to JSON and upload to S3
    s3.put_object(
        Bucket=bucket,
        Key=s3_key,
        Body=json.dumps(text_content),
        ContentType="application/json",
    )
