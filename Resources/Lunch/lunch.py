import urllib2, datetime, os

days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
weekdays = days[0:5]

today = datetime.datetime.now()
readme = open('lunch/README.md', 'w')
n = "Hello, I'm lunch-bot. I handle lunch for MBS Now. Here's what I did recently...\n\nI pushed these at midnight on " + today.strftime('%d %b %Y') + '|\n--- |\n'

for i in range(len(days)):
    q = (datetime.datetime.today().weekday() + i) % len(days)
    if (days[q] in weekdays):
        unformatted = datetime.date.today() + datetime.timedelta(days=i)
        formatted = unformatted.strftime('%m/%d/%y')
        url = 'http://myschooldining.com/mbs/?cmd=pdfmenuday&currDT=' + formatted
        n +=  "| " + url + '\n'
        f = urllib2.urlopen(url)
        data = f.read()
        with open("lunch/" + days[q] + ".pdf", "wb") as code:
            code.write(data)

url = 'http://myschooldining.com/mbs/createPDFMenuMonthAct.cfm?currDT=' + datetime.datetime.today().strftime('%m/%d/%y')
n += "| " + url + '\n'
f = urllib2.urlopen(url)
data = f.read()
with open("lunch/" + "Month.pdf", "wb") as code:
    code.write(data)

n += "| ...I also wanted to wish you an excellent " + days[today.weekday()] + " (times in EST/EDT)"
readme.write(n)
readme.close()
f.close()

os.system("cp lunch.py lunch")
os.chdir("lunch/")
os.system("git add -A .")
os.system("git commit -m 'lunch menus for this week (" + str(today.isocalendar()[1]) + "/52)'")
os.system("git remote rm origin")
os.system("git remote add origin git@github.com:mbsdev/lunch.git")
os.system("git push origin master")