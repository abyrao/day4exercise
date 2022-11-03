# cnappusecase


Add the below variables to your Terraform Cloud workspace

Go to https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-create-variable-set for more information

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY



Change Region to your chosen region

Change the Region by replacing the "country-area-number" in main.tf (lines 11 and 117 of code) and terraform.tfvars (lines 1 and 2) and variables.tf (line 23)



Change AMI identifier to an available AMI for your chosen region

Change ami-xxxxxxxxxxxxxxxxx in the variables.tf file (line 23) and the main.tf (line 112) keeping the "ami-" and just change the alphanumberic identifier "xxxxxxxxxxxxxxxxx"
