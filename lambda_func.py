import boto3
import json

s3 = boto3.client('s3')
# Change this to your actual response bucket name
RESPONSE_BUCKET = "habi-response-bucket"

def lambda_handler(event, context):
    try:
        # 1. Get info about uploaded file
        request_bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']

        # 2. Read JSON file from request bucket
        response = s3.get_object(Bucket=request_bucket, Key=key)
        content = response['Body'].read().decode('utf-8')
        data = json.loads(content)

        # 3. Do "translation" (replace with real logic)
        word = data.get("word", "")
        translated_word = f"{word} (translated to Twi)"
        result = {
            "original": word,
            "translated": translated_word
            }
        # 4. Save result into response bucket
        output_key = key.replace(".json", "_translated.json")

        s3.put_object(
            Bucket=RESPONSE_BUCKET,
            Key=output_key,
            Body=json.dumps(result),
            ContentType="application/json"
            )
        print(f"Processed {key} and saved result to {output_key} in {RESPONSE_BUCKET}")
        return {"status": "success", "output_file": output_key}
    except Exception as e:
        print(f"Error: {str(e)}")
        return {"status": "error", "message": str(e)}