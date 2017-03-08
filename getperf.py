#!/usr/bin/python

import os
import platform
import sys
import binascii
from socket import *
import struct

def recv_bytes (sock, n):
    data = ''
    while len(data) < n:
        chunk = sock.recv(n - len(data))
        if (chunk == ''):
            break
        data += chunk
    return data

def sendQuery (sock, query):
    packer = struct.Struct('I')
    unpacker = struct.Struct('I')
    pd = packer.pack(len(query.encode('utf-8')))
    sock.send(pd)
    sock.send(query)
    data = recv_bytes(sock, 4)
    slen = struct.unpack('I', data)[0]
    values = sock.recv(int(slen))
    k = values.split()
    return k

def do_arm64 (sock):
    query_toplev = "CPU_CYCLES,INST_RETIRED,STALLED_CYCLES_FRONTEND,STALLED_CYCLES_BACKEND\0"
    query_br = "BRANCH_MISPRED,BRANCH_PRED,L1I_CACHE_REFILL,L1I_CACHE_ACCESS,L1D_CACHE_REFILL,L1D_CACHE_ACCESS\0"
    try:
        while True:
            k = sendQuery(sock, query_toplev)
            ipc = float(k[1]) / float(k[0])
            fes = float(k[2]) / float(k[0]) * 100.0
            bes = float(k[3]) / float(k[0]) * 100.0
            out = format("IPC=%2.2f - FRONTEND=%2.2f%% - BACKEND=%2.2f%%. " % (ipc, fes, bes))
            sys.stdout.write(out)
            k = sendQuery(sock, query_br)
            brpred = (float(k[0]) / float(k[1])) * 100.0
            dmiss = (float(k[2]) / float(k[3])) * 100.0
            imiss = (float(k[4]) / float(k[5])) * 100.0
            out = format("Branch mispred rate=%2.2f%%, " % brpred)
            sys.stdout.write(out)
            out = format("L1I miss=%2.2f%%, " % imiss)
            sys.stdout.write(out)
            out = format("L1D miss=%2.2f%%.\r" % dmiss)
            sys.stdout.write(out)
            sys.stdout.flush()
    finally:
        sock.close()

def do_amd64 (sock):
    try:
        while True:
            k = sendQuery(sock, query_toplev)
            ipc = float(k[1]) / float(k[0])
            fes = float(k[2]) / float(k[0]) * 100.0
            bes = float(k[3]) / float(k[0]) * 100.0
            out = format("IPC=%2.2f - FRONTEND=%2.2f%% - BACKEND=%2.2f%%. " % (ipc, fes, bes))
            sys.stdout.write(out)
            k = sendQuery(sock, query_br)
            brpred = (float(k[0]) / float(k[1])) * 100.0
            dmiss = (float(k[2]) / float(k[3])) * 100.0
            imiss = (float(k[4]) / float(k[5])) * 100.0
            out = format("Branch mispred rate=%2.2f%%, " % brpred)
            sys.stdout.write(out)
            out = format("L1I miss=%2.2f%%, " % imiss)
            sys.stdout.write(out)
            out = format("L1D miss=%2.2f%%.\r" % dmiss)
            sys.stdout.write(out)
            sys.stdout.flush()
    finally:
        sock.close()


def main ():
    sock = socket(AF_INET, SOCK_STREAM)
    server_address = (sys.argv[1], 9999)

    sock = socket(AF_INET, SOCK_STREAM)
    sock.connect(server_address)

    arch = sock.recv(1)
    if arch == 'a':
        print "arm64"
        do_arm64 (sock)
    elif arch == 'x':
        print "x86_64"
        do_x86_64 (sock)

if __name__ == "__main__":
    main()

