# Serverless Translation Pipeline

## Overview

This project demonstrates an Infrastructure-as-Code (IaC) solution on AWS using Terraform, integrating AWS Translate for automated language translation and Amazon S3 for object storage. The solution leverages Python and Boto3 to process translation requests from JSON files, storing both the input and translated output in S3 buckets. The architecture is designed to be fully serverless or use minimal EC2 resources, with a focus on Free Tier compliance.

## Objectives

- **Serverless NLP/NLU Solution:** Deploy a real-time or batch translation system using AWS Translate.
- **Secure Data Storage:** Organize and store data in Amazon S3 buckets with lifecycle policies.
- **Free Tier Compliance:** Ensure infrastructure remains within AWS Free Tier limits.

## Architecture

- **Amazon S3:** Two buckets (`request-bucket` for input files, `response-bucket` for translated output).
- **AWS IAM:** Custom roles and policies for secure access to S3 and Translate.
- **AWS Lambda:** Python function triggered by S3 events to automate translation.
- **Terraform:** IaC scripts to provision and manage AWS resources.

## Phased Milestones

### Phase 1: Initial Setup & AWS Resource Configuration

- Research AWS Translate and S3 capabilities.
- Provision S3 buckets with lifecycle policies.
- Create IAM role with Translate and S3 access.
- Validate stack with test deployment and teardown.

**Tools:** AWS Console/CLI, Terraform, IAM
**Free Tier:** S3 (5 GB), IAM (always free)

### Phase 2: Infrastructure-as-Code (IaC) Design

- Write Terraform scripts to automate resource provisioning.
- Ensure resources are secure and compliant with Free Tier.

**Tools:** Terraform, AWS IAM

### Phase 3: Backend Script Development (Translation Logic)

- Develop Python script using Boto3 to:
  - Accept a JSON file with language metadata.
  - Submit text blocks to AWS Translate.
  - Save translated text as new JSON.
  - Upload results to `response-bucket`.

**Tools:** Python, Boto3
**Free Tier:** AWS Translate (2M characters/month), S3 storage

### Phase 4: Automation with AWS Lambda (Recommended)

- Package Python script as an AWS Lambda function.
- Configure S3 event trigger on `request-bucket` to invoke Lambda.
- Lambda reads file, performs translation, and writes output to `response-bucket`.

**Tools:** AWS Lambda, Amazon S3, IAM
**Free Tier:** Lambda (1M requests + 400,000 GB-seconds/month)

## Usage

1. **Clone the repository:**
   ```
   git clone https://github.com/habibaadam/Cloud-Capstone.git
   cd Cloud-Capstone
   ```

2. **Provision AWS resources with Terraform:**
   ```
   terraform init
   terraform apply
   ```

3. **Deploy and test translation workflow:**
   - Upload a JSON file to `request-bucket`.
   - Lambda function will process and store the translated output in `response-bucket`.

## Customization

- Modify Terraform scripts to adjust bucket names, lifecycle policies, or IAM permissions.
- Update Python code for additional language support or custom translation logic.

## Free Tier Considerations

- Monitor usage to stay within AWS Free Tier limits for S3, Translate, and Lambda.
- Use small file sizes and low execution time for Lambda functions.

## License

This project is open source and available under the MIT License.