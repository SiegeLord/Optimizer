module normal_runner;

import runner;

import Float = tango.text.convert.Float;
import Integer = tango.text.convert.Integer;
import tango.text.convert.Format;
import tango.io.Stdout;
import tango.text.Util;
import tango.text.Arguments;

class CNormalRunner : CRunner
{
	this(Arguments args, bool verbose = true)
	{
		super(args(null).assigned, verbose);
	}
	
	override
	SResult[] RunBatch(double[][] params_batch)
	{
		size_t old_len = Results.length;
		ResultsVal.length = Results.length + params_batch.length;
		
		if(Verbose)
			Stdout.formatln("Running batch of {}:", params_batch.length);
			
		foreach(idx, params; params_batch)
		{
			char[][] param_args;
			foreach(param; params)
			{
				param_args ~= Format("{:e6}", param);
			}
			
			auto job_ret = Run(BaseArgs ~ param_args, true);
			
			Results[old_len + idx].Params = params.dup;
			Results[old_len + idx].Value = job_ret;
			
			if(Verbose)
				Stdout.formatln("\t{:e6}: {:e6}", params, job_ret);
		}
		
		if(Verbose)
			Stdout.nl;

		return Results[old_len..$];
	}
}
