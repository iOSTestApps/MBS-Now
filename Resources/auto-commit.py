import os
from os.path import expanduser
home = expanduser("~")

auto_commit = input('This will add and push /MBS_now and /Resources. You\'re sure ? (y/n) ')
if auto_commit is 'y':
    to_cd = home + "/Dropbox/MBS-Now/"
    os.chdir(to_cd)
    os.system("git add -A Resources/")
    os.system("git add -A MBS_Now/")
    os.system("git commit -m 'lunch menus for this week'")
    os.system("git remote rm origin")
    os.system("git remote add origin https://github.com/gdyer/MBS-Now.git")
    os.system("git push origin master")