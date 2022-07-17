### Let's Learn
<img src="https://www.vectorlogo.zone/logos/terraformio/terraformio-ar21.png" height=150>

⇴ As per my understanding:

Terraform is an IaC software that is multi-cloud (well it covers more than that), terraform is a API Connector i.e it gives you an way to write a structured code which will be used to create resources using the vendor specific API. it also manages a state (i.e a table of resources it has created) so that it can be used delete/destroy/clean after the process. <a href="https://www.terraform.io/intro" target="_blank"> read more here.⤤ </a>



<b> Benefits: </b>
- Automation (Automate Cloud Deployment)
- Configuration Management
- Cross-Platform Solution with Multi-Cloud IaC Support
- OpenSource IaC

many more....


<b> Others in the List of Similar Softwares & Solution are: </b>
- AWS CloudFormation (Only for AWS Resources)
- Ansible (@linux guyz will know this)
- Chef 
- Puppet

many more....

<b> Ever Heard of : IaC (Infrastructure as Code) </b>

Well when i heard it, i was not able to understand it, i could just memorize the full form that's it, nothing else, if someone would have asked me, i would have just got stuck after the full form, the reason being because i was not able to understand infrastructure and how to create my own infra, and what code is written to create a infra, is it some python code etc.
I learnt the true meaning & power of IaC after i explored AWS and later felt that i have to automate things here so that i do not just waste time in creating the same setup (after i have learnt it well) again & again and not able to move ahead.


### My Personal Experience

###### Necessity is the Mother of All Inventions

Till the time you do not explore the software or solution yourself, you will not know or not understand the importance of it.
When i first heard IaC it was very difficult for me to understand or explain it to someone what it is. i can only memorized without knowing what, where and how it works.
The moment i started practically learning AWS (using ACloudGuru Cloud-Sanboxes) i understood that after creating the same VPC-Subnet-RT-IGW-EC2 it was time consuming, since i was not able to proceed (ACloudGuru Cloud-Sanboxes has max 4 Hours Access) ahead and do any new thing. i thought of automating it, using CLI, AWS CloudFormation.
But after some research i can across Terraform and the story continues.

Terraform is amazing, it helped me understand why would someone want a IaC, how to actually create one template and learn AWS better.


---

## Terraform basics

> Note: For Explanation part and the setup, i am using Terraform for AWS Resources creation, but this is a good start to learn about terraform.

1. Download Terraform from [Terraform Download Page](https://www.terraform.io/downloads) , Select the OS Specific Variant
    - Terraform is a Single Binary File.(Size is around ~57 MB)
    - unzip it add it to your Env Path
2. Create a Project Folder & create a file with basic TF (terraform script) [Simple TF](./simple-vpc-creator-mini.tf)
3. Credentials to Communicate with the Provider and create resources/infra.
    - With Terraform there are multiple Options
        - [Terraform Official Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
        - [Another Good doc by jhooq](https://jhooq.com/terraform-aws-credentials-handling/)
    - I am using the `awscli` config files approach, as i have to use awscli for other info gathering, therefore this is efficient approach.
    - Learn about AWS CLI config setting [@AWSCLI Setup](../AWSCLI/readme.md) 
4. Let's Explore
    - Terraform Format [Optional] 
        It basically just formats your code, add indentation wherever required
        ```
        terraform fmt
        ```
    - Terraform Initialize (#Step1)
        Understand that Terraform init requires a Config file (.tf), because it will use that to download the respective providers plugins/modules(in our case it will public cloud vendor api communication lib/code created by @hashicorp)
        ```
        terraform init
        ```
    - Terraform Plan
        ```
        terraform plan
        ```
        It is not Optional, it is very important that you review your terraform config as it is going to make changes to your infra or create a new infra, better to plan before apply
    - Terraform apply
        ```
        terraform apply
        ```
        Go ahead by by actually doing the apply, now it is like terraform plan + actual changes and therefore after showing plan-like result it will ask for Y/N 
        To automate it after you have already review this, only do it incase you already run this config file(.tf) multiple times and aware of the result
        ```
        terraform apply -auto-approve
        ```
4. Just go to your Account(AWS) to see resources go created or not

You will be amazed to see that it takes less than 2 mins to create Infra of a VPC -> RT -> NACL -> Subnet -> EC2 -> SG
I have a demo tf [@simple-infra-setup1](./projects/simple-setup1)


## [Practical] Let's actually do it
<font size="3"> 
    Above part is doc and command explanation, let's take a practice set
   
</font>
<br>
<br/>


> NOTE: I am just trying to list down steps, for basic steps like go ahead folder or copy code you will not find any command shown or given or result shown

1. Make sure you have the terraform binary downloaded and added to ENV PATH
2. let's use the above [@simple-tf](./simple-vpc-creator-mini.tf) for practice, download the file and add it to a folder and move inside the folder

<details open>
    <summary>You can also go ahead </summary>

with this Terraform Config file [@simple-infra-setup1](./projects/simple-setup1)  
To have a better understanding of what Terraform can do, why it is called IaC and what is it true power

</details>

3. let's do the `terraform init`.
4. Only for this example let's go to `terraform apply -auto-approve`

__>>>__ *Now you might be wondering why we did not use `terraform fmt` and `terraform plan`, well in this case we knew the config file(it is a very basic simple VPC creator) and also we do not require format part*

