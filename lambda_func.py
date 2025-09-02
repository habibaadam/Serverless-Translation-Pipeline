import boto3
import json
import os

s3 = boto3.client('s3')
translate = boto3.client('translate')

RESPONSE_BUCKET = os.environ.get("RESPONSE_BUCKET", "habi-response-bucket")
DEFAULT_TARGET_LANG = os.environ.get("DEFAULT_TARGET_LANG", "fr")

def lambda_handler(event, context):
    try:
        # 1. Get info about uploaded file
        request_bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']

        # 2. Read JSON file from request bucket
        response = s3.get_object(Bucket=request_bucket, Key=key)
        content = response['Body'].read().decode('utf-8')
        data = json.loads(content)

        # 3. Translate using AWS Translate
        word = data.get("word", "")
        target_lang = data.get("target_language", DEFAULT_TARGET_LANG)
        if word:
            translation = translate.translate_text(
                Text=word,
                SourceLanguageCode="auto",
                TargetLanguageCode=target_lang
            )
            translated_word = translation.get("TranslatedText", "")
        else:
            translated_word = ""

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