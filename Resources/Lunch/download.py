# works with Python 3 and above
import urllib.request, urllib.parse, urllib.error, datetime, os
from os.path import expanduser
home = expanduser("~")

# run this on a SATURDAY, SUNDAY, or MONDAY if you only want to do it once per week.

days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
weekdays = days[0:5]
dir = home + "/Dropbox/MBS-Now/Resources/Lunch/"

last = 0
for i in range(len(days)):
    q = (datetime.datetime.today().weekday() + i) % len(days)
    if (days[q] in weekdays):
        unformatted = datetime.date.today() + datetime.timedelta(days=i)
        last = unformatted
        formatted = unformatted.strftime('%m/%d/%y')
        url = 'http://myschooldining.com/mbs/?cmd=pdfmenuday&currDT=' + formatted
        print(url)
        f = urllib.request.urlopen(url)
        data = f.read()
        with open(dir + days[q] + ".pdf", "wb") as code:
            code.write(data)

# now do the monthly menu
if (last.month != datetime.datetime.today().month):
    print("Conflicting months detected. Storing next month (" + last.month + ") as 'Month2.pdf'.")
    url = 'http://myschooldining.com/mbs/createPDFMenuMonthAct.cfm?currDT=' + last.strftime('%m/%d/%y')
    print(url)
    f = urllib.request.urlopen(url)
    data = f.read()
    with open(dir + "Month2.pdf", "wb") as code:
        code.write(data)

url = 'http://myschooldining.com/mbs/createPDFMenuMonthAct.cfm?currDT=' + datetime.datetime.today().strftime('%m/%d/%y')
print(url)
f = urllib.request.urlopen(url)
data = f.read()
with open(dir + "Month.pdf", "wb") as code:
    code.write(data)

print('Download successful. Files saved in ' + dir)
auto_commit = input('Push to GitHub automatically? (y/n) ')
if auto_commit is 'y':
	to_cd = home + "/Dropbox/MBS-Now/"
	os.chdir(to_cd)
	os.system("git add -A Resources/")
	os.system("git commit -m 'lunch menus for this week'")
	os.system("git remote rm origin")
	os.system("git remote add origin https://github.com/mbsdev/MBS-Now.git")
	os.system("git push origin master")
else:
    print('Leaving the updating to you.')