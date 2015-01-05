import os,sys,urllib2,datetime,base64

try:
    import sendgrid
except ImportError:
    os.system("pip2.7 install sendgrid")
    sys.exit
if sys.version_info[0] >= 3:
    raise '\n\nfriend, you\'re using python 3, but all the cool kids (and this script) use 2.7. Please type "python2.7 <script-name> <github-username> <github-email>" instead.\n'


error = '\n\nplease rerun, entering your GitHub username as an argument: "python <script-name> <github-username> <github-email>"'
u = ''
e = ''
try:
    u = sys.argv[1]
    e = sys.argv[2]
except IndexError:
    sys.exit(error)

print('thanks, {0}; you may have to enter that again, though\n'.format(u))
os.system('git config --global user.email "{0}"'.format(e))
os.system('git config --global user.name "{0}"'.format(u))

if os.path.isdir('lunch'):
    os.system('rm -rf lunch')

os.system('git clone https://github.com/mbsdev/lunch')
os.chdir('lunch')

days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
weekdays = days[0:5]
readme = open('README.md', 'w')
readme.write('Updated lunch via `local-lunch.py`')
readme.close()
today = datetime.datetime.today()
print("\n\nin addition to pushing, this script will notify Graham to get the scheduled lunch script back on track\n\n")
for i in range(len(days)):
    q = (today.weekday() + i) % len(days)
    if (days[q] in weekdays):
        unformatted = today + datetime.timedelta(days=i)
        formatted = unformatted.strftime('%m/%d/%y')
        url = 'http://myschooldining.com/mbs/?cmd=pdfmenuday&currDT=' + formatted
        f = urllib2.urlopen(url)
        data = f.read()
        with open(days[q] + ".pdf", "wb") as code:
            code.write(data)
        f.close()
    
url = 'http://myschooldining.com/mbs/createPDFMenuMonthAct.cfm?currDT=' + today.strftime('%m/%d/%y')
f = urllib2.urlopen(url)
data = f.read()
with open("Month.pdf", "wb") as code:
    code.write(data)
f.close()

repo = ["git add -A .",
        "git commit -m 'local-lunch menus'",
        "git remote rm origin",
        "git remote add origin https://github.com/mbsdev/lunch.git",
        "git push origin master"
    ]

map(os.system, repo)

sg = sendgrid.SendGridClient(base64.b64decode('Z2R5ZXI='), base64.b64decode('bmFidTE0NDA='))
message = sendgrid.Mail()
message.add_to(base64.b64decode('R3JhaGFtIER5ZXIgPGdkeWVyMkBpbGxpbm9pcy5lZHU+'))
message.set_subject('Fix lunch script')
message.set_text('Graham,\n\nYour shitty MBS Now lunch script likely broke. {0} just had to run local-lunch.'.format(e))
message.set_from('Dear Friend '+e)
status, msg = sg.send(message)

os.chdir("../")
os.system("rm -rf lunch")
