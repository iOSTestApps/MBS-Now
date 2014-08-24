__author__ = 'gdyer'
import urllib.request, urllib.parse, urllib.error, re, itertools, operator

def avg(list):
    sum = 0
    for elm in list:
        sum += float(elm[0])
    return(str(sum/(len(list)*1.0)))

def intavg(list):
    sum = 0
    for elm in list:
        sum += elm
    return(str(sum/(len(list)*1.0)))

def int_from_str(ins):
    s = ''.join(x for x in ins if x.isdigit())
    return int(s)

def pavg(arr, mes):
    print(mes + ': ' + str(avg(arr)))

def piavg(arr, mes):
    print(mes + ': ' + str(intavg(arr)))

def ppiavg(arr, mes):
    print(mes + ': ' + str(100 * float(intavg(arr))) + '%')

def most_common(L):
  # get an iterable of (item, iterable) pairs
  SL = sorted((x, i) for i, x in enumerate(L))
  # print 'SL:', SL
  groups = itertools.groupby(SL, key=operator.itemgetter(0))
  # auxiliary function to get "quality" for an item
  def _auxfun(g):
    item, iterable = g
    count = 0
    min_index = len(L)
    for _, where in iterable:
      count += 1
      min_index = min(min_index, where)
    # print 'item %r, count %r, minind %r' % (item, count, min_index)
    return count, -min_index
  # pick the highest-count/earliest item
  return max(groups, key=_auxfun)[0]

url = 'http://gdyer.de/data4.txt'
f = urllib.request.urlopen(url)
data = f.readlines()

#Today reloads 9, more taps 93, device name recorded on 2014-07-21 11:14:40  0000

osversion = []
height = []
width = []
forms = []
offline = []
contacts = []
launches = []
nowv = []
sent_before = []
ms_grade = []
dress = []
ab = []
gen = []
db_logins = []
club_autocheck = []
rsvps_sent = []
txtsch_notifs = []
meetings_viewed = []
self_data = []
fullsch_views = []
service_views = []
whatsnew_time = []
show_tmrw_txtsch = []
lunchviews = []
all_news = []
today_first = []
today_reloads = []
today_hamburger = []
names = []
du_receipt = 0
black = tan = default = 0
iphones = ipads = sims = 0
ms = us = 0

for foo in data:
    bar = foo.decode().split('\n\n')
    for chi in bar:
        ret = chi.split(',')
        if len(ret) > 1:
            osversion.append(re.findall('\d+.\d+', ret[1]))
            if ret[2] is ' model iPhone':
                iphones += 1
            elif ret[2] is ' model iPad':
                ipads += 1
            elif 'Simulator' in ret[2]:
                continue
            height.append(re.findall('\d+.\d+', ret[3]))
            width.append(re.findall('\d+.\d+', ret[4]))
            forms.append(int_from_str(ret[5]))
            offline.append(int_from_str(ret[6]))
            contacts.append(int_from_str(ret[7]))
            launches.append(int_from_str(ret[8]))
            nowv.append(re.findall('\d+.\d+', ret[9]))
            sent_before.append(int_from_str(ret[10]))
            ms_grade.append(int_from_str(ret[11]))
            dress.append(int_from_str(ret[12]))
            ab.append(int_from_str(ret[13]))
            gen.append(int_from_str(ret[14]))
            db_logins.append(int_from_str(ret[15]))
            # club_autocheck.append(int_from_str(ret[16]))
            if ret[16] is ' button color (null)' or ' button color grey' or ' button color default':
                default += 1
            elif ret[16] is ' button color black':
                black += 1
            elif ret[16] is ' button color tan':
                tan += 1
            club_autocheck.append(int_from_str(ret[17]))
            rsvps_sent.append(int_from_str(ret[18]))
            txtsch_notifs.append(int_from_str(ret[19]))
            meetings_viewed.append(int_from_str(ret[20]))
            if ret[21] == ' division MS':
                ms += 1
            elif ret[21] == ' division US':
                us += 1
            self_data.append(int_from_str(ret[22]))
            fullsch_views.append(int_from_str(ret[23]))
            service_views.append(int_from_str(ret[24]))
            whatsnew_time.append(int_from_str(ret[25]))
            show_tmrw_txtsch.append(int_from_str(ret[26]))
            lunchviews.append(int_from_str(ret[27]))
            if (re.findall('\d+:\d+\d+', ret[28])):
                du_receipt += 1
            all_news.append(int_from_str(ret[29]))
            today_first.append((int_from_str(ret[30])))
            today_reloads.append((int_from_str(ret[31])))
            today_hamburger.append((int_from_str(ret[32])))
            names.append(str(ret[33]).replace(" device name ", ""))
pavg(osversion, 'iOS version lower bound')
pavg(height, 'Average device height')
pavg(width, 'Average device width')
piavg(forms, 'Average # of forms tapped')
piavg(offline, 'Average # of offline schedules viewed')
piavg(contacts, 'Average # of contacts copied')
piavg(launches, 'Average # of launches')
pavg(nowv, 'Lower bound MBS Now version (rounds down third decimal)')
ppiavg(sent_before, 'Users who have sent data before')
piavg(ms_grade, 'Average MS grade')
ppiavg(dress, 'Dress-up notification adoption')
ppiavg(ab, 'A/B notification adoption')
ppiavg(gen, 'General notification adoption')
piavg(db_logins, 'Average # of database logins copied')
ppiavg(club_autocheck, 'In-app club notification adoption')
piavg(rsvps_sent, 'Average # of RSVPs to club meetings sent')
piavg(txtsch_notifs, 'Average # of text schedule notifications received (from Today cell)')
piavg(meetings_viewed, 'Average # of clubs meetings viewed')
piavg(self_data, 'Average # of times data was emailed by user')
piavg(fullsch_views, 'Average # of full schedule (in web view) views from Today (by tapping schedule image cell)')
piavg(service_views, 'Average # of service posts viewed')
piavg(whatsnew_time, 'Average # of seconds spent in organic (upon updating) display of "What\'s New"')
ppiavg(show_tmrw_txtsch, 'Always show tomorrow\'s text-based schedule in Today adoption')
piavg(lunchviews, 'Average # of lunch menu views from Today')
ppiavg(all_news, 'Show all news in Today adoption')
ppiavg(today_first, 'Show Today as first screen adoption')
piavg(today_reloads, 'Average # of Today reloads')
piavg(today_hamburger, 'Average # of Today "hamburger" taps')

print('Most common device name: ' + most_common(names))
print(str(du_receipt) + ' users have chosen a personal dress-up receipt time')
print(str(us) + ' upper-school affiliated users, ' + str(ms) + ' middle-school affiliated users')
print(str(black) + ' users have black buttons, ' + str(tan) + ' have tan buttons, ' + str(default) + ' have grey/default buttons')
print(str(iphones) + ' iPhone, ' + str(ipads) + ' iPad = ' + str(ipads + iphones + sims) + ' total uploads')