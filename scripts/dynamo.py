import boto3

dynamodb = boto3.resource("dynamodb", region_name="ap-southeast-2")
# Reference your table

table = dynamodb.Table("collab")  # type: ignore


def add_item(s3_key, shared_with_emails):
    # Convert the list of emails to a CSV string
    shared_with_csv = ",".join(shared_with_emails)

    # Put item in table
    response = table.put_item(Item={"id": s3_key, "shared_with": shared_with_csv})
    return response


# Example usage
s3_key = "example-s3-key"
shared_with_emails = ["email1@example.com", "email2@example.com"]
response = add_item(s3_key, shared_with_emails)

print("PutItem succeeded:")
print(response)
