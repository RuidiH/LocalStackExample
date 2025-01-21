## Setup

#### 0. Clone this repo to a folder on your local machine


#### 1. Prepare [AWS key pair](https://docs.aws.amazon.com/IAM/latest/UserGuide/access-key-self-managed.html)
You will need to know your access key and secret key.

#### 2. Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
You should see the something similar to the following in your terminal:

    $ aws --version
    aws-cli/1.36.36 Python/3.11.8 Windows/10 botocore/1.35.95aws --version

#### 3. Enter AWS Credentials

    // creating a profile named 'terraform'
    aws configure --profile terraform 

    // Then Enter Access Key ID, Secret Key ID, Region(us-west-2), Format(json)
    // Potential security risk ??

#### 4. Install [Terraform](https://developer.hashicorp.com/terraform/install)
It is recommended that you walk through the official tutorials to get a sense of what it's for.
Similarly, you should see something like the following:

    $ terraform --version
    Terraform v1.10.3
    on windows_amd64

#### 5. Install [Postman](https://www.postman.com/downloads/)    
Also check out the official documentation on how do send GET and POST request [here](https://learning.postman.com/docs/getting-started/first-steps/sending-the-first-request/)

#### 6. Install [Golang](https://go.dev/) if you have not already done so.

##### Note
I recommend adding terraform and aws cli to [PATH](https://stackoverflow.com/questions/44272416/how-to-add-a-folder-to-path-environment-variable-in-windows-10-with-screensho) if you have not done so.

## Execution

#### 1. Compile Go binary:

    cd ./server

    go mod tidy

    GOOS=linux GOARCH=amd64 go build -o go-server main.go


#### 2. Create terraform.tfvars under root with your ip address:

    allowed_ip = "YOUR.IP.ADDRESS.HERE"


#### 3. Run terraform:

    // only run this line once
    terraform init

    terraform apply


#### 4. To test requests:
Use curl or [Postman](https://learning.postman.com/docs/getting-started/first-steps/sending-the-first-request/) to send requests

    curl -X POST -H "Content-Type: application/json" -d '{"id": 1, "score": 100}' http://<EC2.IP.ADDRESS.HERE>:8081/item
    curl -X GET http://<EC2.IP.ADDRESS.HERE>:8081/item/1

#### 5. To apply any changes:
If you changed server code

    terraform destroy

And go back to step 1.

Else if changed Infrastructure

    terraform apply

When there's only a single instance, manually sending over binary using CLI is might faster than repeating the destroy - apply process.

#### 6. When you are done, you might want to:
    
    terraform destroy

#### Notes:

init-script.sh needs to be in LF instead of CRLF.

For cross-compile issue, see [here](https://stackoverflow.com/questions/20829155/how-to-cross-compile-from-windows-to-linux).