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
		super(args(null).assigned(), verbose);
		
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
			
			const(char)[][] param_args;
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
