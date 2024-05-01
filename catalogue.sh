#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "script name $0"

timestamp=$(data +%F-%H-%M-%S)

logfile="/tmp/$0-$timestamp.log"

echo "script started excuting at $timestamp" &>> $logfile
 
validate(){
    if [ $? -ne 0 ]
    then 
        echo -e "$1 is $R not succesfull $N"
        exit 1
    else
        echo -e "$1  is $G sucess $N"
    fi
}

if [ $ID -ne 0 ]
then    
    echo -e "$R not a root user $N"
    exit 1
else
    echo -e "$G root user $N"
fi

dnf module disable nodejs -y
validate "disabling current nodejs" &>> $logfile

dnf module enable nodejs:18 -y
validate "enabling  nodejs-18" &>> $logfile

dnf install nodejs -y
validate "installing nodejs-18" &>> $logfile

useradd roboshop
validate "creating roboshop user " &>> $logfile

mkdir /app
validate "creating app directory " &>> $logfile

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
validate "installing catalogue application " &>> $logfile

cd /app 
unzip /tmp/catalogue.zip
validate "unzipping the catalogue file " &>> $logfile

npm install 
validate "installing dependencies " &>> $logfile

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $logfile

systemctl daemon-reload
validate "catalogue daemon reload" &>> $logfile

systemctl enable catalogue
validate  "enabling catalogue" &>> $logfile

systemctl start catalogue
validate  "starting catalogue" &>> $logfile

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $logfile

dnf install mongodb-org-shell -y
validate  "installing mongodb shell" &>> $logfile

mongo --host dbmongo.pjdevops.online </app/schema/catalogue.js
validate  "loading catalogue data into mongodb" &>> $logfile

