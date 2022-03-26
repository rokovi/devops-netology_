#!/usr/bin/env bash
ip_arr=("213.177.125.154" "127.0.0.1" "90.156.141.137")

i=0
for host in ${ip_arr[@]}
do
 ii=0
  while (($ii < 5))
  do
      curl http://${ip_arr[$i]}
       if (($? == 0 ))
        then
            echo "${ip_arr[$i]} works" >> check.log
        else
            echo "smth wrong with ${ip_arr[$i]} check this out" >> error.log
            exit 1
       fi
     ((ii++))
  done
 ((i++))
done
