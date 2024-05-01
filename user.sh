#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "script name $0"

timestamp=$(date +%F-%H-%M-%S)

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

dnf module disable nodejs -y &>> $logfile
validate "disabling current nodejs" 

dnf module enable nodejs:18 -y &>> $logfile
validate "enabling  nodejs-18" 

dnf install nodejs -y &>> $logfile
validate "installing nodejs-18" 

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop &>> $logfile
    validate "roboshop user creation"
else
    echo "roboshop user already exisits skiping"
fi

validate "creating roboshop user " 

mkdir -p /app &>> $logfile
validate "creating app directory " 

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $logfile
validate "installing user application " 

cd /app 
unzip -o /tmp/user.zip &>> $logfile
validate "unzipping the user file " 

npm install &>> $logfile
validate "installing dependencies " 

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $logfile

systemctl daemon-reload &>> $logfile
validate "user daemon reload" 

systemctl enable user &>> $logfile
validate  "enabling user"

systemctl start user &>> $logfile
validate  "starting user" 

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $logfile

dnf install mongodb-org-shell -y &>> $logfile
validate  "installing mongodb shell" 

mongo --host dbmongo.pjdevops.online </app/schema/user.js &>> $logfile
validate  "loading user data into mongodb" 

