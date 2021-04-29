# Auto-tagging EC2 and EBS with Terraform

This is a tool was written by Terraform and Python3.8

## Prerequisites
1. [Git](https://git-scm.com/downloads): Amazing tool.
2. [Terraform](https://www.terraform.io/downloads.html): The most important tool. Make sure download the latest (0.15 current) and add ```PATH``` if your OS is Windows. (Vession 0.15)
3. [Python](https://www.python.org/downloads/): My code using Python 3.8.
4. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) (Recommend): A greate tool of AWS.
5. [Github](https://github.com/) (Recommend): Control your code easily.
6. [VSCode](https://code.visualstudio.com/download) (Recommend for dev): You can upgrade my code with it.

## Installation

### Step 1: 
Make sure you install the first 3 (recommend 4) options above.
Get credentials from AWS, using ```aws configure```.
Follow [this guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html). 
Check your access using ```aws sts get-caller-identity```.

### Step 2:
Clone this repo using Git:
```bash
git clone https://github.com/donglu1000tu/auto_tagging.git
```
### Step 3:
Open CMD, GitBash or PowerShell in this folder you just clone:
```bash
terraform init
terraform plan 
terraform apply --auto-approve 
```
## Parameter
```Owner```: Use 'PrincipalID' in here, maybe you can change to other parameter.

```Schedule```: schedule instance run or stop, search AWS Scheduler EC2 or something similar.

```project```: Use 'userAgent' in here, maybe you can change to other parameter.
## Upgrade code
This code deploys in a single region. So please help me deploy multiple regions, it's a little hard with me now.
## Usage

Auto-tagging your EC2 and EBS using the Lambda function in Single Region. 
Just create an EC2 instance and see its tag.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Reference
[https://vticloud.io/tu-dong-gan-the-cac-tai-nguyen-tren-aws-khi-khoi-tao/](https://vticloud.io/tu-dong-gan-the-cac-tai-nguyen-tren-aws-khi-khoi-tao/)
