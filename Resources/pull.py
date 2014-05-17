import os
from os.path import expanduser
home = expanduser("~")

to_cd = home + "/Dropbox/MBS-Now/"
os.chdir(to_cd)
os.system("git pull https://github.com/MBS-Now/MBS-Now.git")