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

dnf module disable mysql -y &>>$LOGFILE

VALIDATE $? "diabled current mysql version" 

cp mysql.repo /etc/yum.repos.d/mysql.repo &>>$LOGFILE

VALIDATE $? "copied Mysql repo" 

dnf install mysql-community-server -y &>>$LOGFILE

VALIDATE $? "Installing MYSQL Server" 

 systemctl enable mysqld &>>$LOGFILE

VALIDATE $? "Enabling Mysql server" 

systemctl start mysqld &>>$LOGFILE

VALIDATE $? "Sarting mysql server" 

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOGFILE

VALIDATE $? "setting Mysql root password" 

