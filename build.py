#!/usr/bin/python

from sys import argv
from subprocess import call
from string import join
from glob import glob

def shell(cmd):
	return call(cmd, shell=True)

def dbuild():
	ret = shell('xfbuild +threads=6 +q +ooptimizer +cldc +xldc +xtango main.d -unittest')
	shell('rm -f *.rsp')
	return ret

if len(argv) > 1:
	if argv[1] == 'run':
		ret = dbuild()
		if ret == 0:
			shell('./optimizer ' + join(argv[2:], ' '))
	elif argv[1] == 'clean':
		shell('rm ./.objs/*.o')
		dbuild()
else:
	dbuild()
