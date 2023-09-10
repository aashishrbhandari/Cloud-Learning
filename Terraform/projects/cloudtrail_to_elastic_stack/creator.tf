terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "4.21.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}



provider "local" {
    # Configuration options
}


/**

AWS CloudTrail Enable Setup
    - Multi Region (ALL Regions)
    - Logging to S3
    - Log file validation 
    - Event type
        - Management Events
    - API Activity: Read, Write (Not Exclude Anything)


Region:     ALL

AWS CloudTrail -> S3 -> S3 Event SQS ---> SQS URL (used by Elastic Stack Agent)


Create 1 S3 for CloudTrail Logs
Create S3 Bucket Policy to Allow Storing of CloudTrail Logs
Create CloudTrail with Logging to S3
Create SQS
Enable S3 Events to SQS

-----


**/

# Create CloudTrail Logs S3 Bucket
resource "aws_s3_bucket" "CloudTrailS3Logs" {
  bucket_prefix = "cts3"
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "CloudTrailS3BucketPolicy" {
    bucket = aws_s3_bucket.CloudTrailS3Logs.id
    policy = <<-POLICY
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "AWSCloudTrailAclCheck",
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "cloudtrail.amazonaws.com"
                    },
                    "Action": "s3:GetBucketAcl",
                    "Resource": "${aws_s3_bucket.CloudTrailS3Logs.arn}"
                },
                {
                    "Sid": "AWSCloudTrailWrite",
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "cloudtrail.amazonaws.com"
                    },
                    "Action": "s3:PutObject",
                    "Resource": "${aws_s3_bucket.CloudTrailS3Logs.arn}/*",
                    "Condition": {
                        "StringEquals": {
                            "s3:x-amz-acl": "bucket-owner-full-control"
                        }
                    }
                }
            ]
        }
    POLICY
}

# Attach S3 Bucket Policy
resource "aws_cloudtrail" "CloudTrailAPI_EventsLogs" {
  name                          = "CloudTrailAPI_EventsLogs"
  s3_bucket_name                = aws_s3_bucket.CloudTrailS3Logs.id # Bucker Name @ Top
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}

# Create SQS
resource "aws_sqs_queue" "CloudTrail_Logs_to_S3_Event_Queue" {
  name = "CloudTrail_Logs_to_S3_Event_Queue"
}

# SQS Policy
resource "aws_sqs_queue_policy" "SQS_Policy" {
  queue_url = aws_sqs_queue.CloudTrail_Logs_to_S3_Event_Queue.id

  policy = <<-POLICY
    {
        "Version": "2012-10-17",
        "Id": "sqspolicy",
        "Statement": [ 
            {
                "Sid": "SendMessagePermission",
                "Effect": "Allow",
                "Principal": "*",
                "Action": "sqs:SendMessage",
                "Resource": "${aws_sqs_queue.CloudTrail_Logs_to_S3_Event_Queue.arn}",
                "Condition": {
                    "ArnEquals": {
                        "aws:SourceArn": "${aws_s3_bucket.CloudTrailS3Logs.arn}"
                    }
                }
            }
        ]
    }
    POLICY
}

# Add SQS to S3 Events
resource "aws_s3_bucket_notification" "cloudtrail_logs_bucket_notify" {
    bucket = aws_s3_bucket.CloudTrailS3Logs.id

    queue {
        queue_arn     = aws_sqs_queue.CloudTrail_Logs_to_S3_Event_Queue.arn
        events        = ["s3:ObjectCreated:*"]
    }
}

## Output IMP Data

output "cloudtrail_s3_logs_bucket" {
    value = aws_s3_bucket.CloudTrailS3Logs.id
    description = "The S3 Bucket used to Log all CloudTrail API Logs."
}

output "cloudtrail_s3_bucket_queue_url" {
    value = aws_sqs_queue.CloudTrail_Logs_to_S3_Event_Queue.url
    description = "The S3 Bucket Events are sent to a queue which has the above URL"
}

resource "local_file" "local_data" {
    content  = "${aws_sqs_queue.CloudTrail_Logs_to_S3_Event_Queue.url},${aws_s3_bucket.CloudTrailS3Logs.id}"
    filename = "result.content"
}