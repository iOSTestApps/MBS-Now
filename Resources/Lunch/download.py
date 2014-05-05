# works with Python 3 and above
# run this on a Saturday or Sunday
import urllib.request, urllib.parse, urllib.error, time, datetime

# CHANGE THIS:
home_name = "lucasfagan"
# ^ CHANGE THAT

days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
weekdays = days[0:5]

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
        with open("/Users/" + home_name + "/Dropbox/MBS-Now/Resources/Lunch/" + days[q] + ".pdf", "wb") as code:
            code.write(data)

# now do the monthly menu
if (last.month != datetime.datetime.today().month):
    print("Conflicting months detected. Storing next month as 'Month2.pdf'.")
    url = 'http://myschooldining.com/mbs/createPDFMenuMonthAct.cfm?currDT=' + last.strftime('%m/%d/%y')
    print(url)
    f = urllib.request.urlopen(url)
    data = f.read()
    with open("/Users/" + home_name + "/Dropbox/MBS-Now/Resources/Lunch/" + "Month2.pdf", "wb") as code:
        code.write(data)

url = 'http://myschooldining.com/mbs/createPDFMenuMonthAct.cfm?currDT=' + datetime.datetime.today().strftime('%m/%d/%y')
print(url)
f = urllib.request.urlopen(url)
data = f.read()
with open("/Users/" + home_name + "/Dropbox/MBS-Now/Resources/Lunch/" + "Month.pdf", "wb") as code:
    code.write(data)