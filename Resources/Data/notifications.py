import csv

# URL for 14-15 year: http://www.mbs.net/cf_calendar/export.cfm?type=export&list=4486&athlist=&loopstart=09/01/2014&loopend=06/30/2014 << Click on CSV
home_name = 'lucasfagan'

events = []
with open('/Users/' + home_name + '/Downloads/calendar.csv', 'r') as f:
    reader = csv.reader(f)
    for line in reader:
      events.append(line)

dress_dates = "NSArray *dressUpDates = @["
a_weeks = "NSArray *aWeekDates = @["
b_weeks = "NSArray *bWeekDates = @["
accepted = []
rejected = []
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

print("Rejected dress-up days (don't contain 'up'): ", rejected)
print("Accepted dress-up days: ", accepted)
print("\n")
print(a_weeks[:len(a_weeks)-2] + "];")
print(b_weeks[:len(b_weeks)-2] + "];")
print(dress_dates[:len(dress_dates)-2] + "];")
