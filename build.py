#!/usr/bin/python

d_compiler = 'ldc'
optimizer_files = ['main.d', 'de.d', 'grid.d', 'help.d', 'algorithm.d', 'limits.d', 'normal_runner.d', 'parallel_runner.d', 'runner.d']
install_prefix = '/usr/local/'

def example():
	dbuild(['rosenbrock.d'], 'rosenbrock', '-unittest')

def install():
	cp(['optimizer'], install_prefix + 'bin/')

def def_action():
	dbuild(optimizer_files, 'optimizer', '-unittest')
	
def clean():
	rm(['rosenbrock', 'optimizer'])
	rm(glob(".deps*"))
	rmdir(glob(".objs*"));
	
################################################################################

def _main():
	if len(argv) > 1:
		try:
			globals()[argv[1]]();
		except KeyError:
			print "Invalid option: " + argv[1]
	else:
		def_action()
		
from sys import argv
from subprocess import call, Popen
from string import join
from glob import glob
from os import remove
from shutil import rmtree, copy

try:
	a = Popen('xfbuild')
	a.kill()
except:
	have_xfbuild = False
else:
	have_xfbuild = True

def rm(file_list):
	for s in file_list:
		try:
			remove(s)
		except:
			pass

def cp(file_list, dest):
	for s in file_list:
		copy(s, dest)

def rmdir(dir_list):
	for s in dir_list:
		rmtree(s)
		
def shell(cmd):
	return call(cmd, shell=True)
	
def dbuild(input_files, output_file, flags):
	if have_xfbuild:
		command = 'xfbuild +D=".deps_%(output_file)s" +O=".objs_%(output_file)s" +threads=6 +q +o%(output_file)s +c%(d_compiler)s +x%(d_compiler)s +xtango %(input_files)s %(flags)s'
	else:
		command = '%(d_compiler)s -of%(output_file)s -od=".objs_%(output_file)s" %(flags)s %(input_files)s'
		
	ret = shell(command%
		{'output_file' : output_file,
		 'd_compiler' : d_compiler,
		 'input_files' : join(input_files),
		 'flags' : flags
		})
	
	if have_xfbuild:
		shell('rm -f *.rsp')	
	
	return ret

_main()
