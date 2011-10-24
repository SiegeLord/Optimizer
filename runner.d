module runner;

import tango.io.Stdout;
import tango.sys.Process;
import tango.io.stream.Lines;
import tango.text.Util;
import tango.core.Exception;
import tango.math.random.Random;
import Float = tango.text.convert.Float;

class CRunner
{
	this(char[][] base_args, bool verbose)
	{
		BaseArgs = base_args;
		Verbose = verbose;
		Rand = new Random();
	}
	
	abstract
	SResult[] RunBatch(double[][] params_batch);
	
	static double Run(char[][] args, bool redirect_output = true)
	{
		double ret = 0;
		
		scope proc = new Process(true, args);
		
		if(redirect_output)
			proc.setRedirect(Redirect.Output);
		else
			proc.setRedirect(Redirect.None);

		proc.execute;
		auto status = proc.wait;
		
		if(status.reason != 0 || status.status != 0)
		{
			throw new Exception("Error running '" ~ join(args, " ") ~ "':\n" ~ status.toString());
		}
		
		if(redirect_output)
		{
			scope lines = new Lines!(char)(proc.stdout);
			foreach(line; lines)
			{
				try
				{
					ret = Float.toFloat(line);
				}
				catch(IllegalArgumentException e)
				{
					throw new Exception("Running '" ~ join(args, " ") ~ "' yielded an uninterpretable output '" ~ line ~ "'");
				}
				break;
			}
		}
		
		proc.close;
		
		return ret;
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
	
	SResult[] Results()
	{
		return ResultsVal;
	}
	
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
	
	Random Rand;
protected:
	SResult[] ResultsVal;
	char[][] BaseArgs;
	bool Verbose = true;
}
