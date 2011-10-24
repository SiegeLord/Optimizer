module main;

import limits;
import runner;
import parallel_runner;
import normal_runner;
import algorithm;
import grid;
import de;

import tango.io.Stdout;
import tango.text.Arguments;

int main(char[][] arg_str)
{
	auto args = new Arguments;
	auto verbose_arg = args("verbose").aliased('v');
	auto jobs_arg = args("jobs").aliased('j').params(1);
	auto limits_arg = args("limits").aliased('l');
	auto algorithm_arg = args("algorithm").aliased('a').params(1).defaults("de");
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
	
	int num_threads = 1;
		
	if(args("jobs").assigned)
	{
		num_threads = Integer.toInt(args("jobs").assigned[$ - 1]);
		if(num_threads < 1)
			num_threads = 1;
	}
	
	CRunner runner;
	
	if(num_threads > 1)
		runner = new CParallelRunner(args, num_threads, verbose_arg.set);
	else
		runner = new CNormalRunner(args, verbose_arg.set);
		
	CAlgorithm algorithm;
	switch(algorithm_arg.assigned[0])
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
