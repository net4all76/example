#!/bin/bash

REPOSITORY=/home/ec2-user/app/step2
PROJECT_NAME=example

echo "> Copy build file"

cp $REPOSITORY/zip/*.jar $REPOSITORY/

echo "> Review  current application 'pid' "

CURRENT_PID=$(pgrep  -fl springboot2-webservice  | grep jar | awk '{print $1}' )

echo "Current application pid : $CURRENT_PID"

if [ -z "$CURRENT_PID"  ]; then
        echo "> Current application is not running. It can't terminate."
else
        echo ">  kill -15 $CURRENT_PID"
        kill -15 $CURRENT_PID
        sleep 5
fi

echo "> New application deploy"

JAR_NAME=$(ls -tr $REPOSITORY/*.jar | tail -n 1)

echo  "> JAR NAME : $JAR_NAME "

echo  "> make  $JAR_NAME executuable "

chmod  +x $JAR_NAME

echo  "> run  $JAR_NAME "

nohup java -jar \
        -Dspring.config.location=classpath:/application.properties,/home/ec2-user/app/application-oauth.properties,/home/ec2-user/app/application-real-db.properties \
        -Dspring.profiles.active=real   \
        $JAR_NAME >  $REPOSITORY/nohup.out 2>&1 &
