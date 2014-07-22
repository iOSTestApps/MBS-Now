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


#System name iPhone OS, version 7.1, model iPhone Simulator, height 480.00, width 320.00, forms tapped 2, offline tapped 0, contacts tapped 0, launches 0, version 4.0.9, sent before 0, MS grade 0, dress notifications 1, A/B notifications 1, General notifications 1, logins tapped 0, button color (null), club autocheck prefernce 1, RSVP button taps 0, text schedule notifications received 0, club meetings view 2, division MS, self-data exports 1, full schedule views from Today image cell 1, service postings viewed 0, time spent in first what's new screen 2, always show tomorrow's schedule in Today 0, lunch menu views from Today 205855552, dress-up notification receipt time (null), always show news articles in Today 0, show Today as launch screen 0, Today reloads 9, device name iPhone Simulator, recorded on 2014-07-21 11:14:40  0000

osversion = []
height = []
width = []
forms = []
offline = []
contacts = []

for foo in data:
    bar = foo.decode().split('\n\n')
    for chi in bar:
        ret = chi.split(',')
        if len(ret) > 1:
            osversion.append(re.findall('\d+.\d+', ret[1]))
            height.append(re.findall('\d+.\d+', ret[3]))
            width.append(re.findall('\d+.\d+', ret[4]))
            forms.append(re.findall('\d+.\d+', ret[5]))
            offline.append(re.findall('\d+.\d+', ret[6]))
            contacts.append(re.findall('\d+.\d+', ret[7]))
        
                    
print('iOS version average: > '+ avg(osversion))