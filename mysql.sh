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


dnf module disable mysql -y &>> $logfile
validate "disabling mysql"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $logfile

dnf install mysql-community-server -y &>> $logfile
validate "installing mysql"

systemctl enable mysqld &>> $logfile
validate "mysqld is enabling"

systemctl start mysqld &>> $logfile
validate "mysqld is starting"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $logfile
validate "setting mysql root password"





