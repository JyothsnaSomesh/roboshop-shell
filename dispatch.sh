#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"


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

dnf install golang -y &>>$LOGFILE

VALIDATE $? "installing golang" 

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop &>>$LOGFILE

    VALIDATE $? "creating user roboshop" 
else 
    echo -e "roboshop user already exists $Y skipping $N"
fi

mkdir -p /app &>>$LOGFILE

VALIDATE $? "creating app directory" 

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>>$LOGFILE

VALIDATE $? "downloading dispatch"

cd /app &>>$LOGFILE

unzip /tmp/dispatch.zip &>>$LOGFILE

VALIDATE $? "unzipping dispatch"

cd /app 
go mod init dispatch
go get 
go build

VALIDATE $? "Installing dependencies"

cp/home/centos/roboshop-shell/ /etc/systemd/system/dispatch.service &>>$LOGFILE

VALIDATE $? "copying dispatch service file"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon reload dispatch" 

systemctl enable dispatch &>>$LOGFILE

VALIDATE $? "enabling dispatch service file" 

systemctl start dispatch &>>$LOGFILE

VALIDATE $? "starting dispatch service file" 
