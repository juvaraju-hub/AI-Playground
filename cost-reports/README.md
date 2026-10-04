# Aidev GPU cost report

CloudFormation stack for one AWS account. On the 5th of each month at 09:00 IST it builds the GPU cost workbook for the two latest complete months, stores it in S3, and emails it with SES.

This copy targets Aidev account `422940237045` in `us-west-2`. It does not read another account.

## Deploy

From this directory, with credentials for the target account:

```bash
python3 -m pip install -r requirements.txt -t function
sam deploy \
  --template-file template.yaml \
  --stack-name aidev-gpu-cost-report \
  --resolve-s3 \
  --capabilities CAPABILITY_IAM \
  --region us-west-2
```

`pip install -t function` is required before deploy. Those installed packages are not committed.

The From and To addresses default to `juvaraju@cisco.com`. Change them in the stack parameters or in the SSM parameters `/aidev-gpu-cost-report/from-address` and `/aidev-gpu-cost-report/to-address`.

SES must already allow the From domain. In Aidev, `cisco.com` is verified and uses the configuration set `ai_canvas_nonprod`.

## Test

```bash
aws lambda invoke \
  --function-name aidev-gpu-cost-report-report \
  --region us-west-2 \
  /tmp/gpu-cost-report-out.json
```
