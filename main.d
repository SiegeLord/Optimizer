module main;

import limits;
import runner;
import normal_runner;
import algorithm;
import grid;

import tango.io.Stdout;
import tango.text.Arguments;

int main(char[][] arg_str)
{
	auto args = new Arguments;
	auto verbose_arg = args("verbose").aliased('v').params();
	auto jobs_arg = args("jobs").aliased('j').params();
	auto limits_arg = args("limits").aliased('l').params();
	auto algorithm_arg = args("algorithm").aliased('a').params(1).defaults("grid");
	args.parse(arg_str[1..$], true);
	
	/*Stdout("null:").nl;
	foreach(val; args(null).assigned)
	{
		Stdout(val).nl;
	}*/
	
	/*Stdout("algorithm:").nl;
	foreach(val; algorithm_arg.assigned)
	{
		Stdout(val).nl;
	}*/
	
	auto limit_arr = ParseLimits(limits_arg.assigned);
	/*foreach(limit; limit_arr)
	{
		Stdout.formatln("Limit from {} to {}", limit.Min, limit.Max);
	}*/
	
	auto runner = new CNormalRunner(args, verbose_arg.set);
	auto algorithm = new CGrid(args, runner);
	auto best = algorithm.Run(limit_arr);
	
	Stdout.formatln("Minimum at {:e6} with value of {:e6}.", best.Params, best.Value);
	
	return 0;
} 
