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

dnf install nginx -y &>> $logfile
validate "installing nginx" 

systemctl enable nginx &>> $logfile
validate  "enabling nginx" 

systemctl start nginx &>> $logfile
validate  "starting nginx" 

rm -rf /usr/share/nginx/html/* &>> $logfile 
validate  "removing content" 


curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $logfile
validate  "installing web application" 


cd /usr/share/nginx/html &>> $logfile
validate  "moving to html" 


unzip -o /tmp/web.zip &>> $logfile
validate  "unzipping the eb application" 


cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $logfile
validate  "copying roboshop conf file" 

systemctl restart nginx &>> $logfile
validate  "restarting nginx" 

