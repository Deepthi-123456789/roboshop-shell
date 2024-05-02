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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash  &>> $logfile
validate "downloading erlang script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $logfile
validate "downloading rabbitmq script"  

dnf install rabbitmq-server -y &>> $logfile 
validate "installing rabbitmq-server"

systemctl enable rabbitmq-server &>> $logfile 
validate "enabling rabbitmq"

systemctl start rabbitmq-server &>> $logfile 
validate "starting rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>> $logfile
validate "creating user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>> $logfile
validate "setting permissions"

