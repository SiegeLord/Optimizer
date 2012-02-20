module runner;

import tango.math.Math;
import tango.math.random.Random;
import Float = tango.text.convert.Float;
import Integer = tango.text.convert.Integer;
import tango.text.convert.Layout;
import tango.io.Stdout;
import tango.io.stream.Lines;
import tango.text.Util;
import tango.text.Arguments;
import tango.text.convert.Format;
import tango.sys.Process;
import tango.io.device.File;
import tango.core.Exception;

class CRunner
{
	this(Arguments args, size_t num_threads, bool verbose)
	{
		Processes.length = num_threads;
		
		foreach(ref proc; Processes)
		{
			proc = new Process(true, args(null).assigned());
			proc.setRedirect(Redirect.Output);
		}
		
		ProcName = Processes[0].programName;
		ProcArgs = Processes[0].args();
		
		Verbose = verbose;
		Rand = new Random();
	}
	
	SResult[] RunBatch(double[][] params_batch)
	{
		size_t old_len = Results.length;
		ResultsVal.length = Results.length + params_batch.length;
		
		if(Verbose)
			Stdout.formatln("Running batch of {}:", params_batch.length);
		
		size_t res_idx = 0;
		while(params_batch.length)
		{
			auto left = min(params_batch.length, Processes.length);
			
			foreach(idx, proc; Processes[0..left])
			{
				const(char)[][] param_args;
				foreach(param; params_batch[idx])
				{
					param_args ~= Format("{:e6}", param);
				}
				
				proc.setArgs(ProcName, ProcArgs ~ param_args);
				proc.execute();
			}
			
			foreach(proc; Processes[0..left])
			{
				auto status = proc.wait();
				if(status.reason != 0 || status.status != 0)
				{
					throw new Exception("Error running '" ~ proc.programName.idup ~ join(proc.args(), " ").idup ~ "':\n" ~ status.toString().idup);
				}
			}
			
			foreach(idx, proc; Processes[0..left])
			{
				auto job_ret = ParseProcessOutput(proc);
				Results[old_len + res_idx].Params = params_batch[idx].dup;
				Results[old_len + res_idx].Value = job_ret;
			
				if(Verbose)
					Stdout.formatln("\t{:e6}: {:e6}", params_batch[idx], job_ret);
				
				res_idx++;
			}
			
			params_batch = params_batch[left..$];
		}
		
		if(Verbose)
			Stdout.nl;

		return Results[old_len..$];
	}
	
	struct SResult
	{
		double[] Params;
		double Value;
	}
	
	void AddResult(SResult res)
	{
		ResultsVal ~= res;
	}
	
	@property
	SResult[] Results()
	{
		return ResultsVal;
	}
	
	@property
	SResult Minimum()
	{
		assert(Results.length > 0);
		
		double min_val = double.infinity;
		size_t min_idx = 0;
		foreach(idx, res; Results)
		{
			if(res.Value < min_val)
			{
				min_val = res.Value;
				min_idx = idx;
			}
		}
		
		return Results[min_idx];
	}
	
	static double ParseProcessOutput(Process proc)
	{
		scope lines = new Lines!(char)(proc.stdout);
		const(char)[] last_line;
		foreach(line; lines)
		{
			if(line != "")
				last_line = line;
		}
		
		try
		{
			return Float.toFloat(last_line);
		}
		catch(IllegalArgumentException e)
		{
			throw new Exception("Running '" ~ proc.programName.idup ~ join(proc.args(), " ").idup ~ "' yielded an uninterpretable output '" ~ last_line.idup ~ "'");
		}
		assert(0);
	}
	
	Random Rand;
protected:
	SResult[] ResultsVal;
	bool Verbose = true;
	
	Process[] Processes;
	const(char)[] ProcName;
	const(char[])[] ProcArgs;
}
