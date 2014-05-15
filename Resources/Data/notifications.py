import csv,datetime
from os.path import expanduser
home = expanduser("~")
divs = []
# URL for notifications for 14-15 year:
# http://www.mbs.net/cf_calendar/export.cfm?type=export&list=4486&athlist=&loopstart=09/01/2014&loopend=06/30/2014
# ^ Click on CSV

# TODO: general notifications; i.e. end of marking periods, community service deadlines, AP exam start date, more?

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

def gen(dict, data):
    for week in divs:
        dict[str(week)] = []
        for day in data:
            if return_week(day) == week:
                dict[str(week)].append(day)

def week_str(dict, name):
    str = 'NSArray *' + name + ' = @['
    for week in dict.keys():
        str += '@"' + dict[week][0] + '", '

    print(str[:len(str)-2] + "];")

events = []
with open(home + '/Downloads/calendar.csv', 'r') as f:
    reader = csv.reader(f)
    for line in reader:
      events.append(line)

days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
weekdays = days[0:5]

dress_dates = "NSArray *datesOnly = @["

accepted = []
rejected = []
a_weeks = []
b_weeks = []
for foo in events:
    ret = foo[0].lower()
    if "dress" in ret and "middle school" not in ret and " ms " not in ret:
        if "up" in ret:
            # hopefully this is enough to avoid Middle School-exclusive dates and dress DOWN days
            dress_dates += '@"' + foo[1] + '", '
            accepted.append(foo[0] + ": " + foo[1])
        else:
            rejected.append(foo[0])
    if "a week" in ret:
        a_weeks.append(foo[1])
    if "b week" in ret:
        b_weeks.append(foo[1])
    if 'end of second semester' in ret or 'end of 2nd semester' in ret:
        print('school ends on ' + foo[1])
    if 'classes begin' in ret or 'classes start' in ret:
        print('school starts on' + foo[1])

print('A/B WEEKS')
weeksInArray(a_weeks)
a = {}
b = {}
gen(a, a_weeks)
week_str(a, 'aWeeks')

divs = []
weeksInArray(b_weeks)
gen(b, b_weeks)
week_str(b, 'bWeeks')

print("\nDRESS_UP DAYS\nrejected:", rejected)
print("accepted:", accepted)
print(dress_dates[:len(dress_dates)-2] + "];")