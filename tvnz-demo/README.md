# AWS - Provision MySQL RDS and ECS with Wordpress using Terraform

## Requirements
### Versions
Terraform - v0.11.11  
Maven - 3.5.4  
JDK 1.8.0_231
  
  
  
### Terraform provisioning requirements - AWS
AWS Account Number (configuration required for API Gateway and Lambda)   
AWS Key and Secret  
These parameters will need to be updated in **variables.tf**  
Prefered AWS region is set to us-east-1. This can be changed if required.  
  
  
### Defaults for Demo purposes
Once provisioned and deployed successfully, please use the following credentials when starting the Wordpress application. These are for demo purposes only.  
  
  
 **Site:** admin  
 **Username:** admin (this is for demo purposes only - production deployments will be managed differently)  
 **Password:** admin (this is for demo purposes only - production deployments will be managed differently)  
 **Email:** Any email can be used  
   
   
### JAVA Lambda Function  
All java code resides in the **src** folder. Simple function to get the Lambda context and process it accordingly.  
  
  
### Build the application
Once the the AWS Terraform configuration has been complete, the build can be initiated. You would need to be in the root folder of the application. Run the following command:  
  
```
./build.sh
```
  
This will run a set of commands that will build the JAVA lambda function, deploy the infrastructure (RDS, ECS, ELB's, SG's, NAT GW, API Gateway, Lambda Function, JAVA components)  
  
The build consists of the following commands encapsulated in build.sh  
```
mvn clean  
mvn package  
cd aws-terraform  
terraform init  
terraform plan -out "tvnz"  
terraform apply "tvnz"  
``` 
  
Once completed successfully, the console output will consist of the following:  
```
1. DB Endpoint  
2. ECS Cluster  
3. astion Public IP  
4. Private IP GW  
5. Public IP GW  
6. Bastion SSH Private Key (Demo purposes only)  
7. ECS SSH Private Key (Demo purposes only)  
8. WordPress Public Endpoint - this is where you will access Wordpress. This parameter will also be required for the API Gateway service call (important to note)  
9. Wordpress Create Post API Service Enpoint - This will allow you to create a post via cURL or Postman 
```  
  
### Testing  
After a successfull deployment, you can access the Wordpress site by navigating to the **WordPress Public Endpoint** that is available from the output eg. **``wordpress-2084892677.us-east-1.elb.amazonaws.com``**  Please wait a few minutes after the build to allow for the containers to start up and the ELB health checks to be active. An HTTP 503 will be thrown if the containers are not up and running. Please try again if you do experience a 503.    
  
You will be presented with the final configuration of Wordpress which requires the Language setting and admin user. Please refer to the above **Defaults for Demo.** Once you have completed this configuration, you can now access Wordpress. To test the Lambda functions that are exposed via API Gateway, you will need the Service endpoint that was rendered in the output eg. **``https://jfnfcy2432.execute-api.us-east-1.amazonaws.com/tvnz/createPost``**  
  
You can test this using the below cURL command:  
  
```  
curl -H "Content-Type: application/json" -X POST [SERVICE ENDPOINT] -d '{"title":"Your title here","content":"Your content here", "url":"[WORDPRESS ENDPOINT]"}'  
```  

Success message: **"Post processed successfully for : TITLE + CONTENT + WORDPRESS-SITE**  
Error Message: **Post process has failed : {Error Message}**
  
You will find the parameters required to run this as mentioned above. The service does not perform any validation as this is for demo purposes only. Only positive testing applies. Once this cURL has run successfully, you can log into Wordpress using the user that was created (admin) and view the posts.  
  
  
# Important Notes  
Please remember that without the required AWS parameters, this will not work. The post configuration using the defaults as specified in **Defaults for Demo** must be adhered to for a successful outcome. The build and destroy files must have the correct permissions:  
  
```
chmod 755 build.sh destroy.sh
```  
  
**BUILD NOTES:** Script files must be run from the project root directory. Once successfully tested **PLEASE TEAR DOWN ENVIRONMENT** to prevent costs.  
  
```
./destroy.sh
```
  
  


   
   
 
  
