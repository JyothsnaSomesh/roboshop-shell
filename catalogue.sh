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
dnf module disable nodejs -y &>>$LOGFILE

VALIDATE $? "disabling current nodejs"

dnf module enable nodejs:18 -y &>>$LOGFILE

VALIDATE $? "enabling nodejs-18"

dnf install nodejs -y &>>$LOGFILE

VALIDATE $? "installing nodejs-18" 

id roboshop
if [ $? -ne 0]
then
    useradd roboshop 

    VALIDATE $? "creating user roboshop" 
else 
    echo -e "roboshop user already exists $Y skipping $N"
fi

mkdir -p /app 

VALIDATE $? "creating app directory" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOGFILE

VALIDATE $? "downloading catalogue" 

cd /app 

unzip /tmp/catalogue.zip &>>$LOGFILE

VALIDATE $? "unzipping catalogue" 

npm install &>>$LOGFILE

VALIDATE $? "Installing dependencies" 

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE

VALIDATE $? "copying catalogue service file" 

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon reload catalogue" 

systemctl enable catalogue &>>$LOGFILE

VALIDATE $? "enabling catalogue service file" 

systemctl start catalogue &>>$LOGFILE

VALIDATE $? "starting catalogue service file" 

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "copying Mongodb repo" 

dnf install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "Installing mongodb client" 

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>>$LOGFILE

VALIDATE $? "Loading catalogue data into Mongodb" 



