#!/bin/bash

mvn clean
mvn package
cd aws-terraform
terraform init
terraform plan -out "tvnz"
terraform apply "tvnz"
