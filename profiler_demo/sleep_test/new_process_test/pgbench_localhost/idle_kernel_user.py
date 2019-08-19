#Raymond Schooley
#Reference https://www.geeksforgeeks.org/socket-programming-python/
import json
import os, sys
import socket
import pickle
import struct

path = sys.argv[1]
dirs = os.listdir( path )

#open socket and connect
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    #caron will be running on localhost port 2004
    host_ip = "127.0.0.1"
    port = 2004
    s.connect((host_ip, port)) 

    for file in dirs:
        with open(path+file) as f:
            metrics = list()
            # Deserialize into python object
            y = json.load(f)
            time = y["currentTime"]
            metrics.append(("vCpuIdleTime", (time, y["vCpuIdleTime"])))
            metrics.append(("vCpuTimeKernelMode", (time, y["vCpuTimeKernelMode"])))
            metrics.append(("vCpuTimeUserMode", (time, y["vCpuTimeUserMode"])))
            #print "Current Time:", y["currentTime"]
            #print "vCpuIdleTime:", y["vCpuIdleTime"]
            #print "vCpuTimeKernelMode:", y["vCpuTimeKernelMode"]
            #print "vCpuTimeUserMode:", y["vCpuTimeUserMode"]

            #pickle the list of metrics and create a packet to be sent to carbon server
            payload = pickle.dumps(metrics, protocol=2)
            header = struct.pack("!L", len(payload))
            message = header + payload
            s.send(message)
        
            #print server message
            #print s.recv(1024)
    s.close()
except socket.error as err: 
    print "socket creation or connection failed with error %s" %(err) 


