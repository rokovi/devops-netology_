#!/usr/bin/env python3

import os
import sys

if not os.path.exists(sys.argv[1] + '.git'):
    print('This is not a git repository')
else:
    place = 'cd ' + sys.argv[1]
    bash_command = [place, "git status"]
    result_os = os.popen(' && '.join(bash_command)).read()
    for result in result_os.split('\n'):
        if result.find('modified') != -1:
            prepare_result = result.replace('\tmodified:   ', '')
            print(f"{sys.argv[1]}{prepare_result}")
