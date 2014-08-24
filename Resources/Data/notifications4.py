__author__ = 'gdyer'
import csv,datetime,os
from os.path import expanduser
home = expanduser("~")
divs = []
# URL for notifications for 14-15 year:
# http://www.mbs.net/cf_calendar/export.cfm?type=export&list=4486&athlist=&loopstart=09/01/2014&loopend=06/30/2015
# ^ Click on CSV after checking "school calendar"

# find new general alert possibilities here: http://www.mbs.net/page.cfm?do=calsearch&p=1424&keywords=service&eventsorting=past

def hasNumbers(inputString):
    return any(char.isdigit() for char in inputString)

# def compare_weeks(f, s):
#     return 1 if ((datetime.datetime.strptime(f, '%m/%d/%Y').isocalendar()[1]) == (datetime.datetime.strptime(s, '%m/%d/%Y').isocalendar()[1])) else 0
#
# def compare_days(f, s):
#     return 1 if (datetime.datetime.strptime(f, '%m/%d/%Y').date() < datetime.datetime.strptime(s, '%m/%d/%Y').date()) else 0

def return_week(d):
    return (datetime.datetime.strptime(d, '%m/%d/%Y').isocalendar()[1])

def weeksInArray(array):
    for foo in array:
        if return_week(foo) not in divs:
            divs.append(return_week(foo))

def list_contains(list, needle):
    for foo in list:
        if needle in foo:
            return True
    return False

events = []
with open(home + '/Downloads/calendar.csv', 'r') as f:
    reader = csv.reader(f)
    for line in reader:
      events.append(line)

days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
weekdays = days[0:5]

du_dates = []
du_names = [] # better than a for-loop assigning a generic message because these typically have a reason for dressing-up
rejected = []
a_weeks = []
compiled_a_weeks = []
b_weeks = []
compiled_b_weeks = []
general = []
gen_dates = []
interval_dates = 0
for foo in events:
    ret = foo[0].lower()
    if "dress" in ret and "middle school" not in ret and " ms " not in ret:
        if "up" in ret:
            # hopefully this is enough to avoid Middle School-exclusive dates and dress *down* days
            du_dates.append(foo[1])
            du_names.append(foo[0])
        else:
            rejected.append(foo[0])
    if "a week" in ret:
        if return_week(foo[1]) not in compiled_a_weeks:
            compiled_a_weeks.append(return_week(foo[1]))            
            a_weeks.append(foo[1])
    if "b week" in ret:
        if return_week(foo[1]) not in compiled_b_weeks:        
            compiled_b_weeks.append(return_week(foo[1]))
            b_weeks.append(foo[1])
    if ('end of second semester' in ret or 'end of 2nd semester' in ret or 'last day of academic classes' in ret or 'last day of 2nd semester' in ret) and interval_dates < 1:
        interval_dates += 1
        general.append('The second semester ends today. Have a great summer!')
        gen_dates.append(foo[1])
        print('school ends on ' + foo[1] + '\n')
    if 'classes begin' in ret or 'classes start' in ret:
        print('COUNTDOWN\nschool starts on ' + foo[1])
    if 'end of first semester' in ret or 'end of 1st semester' in ret:
        general.append('The first semester ends today.')
        gen_dates.append(foo[1])
    if 'ap exams' in ret and list_contains(general , 'APs') is False:
        general.append('Best of luck on APs!')
        gen_dates.append(foo[1])

#07/18/2014 23 31 | Today: dress-up day
#05/20/2014 08 00 | Today: dress-up day^
#03/24/2014 08 00 | This week: B
#07/18/2014 23 33 | This week: B
#04/21/2014 09 00 | This week: B
#05/05/2014 08 00 | This week: B
#05/19/2014 08 00 | This week: B^
#07/18/2014 23 32 | Today: end of 3/4
#05/30/2014 08 00 | See you in September!
#02/19/2014 08 00 | Monday, A schedule
#05/08/2014 08 00 | Tomorrow: service hours due

core_string = ""
if len(du_dates) is not len(du_names):
    print("There's a PROBLEM here: the count of dress up dates is not equal to the count of dress up descriptions.")
    raise SystemExit

for x in range(0, len(du_dates)):
    core_string += (du_dates[x] + ' $ | ' + du_names[x])
    if x < len(du_dates)-1:
        core_string += '\n'

core_string += '^\n'

for x in range(0, len(a_weeks)):
    core_string += (a_weeks[x] + ' 08 00 | It\'s an A week')
    core_string += '\n'

for x in range(0, len(b_weeks)):
    core_string += (b_weeks[x] + ' 08 00 | It\'s a B week')
    if x < len(b_weeks)-1:
        core_string += '\n'

core_string += '^\n'

if len(general) is not len(gen_dates):
    print("There's a PROBLEM here: the count of general dates is not equal to the count of general descriptions.")
    raise SystemExit

for x in range(0, len(general)):
    core_string += (gen_dates[x] + ' 08 00 | ' + general[x])
    if x < len(general)-1:
        core_string += '\n'

# print(core_string)
old_notifs = ''

try:
    f = open(home + "/Dropbox/MBS-Now/Resources/notifs.txt", "r")
    try:
        old_notifs = f.read()
    finally:
        f.close()
except IOError:
    pass

try:
    f = open(home + "/Dropbox/MBS-Now/Resources/old_notifs.txt", "w")
    try:
        f.writelines(old_notifs)
    finally:
        f.close()
except IOError:
    pass

try:
    f = open(home + "/Dropbox/MBS-Now/Resources/notifs.txt", "w")
    try:
        f.writelines(core_string)
        print('\nWrote Resources/notifs.txt and saved old pack at Resources/old_notifs.txt')
    finally:
        f.close()
except IOError:
    pass

print("\nDRESS-UP DAYS\nrejected:", rejected)
p = input('Auto-push, making this pack live immediately? (p/anything): ')
if p is 'p':
    c = input('Commit message ("q" to quit): ')
    if c is not "q":
        to_cd = home + "/Dropbox/MBS-Now/"
        os.chdir(to_cd)
        os.system("git add -A Resources/")
        os.system("git add -A MBS_Now/")
        os.system("git add README.md")
        os.system("git commit -m '" + c + "'")
        os.system("git remote rm origin")
        os.system("git remote add origin https://github.com/mbsdev/MBS-Now.git")
        os.system("git push origin master")