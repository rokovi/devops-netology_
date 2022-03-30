#!/usr/bin/env python3

import socket
import ast
import os
import json
import yaml

# set list
hostnames = ['drive.google.com', 'mail.google.com', 'google.com']


def d_create():
    # set empty dict
    mydict = {}
    # fill mydict
    for host in hostnames:
        ip = socket.gethostbyname(host)
        mydict[host] = ip
    # save to json
    for k in mydict:
        create_oneline_dict = {k: mydict[k]}
        with open(f'{k}.json', 'w') as f:
            json.dump(create_oneline_dict, f)
        with open(f'{k}.yaml', 'w') as ff:
            yaml.dump(create_oneline_dict, ff)
    # save mydict to file
    file_w = open("dict.txt", "w")
    file_w.write(str(mydict))
    file_w.close()
    return mydict


def show():
    # show urls with IPs
    for host in hostnames:
        ip = socket.gethostbyname(host)
        print(f'{host} - {ip}')
    d_create()


def compare():
    # read form previously crated file
    file_r = open("dict.txt", "r")
    # make dict from str via ast module
    o_dict = ast.literal_eval(file_r.read())
    file_r.close()
    # cause o_dict already read in step above we can rewrite
    curr_dict = d_create()
    if curr_dict == o_dict:
        show()
    else:
        mod = [k for k in curr_dict if curr_dict[k] != o_dict[k]]
        same = [k for k in curr_dict if curr_dict[k] == o_dict[k]]
        # create new empty dict for parse
        d_json_mod = {}
        for k in mod:
            print('[ERROR]', k, 'IP mismatch:', o_dict[k], curr_dict[k])
            # fill d_json_mod dict with changed IPs
            d_json_mod[k] = curr_dict[k]
            # create json file
        for kk in d_json_mod:
            compare_oneline_dict = {kk: d_json_mod[kk]}
            with open(f'{kk}.json', 'w') as f:
                json.dump(compare_oneline_dict, f)
            # create yaml file
            with open(f'{kk}.yaml', 'w') as ff:
                yaml.dump(compare_oneline_dict, ff)
        for k in same:
            print(k, '-', curr_dict[k])


if not os.path.isfile("dict.txt"):
    show()
else:
    compare()
