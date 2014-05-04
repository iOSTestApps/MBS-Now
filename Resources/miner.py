# works with Python 3.3
import urllib.request, urllib.parse, urllib.error, re

def avg(list):
    sum = 0
    for elm in list:
        sum += float(elm[0])
    print(str(sum/(len(list)*1.0)))

url = 'http://campus.mbs.net/mbsnow/scripts/data.txt'
f = urllib.request.urlopen(url)
data = f.read()

f = urllib.request.urlopen(url)
data = f.readlines()
version = []
for foo in data:
    bar = foo.decode().split('\n\n')
    for chi in bar:
        ret = chi.split(',')
        if len(ret) > 1:
            version.append(re.findall('\d+.\d+', ret[10]))

avg(version)