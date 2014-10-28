import os
to_cd = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(to_cd)
os.system("git pull https://github.com/mbsdev/MBS-Now")
