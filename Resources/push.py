import os
from os.path import expanduser
home = expanduser("~")
to_cd = home + "/Dropbox/MBS-Now/"
os.chdir(to_cd)

auto_pull = input('Auto-pull now? (y/anything): ')
if auto_pull is 'y':
	os.system("python Resources/pull.py")

auto_commit = input('Commit message (type "q" to quit): ')
if auto_commit is 'q':
	raise SystemExit

os.system("git add -A Resources/")
os.system("git add -A MBS_Now/")
os.system("git add README.md")
os.system("git commit -m '" + auto_commit.strip("'") + "'")
os.system("git remote rm origin")
os.system("git remote add origin https://github.com/mbsdev/MBS-Now.git")
os.system("git push origin master")