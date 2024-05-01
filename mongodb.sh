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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $logfile
validate $? "copied mongo repo"

dnf install mongodb-org -y &>> $logfile 
validate $? "installing mongodb"

systemctl enable mongod &>> $logfile 
validate $? "enabling mongodb"

systemctl start mongod &>> $logfile
validate $? "starting mongodb"

