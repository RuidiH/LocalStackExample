Steps to Start:

1. Run Docker

2. Run LocalStack.exe

3. terraform init OR terraform init -upgrade

   (optional) terraform plan
    
    terraform apply

To see LocalStack DynamoDB:

1. Install awslocal

2. awslocal configure
    
    Set keys, region, and format(json)
    Make sure Information matches 

3. awslocal dynamodb list-tables