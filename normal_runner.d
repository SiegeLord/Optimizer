module normal_runner;

import runner;

import tango.core.ThreadPool;
import Float = tango.text.convert.Float;
import Integer = tango.text.convert.Integer;
import tango.text.convert.Layout;
import tango.io.Stdout;
import tango.text.Util;
import tango.text.Arguments;

class CNormalRunner : CRunner
{
	this(Arguments args, bool verbose = true)
	{
		super(args(null).assigned, verbose);
		
		int num_threads = 1;
		
		if(args("jobs").assigned)
		{
			num_threads = Integer.toInt(args("jobs").assigned[$ - 1]);
			if(num_threads < 1)
				num_threads = 1;
		}
		
		Pool = new typeof(Pool)(num_threads);
	}
	
	override
	SResult[] RunBatch(double[][] params)
	{
		size_t old_len = Results.length;
		ResultsVal.length = Results.length + params.length;
			
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
					Stdout.formatln("{:e6}: {:e6}", job_params.Params, job_ret);
				}
			}
		}
		
		foreach(idx, param; params)
		{
			Pool.append(&job, SParameterStruct(old_len + idx, param));
		}
		
		Pool.finish();

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
