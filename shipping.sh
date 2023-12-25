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

dnf install maven -y &>>$LOGFILE

VALIDATE $? "installing Maven" 

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop 
    VALIDATE $? "creating user roboshop" 
else 
    echo -e "roboshop user already exists $Y skipping $N"
fi

mkdir -p /app &>>$LOGFILE

VALIDATE $? "creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOGFILE

VALIDATE $? "downloading Shipping" 

cd /app 

unzip -o /tmp/shipping.zip &>>$LOGFILE

VALIDATE $? "unzipping user"

mvn clean package &>>$LOGFILE

VALIDATE $? "installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>>$LOGFILE

VALIDATE $? "renaming jar files"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service

VALIDATE $? "copying shipping service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon reload shipping" 

systemctl enable Shipping &>>$LOGFILE

VALIDATE $? "enabling Shipping service file" 

systemctl start Shipping &>>$LOGFILE

VALIDATE $? "starting Shipping service file" 

dnf install mysql -y &>>$LOGFILE

VALIDATE $? "starting Shipping service file" 

mysql -h mysql.daws76devops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>$LOGFILE

VALIDATE $? "loading shipping data" 

systemctl restart shipping &>>$LOGFILE

VALIDATE $? "starting Shipping service file" 
