### Let's learn

<img src="https://dashboard.snapcraft.io/site_media/appmedia/2022/01/awscli_Tl3t26M.png" width=180> 

<b>This is what Amazon AWS Docs Defines it's cli as</b>

The AWS Command Line Interface (AWS CLI) is a unified tool to manage your AWS services. With just one tool to download and configure, you can control multiple AWS services from the command line and automate them through scripts.

More Details Below:
https://aws.amazon.com/cli/
https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html

---

<b> In Simple words (as per my understanding): </b> 

- AWS (or most services) interact with the means of API.
- AWS CLI (in the backend) uses API call to interact with your AWS Account and then create Resources like(EC2,S3,VPC and a lot other).
- It is like doing the same thing that you do via your AWS Dashboard (in the backend you are actually making API Calls) with multiple selections and clicks.
- Very Important Part: A True Engineer is someone who first understand the working of a software (tries it multiple times) and then tries to Automate it. AWS CLI is the way to automate this repetitive process.
- You can write scripts that will run multiple aws cli options and built a complete aws setup (a project) within few minutes.
- Why AWS CLI ? Because whoever has used Linux, knows and understands the `Power of CLI`.

Example : To Create a S3 Bucket:

Just use the below line

```sh
aws s3api create-bucket --bucket bucket-no1-67121 --region us-east-1
```

<b> Note: Just by Running the Above Command, Things don't work </b> 


You will require to do few things first

###### Pre-requisites
- Have a AWS (I would suggest go with ACloudGuru)
- Create an IAM User with Admin Access
- Create Access keys(Access Keys + Secret Keys)

###### Setup
- Install AWS CLI (awscli)
- Set/Configure AWS Access Keys

<br>

## Simple Snippet to Get All EC2
This Example Snippet is just to showcase what all things can be done using AWS CLI and further adding this to a bash script for further automation.

> Note: This is a Small snippet which got from internet to get my work done. you can further add new fields to get more details. Just to add: the below code basically travers through the JSON response provided by (aws ec2 describe-instances) and then provides only fields mentioned in table format(--output=table)

```bash
aws ec2 describe-instances \
    --query 'Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Name:Tags[?Key==`Name`]|[0].Value,PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress}' \
    --output table
```

Output:
```
----------------------------------------------------------------------------------------
|                                   DescribeInstances                                  |
+------------+-----------------------+--------------+----------------+-----------------+
|     AZ     |       Instance        |    Name      |   PrivateIP    |    PublicIP     |
+------------+-----------------------+--------------+----------------+-----------------+
|  us-east-1a|  i-0824edff9ece6a36a  |  WebServer-1 |  10.30.1.254   |  18.234.248.77  |
|  us-east-1a|  i-05cca13247fc4f031  |  DBServer-1  |  10.30.101.201 |  None           |
|  us-east-1b|  i-0b0ce6247da0ea168  |  WebServer-2 |  10.30.2.68    |  54.89.221.17   |
|  us-east-1b|  i-04fb53c235b5c4a45  |  DBServer-2  |  10.30.102.112 |  None           |
+------------+-----------------------+--------------+----------------+-----------------+
```
