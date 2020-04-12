#!/usr/bin/env bash

ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname  $ABSPATH)
source ${ABSDIR}/profile.sh
source ${ABSDIR}/switch.sh

IDLE_PORT=$(find_idle_port)

echo "> Health Check Start!"
echo "> IDLE_PORT : $IDLE_PORT"
echo "> curl -s http://localhost:$IDLE_PORT/profile "
sleep 10

for RETRY_COUNT in {1..10}
do
  RESPONSE=$(curl -s http://localhost:${IDLE_PORT}/profile)
  UP_COUNT=$(echo ${RESPONSE} | grep 'real' | wc -l)

  if [ ${UP_COUNT} -ge 1 ]
  then
    echo "> Health check success!"
    switch_proxy
    break
  else
    echo "> Health check의 응답을 알 수 없거나 혹은 실행 상태가 아닙니다."
    echo "> Health check: ${RESPONSE}"
  fi

  if [ ${RETRY_COUNT} -eq 10 ]
  then
    echo "> Health check 실패."
    echo "> 엔진엑스에 연결하지 않고 배포를 종료합니다."
    exit 1
  fi

  echo "> Health check 연결 실패. 재시도..."
  sleep 10
done


REPOSITORY=/home/ec2-user/app/step2
PROJECT_NAME=example

echo "> Copy build file"

cp $REPOSITORY/zip/*.jar $REPOSITORY/

echo "> Review  current application 'pid' "

CURRENT_PID=$(pgrep  -fl $PROJECT_NAME  | grep jar | awk '{print $1}' )

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
        -Dspring.profiles.active=real \
        $JAR_NAME > $REPOSITORY/nohup.out 2>&1 &
