# InfoGathering using AWS CLI

1. Get All Instances IMDS Status (Of Region us-east-1)

```
aws ec2 describe-instances --region us-east-1 --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value|[0],InstanceId,MetadataOptions.HttpTokens]' --output table
```


<strong>Example:</strong>

Below Column 3 Shows IMDSv2 Options: If it is `required` it is IMDSv2 and if it is `optional` it is IMDSv1
```
aws ec2 describe-instances --region us-east-1 --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value|[0],InstanceId,MetadataOptions.HttpTokens]' --output table
----------------------------------------------------------------------
|                          DescribeInstances                         |
+--------------------------------+-----------------------+-----------+
|  Machine01                     |  i-09641dfadsffbdc1b  |  required |
|  Machine02                     |  i-09641dfadsffbdc2b  |  optional |
|  Machine03                     |  i-09641dfadsffbdc3b  |  required |
|  Machine04                     |  i-09641dfadsffbdc4b  |  required |
|  Machine05                     |  i-09641dfadsffbdc5b  |  required |
|  Machine06                     |  i-09641dfadsffbdc6b  |  required |
|  Machine07                     |  i-09641dfadsffbdc7b  |  required |
|  Machine08                     |  i-09641dfadsffbdc8b  |  optional |
|  Machine09                     |  i-09641dfadsffbdc0b  |  required |
+--------------------------------+-----------------------+-----------+

```

2. Get All AWS EC2 Volumes (EBS) Details

```
aws ec2 describe-volumes --query 'Volumes[*].[VolumeId,State,VolumeType,Size,Iops,Attachments[0].InstanceId,Attachments[0].Device]' --output table
```

<strong>Example:</strong>

Below Column 3 Shows Volume Type Details: Like GP2, GP3, IO1 etc.
```
aws ec2 describe-instances --region us-east-1 --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value|[0],InstanceId,MetadataOptions.HttpTokens]' --output table
-------------------------------------------------------------------------------------------------
|                                        DescribeVolumes                                        |
+------------------------+---------+------+-------+--------+----------------------+-------------+
|  vol-0a3781gtasfde58a2 |  in-use |  gp2 |  60   |  3000  |  i-09641dfadsffbdc1b |  /dev/xvda  |
|  vol-0a3781gtasfde58a3 |  in-use |  gp2 |  20   |  3000  |  i-09641dfadsffbdc1b |  /dev/xvda  |
|  vol-0a3781gtasfde58a4 |  in-use |  gp3 |  20   |  3000  |  i-09641dfadsffbdc1b |  /dev/xvda   |
|  vol-0a3781gtasfde58a5 |  in-use |  gp3 |  60   |  3000  |  i-09641dfadsffbdc1b |  /dev/xvda  |
|  vol-0a3781gtasfde58a6 |  in-use |  gp3 |  750  |  3000  |  i-09641dfadsffbdc1b |  /dev/xvda   |
|  vol-0a3781gtasfde58a7 |  in-use |  gp2 |  100  |  16000 |  i-09641dfadsffbdc1b |  /dev/xvda   |
|  vol-0a3781gtasfde58a8 |  in-use |  gp3 |  111  |  4000  |  i-09641dfadsffbdc1b |  /dev/xvda   |
|  vol-0a3781gtasfde58a9 |  in-use |  io1 |  60   |  3000  |  i-09641dfadsffbdc1b |  /dev/xvda  |
+------------------------+---------+------+-------+--------+----------------------+-------------+

```