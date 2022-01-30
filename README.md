# Description

Goal of this project is to allow users to run a terraform script to bring up the require infrastructure in aws to host a simple postgresql database. We will be utilizing the following resources to achieve this task

* VPC
* Internet Gateway
* VPC Route Table
* Public Subnet
* Security Group
* EC2

The whole idea is to spin up a ec2 in a default or customized VPC environment. We will utilize gateway, route table and subnet to setup the networking rules. We will only allow inbound traffic via ssh on port 22 of the ec2 instance. All traffic will be allowed outwards from the ec2 instance. If you need it to be more restrictive, make that change in subnet/vpc/postfres config file. It really depends on the need. If the network needs to be restrictive, you can configure `${allowed_ip}` to your desired ip in `pg_hba.conf`

# Pre-requisites

- [AWS account](https://aws.amazon.com/account/)
- [AWS cli](https://aws.amazon.com/cli/)
  - MacOS: `brew install awscli`
- AWS access key and secret (AWS IAM)
  - After you have the key and secret, do the following
    - `mkdir ~/.aws`
    - `vi ~/.aws/config` and put aws specific values (i.e. region) in there similar to the following

    ```
    [profile profile_name]
    region=us-east-1
    output=json
    ```
    - `vi ~/.aws/credentials` and put your secrets in here similar to the following

    ```
    [profile_name]
    aws_access_key_id=HEHEHEHEHEHEHE
    aws_secret_access_key=HEHEHEHEHE
    ```
- terraform (recommend [tfenv](https://github.com/tfutils/tfenv))

# Provisioning

- Clone this repository
- Generate a ssh key if you do not have it already
  - `ssh-keygen -t rsa`
  - keep the public key in this directory
- First, go to variable.tf to update the values to your specific values
- Run `terraform init`
- Run `terraform validate` to verify the syntax
- Run `terraform plan` if you want to see the plan
- Run `terraform apply -auto-approve` to actually provision the resources described using `main.tf` and `variable.tf`
- Save the IP address that gets outputted at the end of previous step

# Accessing the EC2 instance

`ssh -i <path to your private key> ec2-user@<IP addres that you saved at the end of last section>`

# Cleanup

`terraform destroy`
