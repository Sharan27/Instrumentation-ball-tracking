import os
import sys
from ast import literal_eval
import numpy as np
import subprocess

argList=sys.argv[1:]
print(argList)


a,b = ['manjeet', 'akshat'], ['nikhil', 'akash']
print(type(literal_eval(str(a))))

cwd = os.path.join(os.getcwd(), "test2.py" + ' ' + str(a) + "  " + "['2']")

os.system('{} {}'.format('python', cwd))
# os.system('/Users/sharan/PycharmProjects/Flask_Webpage/test2.py %s' % ' '.join(argList))
# subprocess.run(["python", "test2.py"])