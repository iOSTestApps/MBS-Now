import os
from os.path import expanduser
home = expanduser("~")

auto_commit = input('Commit message: ').strip("'")
to_cd = home + "/Dropbox/MBS-Now/"
os.chdir(to_cd)
os.system("git add -A Resources/")
os.system("git add -A MBS_Now/")
os.system("git add README.md")
os.system("git commit -m '" + auto_commit + "'")
os.system("git remote rm origin")
os.system("git remote add origin https://github.com/gdyer/MBS-Now.git")
os.system("git push origin master")