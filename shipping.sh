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

dnf install maven -y &>> $logfile
validate "installing maven for java"

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

curl -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $logfile
validate "installing shipping  application " 

cd /app 
unzip -o /tmp/shipping.zip &>> $logfile
validate "unzipping the shipping file " 

mvn clean package &>> $logfile
validate "installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $logfile
validate "renaming jar file"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $logfile

systemctl daemon-reload &>> $logfile
validate "shipping daemon reload" 

systemctl enable shipping &>> $logfile
validate  "enabling shipping" 

systemctl start shipping &>> $logfile
validate  "starting shipping"

dnf install mysql -y $logfile 
validate "installing mysql"

mysql -h < mysql.pjdevops.online > -uroot -pRoboShop@1 < /app/schema/shipping.sql $logfile  

systemctl restart shipping $logfile 
validate "shipping is restarted"



