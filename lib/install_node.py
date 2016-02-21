#!/bin/python

import os
import re
import urllib2
from subprocess import call
from time import sleep


# File to save node as
node_file = 'node.tar.gz'
# Link for latest node versions
links = urllib2.urlopen("http://nodejs.org/dist/latest-v4.x/").read().split('\n')

# Find the correct version of node
for link in links:
    match = re.search(">(node-.*-linux-x64.tar.gz)<", link)
    if match is not None:
        node_link = 'http://nodejs.org/dist/latest-v4.x/{0}'.format(match.group(1))
        break

# Download node
u = urllib2.urlopen(node_link)
f = open(node_file, 'wb')
meta = u.info()
file_size = int(meta.getheaders('Content-Length')[0])
file_size_dl = 0
block_sz = 8192
last_percent = 0
while True:
    buffer = u.read(block_sz)
    if not buffer:
        break

    file_size_dl += len(buffer)
    f.write(buffer)
    current_percent = file_size_dl * 100 / file_size
    if last_percent != current_percent:
        status = r'Downloading NodeJS .......... [{0}%]'.format(current_percent)
        status = status + chr(8)*(len(status)+1)
        print status
        last_percent = current_percent

print 'Downloaded NodeJS'

sleep(2)

print 'Installing NodeJS'

sleep(2)

# Install node
call(['tar', '--strip-components', '1', '-zxvf', 'node.tar.gz', '-C', '/usr/local'])
call(['ln', '-s', '/usr/local/bin/node', '/usr/bin/node'])
call(['ln', '-s', '/usr/local/lib/node', '/usr/lib/node'])
call(['ln', '-s', '/usr/local/bin/npm', '/usr/bin/npm'])
call(['ln', '-s', '/usr/local/bin/node-waf', '/usr/bin/node-waf'])

# Clean up downlaoded file
os.remove(node_file)
print 'Installed NodeJS'

sleep(2)
f.close()
