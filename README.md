### 0.  Setup aws profile configuration, will need access & secret key:
    // You might need AWS CLI installed
    // Default profile name is 'terraform'
    aws configure --profile terraform 
    // Enter Access Key ID, Secret Key ID, Region(us-west-2), json
    // Potential security risk ??

### 1. Compile Go binary:

    cd ./server

    go mod tidy

    GOOS=linux GOARCH=amd64 go build -o go-server main.go


### 2. Create terraform.tfvars under root with your ip address:

    echo "allowed_ip = \"<YOUR.IP.ADDRESS.HERE>\"" >> terraform.tfvars


### 3. Run terraform:

    // only run this line once
    terraform init

    terraform apply


### 4. To test requests:

    curl -X POST -H "Content-Type: application/json" -d '{"id": 1, "score": 100}' http://<EC2.IP.ADDRESS.HERE>:8081/item
    curl -X GET http://<EC2.IP.ADDRESS.HERE>/item/1

### 5. To apply any changes to the server, run the following and go back to Step 1:
    // If you changed server code    
    terraform destroy
    
    // Else if changed Infrastructure
    terraform apply

    // When there's only a single instance, manually sending over binary using CLI is faster.

### 6. When you are done, you might want to:
    
    terraform destroy

#### Notes:

init-script.sh needs to be in LF instead of CRLF.