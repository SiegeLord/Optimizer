/*
Optimizer, a command line function minimization software.
Copyright (C) 2011-2012  Pavel Sountsov

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

module main;

import limits;
import runner;
import algorithm;
import grid;
import de;
import help;

import tango.io.Stdout;
import tango.text.Arguments;

int main(char[][] arg_str)
{
	auto args = new Arguments;
	auto verbose_arg = args("verbose").aliased('v');
	auto jobs_arg = args("jobs").aliased('j').params(1);
	auto limits_arg = args("limits").aliased('l').params();
	auto algorithm_arg = args("algorithm").aliased('a').params(1).defaults("de");
	auto help_arg = args("help").aliased('h').halt();
	
	CDifferentialEvolution.RegisterArguments(args);
	CGrid.RegisterArguments(args);
	
	if(!args.parse(arg_str[1..$], false))
	{
		Stderr(args.errors(&Stderr.layout.sprint)).flush();
		return -1;
	}
	if(help_arg.set)
	{
		Stdout(Help);
		return 0;
	}
	if(args(null).assigned().length == 0)
	{
		Stderr("Need a program name to run.").nl;
	}

	auto limit_arr = ParseLimits(limits_arg.assigned());
	
	int num_threads = 1;
		
	if(args("jobs").assigned())
	{
		num_threads = Integer.toInt(args("jobs").assigned()[$ - 1]);
		if(num_threads < 1)
			num_threads = 1;
	}
	
	auto runner = new CRunner(args, num_threads, verbose_arg.set);
		
	CAlgorithm algorithm;
	switch(algorithm_arg.assigned()[0])
	{
		case "grid":
			algorithm = new CGrid(args, runner, verbose_arg.set);
			break;
		default:
		case "de":
			algorithm = new CDifferentialEvolution(args, runner, verbose_arg.set);
			break;
	}
	auto best = algorithm.Run(limit_arr);
	
	Stdout.formatln("Minimum at {:e6} with value of {:e6}.", best.Params, best.Value);
	
	return 0;
} 
