#!/bin/bash

AMI=ami-0f3c7d07486cad13
SG_ID=sg-04bb94f5d828fa09d
INSTANCES=("mongodb" "catalogue" "user" "cart" "redis" "shipping" "rabbitmq" "payment" "mysql" "web" "dispatch")

for i in "${INSTANCE[@]}"
do
    echo "instance is: $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    aws ec2 run-instances --image-id ami-0f3c7d07486cad139 --instance-type $INSTANCE_TYPE --security-group-ids sg-04bb94f5d828fa09d  --tag-specification "ResourceType=instance,Tags=[{key=Name,Value=$i}]"
done

