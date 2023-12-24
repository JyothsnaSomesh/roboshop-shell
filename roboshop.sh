#!/bin/bash

AMI=ami-03265a0778a880afb
SG_ID=sg-042b3bca4427fb7b3
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "User" "cart" "shipping" "Payment" "web" "ratings")
Zone_ID=Z025729721K26XR9HFCPR
DOMAIN_NAME="daws76devops.online"

for i in "${INSTANCES[@]}"
do  
    
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.small"
    else 
        INSTANCE_TYPE="t2.micro"
    fi
    IP_ADDRESS=$(aws ec2 run-instances --image-id ami-03265a0778a880afb --instance-type $INSTANCE_TYPE --security-group-ids sg-042b3bca4427fb7b3 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i: $IP_ADDRESS" 
     
    aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '
  {
    "Comment": "Testing creating a record set"
    ,"Changes": [{
      "Action"              : "CREATE"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$i.$DOMAIN_NAME'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP_ADDRESS'"
        }]
      }
    }]
  }
  '
done