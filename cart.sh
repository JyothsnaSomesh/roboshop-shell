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
dnf module disable nodejs -y &>>$LOGFILE

VALIDATE $? "disabling current nodejs"

dnf module enable nodejs:18 -y &>>$LOGFILE

VALIDATE $? "enabling nodejs-18"

dnf install nodejs -y &>>$LOGFILE

VALIDATE $? "installing nodejs-18" 

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

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>$LOGFILE

VALIDATE $? "downloading cart" 

cd /app 

unzip -o /tmp/cart.zip &>>$LOGFILE

VALIDATE $? "unzipping cart" 

npm install &>>$LOGFILE

VALIDATE $? "Installing dependencies" 

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>>$LOGFILE

VALIDATE $? "copying cart service file" 

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon reload cart" 

systemctl enable cart &>>$LOGFILE

VALIDATE $? "enabling cart service file" 

systemctl start cart &>>$LOGFILE

VALIDATE $? "starting cart service file" 


