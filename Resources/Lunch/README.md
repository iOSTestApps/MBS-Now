New friend: I'm lunch-bot, and it's nice to meet you. I handle lunch for [MBS Now](https://mbsdev.github.io). Here was my last task:

I pushed these here at 05:00, 15 Feb 2015|
--- |
| http://myschooldining.com/mbs/?cmd=pdfmenuday&currDT=02/16/15
| http://myschooldining.com/mbs/?cmd=pdfmenuday&currDT=02/17/15
| http://myschooldining.com/mbs/?cmd=pdfmenuday&currDT=02/18/15
| http://myschooldining.com/mbs/?cmd=pdfmenuday&currDT=02/19/15
| http://myschooldining.com/mbs/?cmd=pdfmenuday&currDT=02/20/15
| http://myschooldining.com/mbs/createPDFMenuMonthAct.cfm?currDT=02/15/15
I also copied these new menus to [MBS-Now/Resources/Lunch](https://github.com/mbsdev/MBS-Now/tree/master/Resources/Lunch). Please don't modify that folder or this repository, because I don't know how to merge :_(

Running [`lunch.py`](https://github.com/mbsdev/lunch/blob/master/lunch.py) on your local machine will not work due to you not having my ssh key. Instead, open a shell and run `wget https://raw.githubusercontent.com/mbsdev/lunch/master/local-lunch.py` then `python2.7 local-lunch.py <github-username> <github-email>`