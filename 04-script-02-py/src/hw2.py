#!/usr/bin/env python3

import os

bash_command = ["cd /mnt/d/2022/!EDUC/Netology/DevOps/HomeWorks/devops-netology_/", "git status"]
path = bash_command[0].replace('cd ', '')
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(f"{path}{prepare_result}")