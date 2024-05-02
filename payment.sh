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

dnf install python36 gcc python3-devel -y &>> $logfile
validate "installing python"

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

curl -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $logfile
validate "installing catalogue application "

cd /app

unzip -o /tmp/payment.zip &>> $logfile
validate "unzipping the payment file " 


pip3.6 install -r requirements.txt &>> $logfile
validate "installing dependenceis"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $logfile

systemctl daemon-reload &>> $logfile
validate "payment daemon reload" 

systemctl enable payment &>> $logfile
validate  "enabling payment" 

systemctl start payment &>> $logfile
validate  "starting payment"

