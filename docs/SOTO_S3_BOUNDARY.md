# Soto S3 Asset Boundary

DJSwift's first AWS application boundary is write-only S3 object storage for station artwork and non-music audio assets. `DJSwiftServer` depends on `SotoS3`, not the AWS SDK for Swift or Soto's umbrella product.

## Runtime contract

- `AssetStorage.put(key:data:contentType:)` is the application protocol.
- `S3AssetStorage` implements it with `S3.PutObject`.
- `AWSClient` is created once when both `AWS_REGION` and `AWS_S3_ASSET_BUCKET` exist and is shut down by Vapor's application lifecycle.
- Local and deployed credentials come from Soto's temporary default credential chain. Credentials never belong in source, dotenv files, Compose, images, or manifests.
- The adapter reports the bucket, object key, and underlying cause on upload failure without logging credentials or payload bytes.

No AWS call was made during repository modernization because the currently configured AWS CLI identity is the account root principal. Local credential verification must wait for IAM Identity Center or another approved temporary non-root identity.

## Permission surface

The implemented adapter makes exactly one AWS API call: `s3:PutObject`. Its application task role needs access only to the deployed asset prefix:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "WriteDJSwiftStationAssets",
      "Effect": "Allow",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::REPLACE_WITH_ASSET_BUCKET/stations/*"
    }
  ]
}
```

Do not add `s3:*`, bucket-listing permissions, read/delete permissions, or KMS permissions unless implemented behavior proves they are required. Replace the bucket placeholder only when Phase 6 provisions the concrete resource, then validate the policy with IAM Access Analyzer before attaching it to a DJSwift application role.
