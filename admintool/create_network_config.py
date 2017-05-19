#!/usr/bin/env python
# coding=utf-8

import os
import copy
import sys
import math

def make_netconfig():
	nid = int(sys.argv[2])
	path = os.path.join(sys.argv[1],"node" + str(nid))
	ip_list = (sys.argv[4]).split(',')
	port = 4000
	net_config_name = "config.node" + str(nid)
	size = int(sys.argv[3])
	dump_path = os.path.join(path, net_config_name)
	f = open(dump_path, "w")
	f.write("port = " + str(port) + "\n")
	f.write("max_peer = " + str(size - 1) + "\n")
	del ip_list[nid]
	for addr in ip_list :
		addr_list = addr.split(':')
		f.write("[[peers]]" + "\n")
		ip = addr_list[0]
		f.write("ip = " + ip + "\n")
		port = addr_list[1]
		f.write("port = " + str(port) + "\n") 

	f.close()

make_netconfig()
