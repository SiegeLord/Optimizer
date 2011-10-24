module parallel_runner;

import runner;

import tango.core.ThreadPool;
import Float = tango.text.convert.Float;
import Integer = tango.text.convert.Integer;
import tango.text.convert.Layout;
import tango.io.Stdout;
import tango.text.Util;
import tango.text.Arguments;

class CParallelRunner : CRunner
{
	this(Arguments args, size_t num_threads, bool verbose = true)
	{
		super(args(null).assigned, verbose);
		
		Pool = new typeof(Pool)(num_threads);
	}
	
	override
	SResult[] RunBatch(double[][] params_batch)
	{
		size_t old_len = Results.length;
		ResultsVal.length = Results.length + params_batch.length;
		
		if(Verbose)
			Stdout.formatln("Running batch of {}:", params_batch.length);
			
		void job(SParameterStruct job_params)
		{
			scope layout = new Layout!(char);
			
			char[][] param_args;
			foreach(param; job_params.Params)
			{
				param_args ~= layout("{:e6}", param);
			}
			
			auto job_ret = Run(BaseArgs ~ param_args, true);
			
			Results[job_params.JobId].Params = job_params.Params.dup;
			Results[job_params.JobId].Value = job_ret;
			
			if(Verbose)
			{
				synchronized
				{
					Stdout.formatln("\t{:e6}: {:e6}", job_params.Params, job_ret);
				}
			}
		}
		
		foreach(idx, params; params_batch)
		{
			Pool.append(&job, SParameterStruct(old_len + idx, params));
		}
		
		Pool.finish();
		
		if(Verbose)
			Stdout.nl;

		return Results[old_len..$];
	}
	
	struct SParameterStruct
	{
		size_t JobId;
		double[] Params;
	}
	
protected:
	ThreadPool!(SParameterStruct) Pool;
}
