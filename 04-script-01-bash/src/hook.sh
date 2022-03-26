#!/usr/bin/env bash
pattern="^\[[0-9]{2}-[a-z]{0,8}-[0-9]{2}-[a-z]{0,8}\]:\s.*"
check=$(echo "$1" | grep -Eoh "$pattern")

if [[ $? == 0 ]] && [[ ${#check} -le 30 ]]
then
   echo "Commit message policy is OK"
    exit 0
  else
   echo "Commit message polisy is violated. Example: \"[01-test-01-test]: some text\" and no more then 30 chars."
    exit 1
fi
###
