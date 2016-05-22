#!/usr/bin/python

# native-java-agent
#
# Copyright (C) 2015 Linaro Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Author: Steve Capper <steve.capper@linaro.org>

import os
import platform
import sys
import re
import subprocess

def getsourceline (classname, filename, line):
    searchname = ""
    for component in classname.split('.')[:-1]:
        searchname += component + "/"

    searchname += filename

    try:
        for searchpath in os.environ['JAVA_SOURCE_PATH'].split(':'):
            fullname = searchpath + "/" + searchname

            if os.path.isfile(fullname):
                with open(fullname) as f:
                    content = f.readlines()
                    return content[line - 1]
    except KeyError:
        pass

    return None

objectname = sys.argv[len(sys.argv) - 1]

if not re.match('/tmp/perf-[0-9]+.map', objectname):
    newargs = sys.argv
    newargs[0] = 'objdump'
    retcode = subprocess.call(newargs)
    sys.exit(retcode)

objectdir = objectname + '.d'

startaddress = 0
endaddress = 0

startsmatch = '--start-address='
stopsmatch = '--stop-address='

for argument in sys.argv:
    if argument.startswith(startsmatch):
        startaddress = int(argument[len(startsmatch):], 16)

    elif argument.startswith(stopsmatch):
        endaddress = int(argument[len(stopsmatch):], 16)

filename = objectdir + '/' + format(startaddress, 'x') + '.dump'

newargs = ['objdump', '-b', 'binary', '--start-address=0x' + format(startaddress, 'x'), \
    '--stop-address=0x' + format(endaddress, 'x'), \
    '--adjust-vma=0x' + format(startaddress, 'x'), \
    '--architecture=' + platform.machine(), '--no-show-raw', '-D', filename]

retproc = subprocess.Popen(newargs, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
outputlines = retproc.stdout.read().splitlines()

midict = {}
mifilename = objectdir + '/' + format(startaddress, 'x') + '.methodinfo'
try:
    with open(mifilename, 'r') as f:
        milines = f.read().splitlines()

        for miline in milines:
            sline = miline.split(':')
            if len(sline) != 6:
                continue

            pc = int(sline[0], 16)

            if (int(sline[5]) != -1):
                sourceline = getsourceline(sline[1], sline[2], int(sline[3]))
            else:
                sourceline = None

            rhs = sline[1]
            rhs += " <" + sline[4] + "+" + sline[5] + ">"
            rhs += " " + sline[2] + ":" + sline[3] + ":"

            if sourceline:
                rhs += "\n" + sourceline

            if midict.has_key(pc):
                midict[pc] = rhs + '\n' + midict[pc]
            else:
                midict[pc] = rhs
except IOError:
    pass

for line in outputlines:
        sublines = line.split(':')
        try:
            pc = int(sublines[0], 16)

            if midict.has_key(pc):
                print midict[pc]
        except ValueError:
            pass

	print line
