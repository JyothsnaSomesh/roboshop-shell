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

dnf install nginx -y &>>$LOGFILE

VALIDATE $? "installing nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE

VALIDATE $? "removing default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>$LOGFILE

VALIDATE $? "downloading web application"

cd /usr/share/nginx/html &>>$LOGFILE

VALIDATE $? "moving nginx html directory"

unzip -o /tmp/web.zip &>>$LOGFILE

VALIDATE $? "unzipping web" 

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>>$LOGFILE

VALIDATE $? "copied roboshop reverse proxy config"

systemctl restart nginx &>>$LOGFILE

VALIDATE $? "starting nginx" 