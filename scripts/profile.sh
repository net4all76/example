#!/usr/bin/env bash

#find idle profile: if real1 is running, real2 is idle.  On the other side, real1 is idle.

function find_idle_profile() {

  RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/profile)

  if [ ${RESPONSE_CODE} -ge 400 ]
  then
    CURRENT_PROFILE=real2
  else
    CURRENT_PROFILE=$(curl -s http://localhost/profile)
  fi

  if [ "${CURRENT_PROFILE}" == real1 ]
  then
    IDLE_PROFILE=real2
  else
    IDLE_PROFILE=real
  fi

  echo "${IDLE_PROFILE}"
}

# find idle profile's port
function find_idle_port(){
  IDLE_PROFILE=$(find_idle_profile)

  if [ "${IDLE_PROFILE}" == real1 ]
  then
    echo "8081"
  else
    echo "8082"
  fi

}
