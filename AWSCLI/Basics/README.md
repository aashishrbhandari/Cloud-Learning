
#### 1. Get Caller Identity

Run below `aws cli` command to get the Caller Details (i.e Programmatic Key Owner & Account)
This command helps to validate that the Programmatic Keys are added and are correct.

```
aws sts get-caller-identity
```

<strong>Example:</strong>

```
aws sts get-caller-identity
{
    "UserId": "AIDAQWKFARWGGNCW5Q",
    "Account": "5324912353240",
    "Arn": "arn:aws:iam::5324912353240:user/aws-user"
}
```
#### 2. Use ENV EXPORT to Store AWS Programmatic Keys

Put " "(SPACE) at start of the export , so that it does not logs into the BASH HISTORY

> Note: CentOS and AL3 stores the command in History regardless of having SPACE " " in start of the command 

```
 export AWS_ACCESS_KEY_ID=AKIAHKJSAHDOUE1LKDJ ; export AWS_SECRET_ACCESS_KEY="BASDJALJSAJ/asdakjLSDJASDJ:D" ; export AWS_DEFAULT_REGION="us-east-1"
```

