#!/usr/bin/env python3

import socket
import ast
import os

# set list
hostnames = ['drive.google.com', 'mail.google.com', 'google.com']


def d_create():
    # set empty dict
    mydict = {}
    # fill mydict
    for host in hostnames:
        ip = socket.gethostbyname(host)
        mydict[host] = ip
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
        for k in mod:
            print('[ERROR]', k, 'IP mismatch:', o_dict[k], curr_dict[k])
        for k in same:
            print(k, '-', curr_dict[k])


if not os.path.isfile("dict.txt"):
    show()
else:
    compare()
