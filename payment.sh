#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGFILE="/tmp/$0-$TIMESTAMP.log"
MONGODB_HOST=mongodb.daws76devops.online

echo "script started executing at $TIMESTAMP" &>>$LOGFILE

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

dnf install python36 gcc python3-devel -y &>>$LOGFILE
 
VALIDATE $? "Installing python36 "

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop 

    VALIDATE $? "creating user roboshop" 
else 
    echo -e "roboshop user already exists $Y skipping $N"
fi

mkdir -p /app 

VALIDATE $? "creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOGFILE

VALIDATE $? "downloading payment" 

cd /app &>>$LOGFILE

unzip -o /tmp/payment.zip &>>$LOGFILE

VALIDATE $? "unzipping payment" 

pip3.6 install -r requirements.txt &>>$LOGFILE

VALIDATE $? "Installing dependencies" 

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service

VALIDATE $? "Copying payment service" 

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon reload payment" 

systemctl enable payment &>>$LOGFILE

VALIDATE $? "enabling payment service file" 

systemctl start payment &>>$LOGFILE

VALIDATE $? "starting payment service file" 