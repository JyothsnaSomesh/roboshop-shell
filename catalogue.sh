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
dnf module disable nodejs -y &>>$LOGFILE

VALIDATE $? "disabling current nodejs"

dnf module enable nodejs:18 -y &>>$LOGFILE

VALIDATE $? "enabling nodejs-18"

dnf install nodejs -y &>>$LOGFILE

VALIDATE $? "installing nodejs-18" &>>$LOGFILE

useradd roboshop

VALIDATE $? "creating user roboshop" &>>$LOGFILE

mkdir /app

VALIDATE $? "creating app directory" &>>$LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "downloading catalogue" &>>$LOGFILE

cd /app 

unzip /tmp/catalogue.zip

VALIDATE $? "unzipping catalogue" &>>$LOGFILE

cd /app

npm install 

VALIDATE $? "Installing dependencies" &>>$LOGFILE

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE $? "copying catalogue service file" &>>$LOGFILE

systemctl daemon-reload

VALIDATE $? "daemon reload catalogue" &>>$LOGFILE

systemctl enable catalogue

VALIDATE $? "enabling catalogue service file" &>>$LOGFILE

systemctl start catalogue

VALIDATE $? "starting catalogue service file" &>>$LOGFILE

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying Mongodb repo" &>>$LOGFILE

dnf install mongodb-org-shell -y

VALIDATE $? "Installing mongodb client" &>>$LOGFILE

mongo --host $MONGODB_HOST </app/schema/catalogue.js

VALIDATE $? "Loading catalogue data into Mongodb" &>>$LOGFILE



