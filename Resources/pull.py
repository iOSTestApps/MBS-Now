import os
from os.path import expanduser
home = expanduser("~")

to_cd = home + "/Dropbox/MBS-Now/"
print(to_cd)
os.chdir(to_cd)
os.system("git pull https://github.com/mbsdev/MBS-Now.git")