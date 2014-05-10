import csv
from datetime import datetime
from os.path import expanduser

# URL for notifications for 14-15 year: http://www.mbs.net/cf_calendar/export.cfm?type=export&list=4486&athlist=&loopstart=09/01/2014&loopend=06/30/2014 << Click on CSV

def hasNumbers(inputString):
    return any(char.isdigit() for char in inputString)

home = expanduser("~")
events = []
with open(home + '/Downloads/calendar.csv', 'r') as f:
    reader = csv.reader(f)
    for line in reader:
      events.append(line)


days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
weekdays = days[0:5]

dress_dates = "NSArray *dressUpDates = @["
a_weeks = "NSArray *aWeekDates = @["
b_weeks = "NSArray *bWeekDates = @["
accepted = []
rejected = []
weekdays = [] # yes, the calendar is likely all weekdays already, but it's good to be absolutely positive
l = len(a_weeks)
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
        a_weeks += '@"' + foo[1] + '", '
    if "b week" in ret:
        b_weeks += '@"' + foo[1] + '", '
    if 'end of second semester' in foo[0].lower() or 'end of 2nd semester' in foo[0].lower():
        print('school ends on ' + foo[1])
    if 'classes begin' in foo[0].lower() or 'classes start' in foo[0].lower():
        print('school starts on' + foo[1])

print("Rejected dress-up days (don't contain 'up'): ", rejected)
print("Accepted dress-up days: ", accepted)
print("\n")
print(a_weeks[:len(a_weeks)-2] + "];")
print(b_weeks[:len(b_weeks)-2] + "];")
print(dress_dates[:len(dress_dates)-2] + "];")