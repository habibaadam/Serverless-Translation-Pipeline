terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.region
}


resource "aws_s3_bucket" "request" {
  bucket = var.request_bucket_name
}

resource "aws_s3_bucket" "response" {
  bucket = var.response_bucket_name
}

resource "aws_s3_bucket_lifecycle_configuration" "request_lifecycle" {
  bucket = aws_s3_bucket.request.id

  rule {
    id     = "expire-objects"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "response_lifecycle" {
  bucket = aws_s3_bucket.response.id

  rule {
    id     = "expire-objects"
    status = "Enabled"

    filter {}

    expiration {
      days = var.lifecycle_expiration_days
    }
  }
}


resource "aws_iam_role" "lambda_role" {
  name = "habi-translate-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.request.arn,
          "${aws_s3_bucket.request.arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.response.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["translate:TranslateText"]
        Resource = "*"
      },
       {
        Effect   = "Allow"
        Action   = [
          "translate:TranslateText",
          "comprehend:DetectDominantLanguage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}


data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_func.py"
  output_path = "${path.module}/lambda_func.zip"
}

resource "aws_lambda_function" "translate" {
  function_name = "habi-translate-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_func.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 256
  timeout       = 60
  filename      = data.archive_file.lambda_zip.output_path

  environment {
    variables = {
      RESPONSE_BUCKET     = aws_s3_bucket.response.bucket
      DEFAULT_TARGET_LANG = var.default_target_lang
    }
  }
}


resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.translate.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.request.arn
}

resource "aws_s3_bucket_notification" "request_trigger" {
  bucket = aws_s3_bucket.request.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.translate.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
