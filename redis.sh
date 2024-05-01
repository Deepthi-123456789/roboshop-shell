#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "script name $0"

timestamp=$(date +%F-%H-%M-%S)

logfile="/tmp/$0-$timestamp.log"
exec &>logfile

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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y 
validate "installing remi-release"

dnf module enable redis:remi-6.2 -y 
validate "enabling redis"

dnf install redis -y 
validate "installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf

systemctl enable redis
validate "enabling redis"

systemctl start redis
validate "starting redis"
