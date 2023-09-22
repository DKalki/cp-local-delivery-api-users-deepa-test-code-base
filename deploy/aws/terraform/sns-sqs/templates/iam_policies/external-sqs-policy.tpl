{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${account-id}:root"
      },
      "Action": "sqs:*",
      "Resource": "*"
    },
    {
      "Sid": "Administrators can manage the SQS",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${account-id}:role/${instance}-ld-plat-rol-deployment"
      },
      "Action": "sqs:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:${aws-region}:${account-id}:${instance}-ld-sqs-external-sq",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "arn:aws:sns:${aws-region}:${account-id}:${instance}-ld-sns-psc"
        }
      }
    }
  ]
}