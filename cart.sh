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

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $logfile
validate "installing cart application " 

cd /app 
unzip -o /tmp/cart.zip &>> $logfile
validate "unzipping the cart file " 

npm install &>> $logfile
validate "installing dependencies " 

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $logfile

systemctl daemon-reload &>> $logfile
validate "cart daemon reload" 

systemctl enable cart &>> $logfile
validate  "enabling cart" 

systemctl start cart &>> $logfile
validate  "starting cart" 