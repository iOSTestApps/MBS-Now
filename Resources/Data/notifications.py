import csv,datetime
from os.path import expanduser
home = expanduser("~")
divs = []

print("Hey! Since version 4.0, there's a better version of this script that actually generates notifs.txt for you. It's in this same directory called notifications4.py")

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
general = []
gen_dates = []
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

if len(general) > 0:
    print('GENERAL ALERTS')
    date_strings = "NSArray *datesStrings = @["
    desc = "NSArray *descriptions = @["
    for x in range(0, len(general)):
        date_strings += '"' + gen_dates[x] + '", '
        desc += '"' + general[x] + '", '
    print(date_strings[:len(date_strings)-2] + "];")
    print(desc[:len(desc)-2] + "];")

print('\nA/B WEEKS')
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