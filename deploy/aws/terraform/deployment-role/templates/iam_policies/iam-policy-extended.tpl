{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowExtendendPermissions",
      "Action": [
        "s3:GetLifecycleConfiguration",
        "s3:PutLifecycleConfiguration",
        "ec2:DisableEbsEncryptionByDefault",
        "ec2:EnableEbsEncryptionByDefault",
        "ec2:GetEbsDefaultKmsKeyId",
        "ec2:GetEbsEncryptionByDefault",
        "ec2:ModifyEbsDefaultKmsKeyId",
        "ec2:ResetEbsDefaultKmsKeyId",
        "ec2:CreateNetworkAcl",
        "ec2:CreateNetworkAclEntry",
        "ec2:DeleteNetworkAcl",
        "ec2:DeleteNetworkAclEntry",
        "ec2:StopInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
