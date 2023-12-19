#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
exec &>>$LOGFILE

echo "script started executing at $TIMESTAMP" 

VALIDATE (){
   if [ $1 -ne 0 ]
   then
      echo -e "$2... $R FAILED $N"
      exit 1
   else
      echo -e "$2... $G SUCCESS $N"
   fi
   }


if [ $ID -ne 0 ]
then
   echo -e "$R ERROR :: Please access with root user $N"
   exit 1 # you can give other than zero
else
   echo "You are root user"
fi

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y 

VALIDATE $? "Installing remi-release"

dnf module enable redis:remi-6.2 -y 

VALIDATE $? "enabling redis:remi"

dnf install redis -y 

VALIDATE $? "installing Redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf 

VALIDATE $? " ALlowing remote connections"

systemctl enable redis 

VALIDATE $? " Enabling Redis"

systemctl start redis 

VALIDATE $? " Starting Redis"
