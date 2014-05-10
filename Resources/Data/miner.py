# works with Python 3 and higher
import urllib.request, urllib.parse, urllib.error, re

def avg(list):
    sum = 0
    for elm in list:
        sum += float(elm[0])
    return(str(sum/(len(list)*1.0)))

url = 'http://campus.mbs.net/mbsnow/scripts/data.txt'
f = urllib.request.urlopen(url)
data = f.read()

f = urllib.request.urlopen(url)
data = f.readlines()
version = []
osversion = []
lunchavg = []
dudavg = []
abavg = []
genavg = []
formsavg = []
screenheightavg = []
screenwidthavg = []
msgrade = []
avglaunches = []
offlinetappedavg = []
for foo in data:
    bar = foo.decode().split('\n\n')
    for chi in bar:
        ret = chi.split(',')
        if len(ret) > 1:
            version.append(re.findall('\d+.\d+', ret[10]))
            osversion.append(re.findall('\d+.\d+', ret[1]))
            lunchavg.append(re.findall('\d+', ret[7]))
            dudavg.append(re.findall('\d+', ret[13]))
            abavg.append(re.findall('\d+', ret[14]))
            genavg.append(re.findall('\d+', ret[15]))
            formsavg.append(re.findall('\d+', ret[5]))
            screenheightavg.append(re.findall('\d+', ret[3]))
            screenwidthavg.append(re.findall('\d+', ret[4]))
            msgrade.append(re.findall('\d+', ret[12]))
            avglaunches.append(re.findall('\d+', ret[9]))
            offlinetappedavg.append(re.findall('\d+', ret[6]))

print('iOS version average: > '+ avg(osversion))
print('MBS Now version average: ' + avg(version))
print('Menus tapped average: ' + avg(lunchavg))
print('Dress-up notification recipients (1 is all, 0 is none) : ' + avg(dudavg))
print('A/B notification recipients (1 is all, 0 is none) : ' + avg(abavg))
print('General notification recipients (1 is all, 0 is none) : ' + avg(genavg))
print('Forms tapped average: ' + avg(formsavg))
print('Average screen dimensions: (' + avg(screenwidthavg) + ',' + avg(screenheightavg) + ')')
print('Average MS grade: ' + avg(msgrade))
print('Average number of launches: ' + avg(avglaunches))
print('Average number of offline schedules tapped: ' + avg(offlinetappedavg))
print('Total number of uploads: ' + str(len(osversion)))