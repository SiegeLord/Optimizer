module de;

import algorithm;
import runner;
import limits;

import tango.text.Arguments;
import tango.io.Stdout;
import tango.core.Array;
import Integer = tango.text.convert.Integer;
import Float = tango.text.convert.Float;

class CDifferentialEvolution : CAlgorithm
{
	this(Arguments args, CRunner runner, bool verbose)
	{
		super(runner, verbose);
		
		char[] get_last(char[] name)
		{
			auto arr = args[name].assigned;
			if(arr.length)
				return arr[$ - 1];
			else
				return null;
		}
		
		char[] str = get_last("ge_strategy");
		if(str !is null)
		{
			auto strat = Integer.toInt(str);
			if(strat < 0)
				strat = 0;
			Strategy = strat;
		}
			
		str = get_last("ge_maxgen");
		if(str !is null)
		{
			auto maxgen = Integer.toInt(str);
			if(maxgen < 1)
				maxgen = 1;
			MaxGen = maxgen;
		}
		
		str = get_last("ge_popsize");
		if(str !is null)
		{
			auto popsize = Integer.toInt(str);
			if(popsize < 0)
				popsize = 0;
			PopSize = popsize;
		}
		
		str = get_last("ge_factor");
		if(str !is null)
		{
			auto factor = Float.toFloat(str);
			if(factor < 0)
				factor = 0;
			if(factor > 1)
				factor = 1;
			Factor = factor;
		}
		
		str = get_last("ge_cross");
		if(str !is null)
		{
			auto cross = Float.toFloat(str);
			if(cross < 0)
				cross = 0;
			if(cross > 1)
				cross = 1;
			Cross = cross;
		}
	}
	
	override
	CRunner.SResult Run(SLimits[] limits)
	{
		if(!PopSize)
		{
			auto popsize = limits.length * 10;
			if(popsize > 40)
				popsize = 40;
			if(popsize < 5)
				popsize = 5;
			
			PopSize = popsize;
		}
		
		if(PopSize < 5)
			PopSize = 5;
		
		auto params = new double[][](PopSize);
		
		void evaluate(SIndividual[] pop)
		{
			foreach(ii, indiv; pop)
				params[ii] = indiv.Params;
			
			auto res = Runner.RunBatch(params);
			
			foreach(ii, ref indiv; pop)
				indiv.Fitness = res[ii].Value;
		}
		
		/* Setup the arrays */
		Population.length = PopSize * 2;
		foreach(ref indiv; Population)
			indiv.Params.length = limits.length;
			
		auto parents = Population[0..PopSize];
		auto children = Population[PopSize..$];
		size_t best_idx = 0; /* Guaranteed by periodic sorting */
		
		/* Initialize the parents */
		foreach(ref indiv; parents)
		{
			foreach(ii, ref param; indiv.Params)
			{
				param = Rand.uniformR2(limits[ii].Min, limits[ii].Max);
			}
		}
		
		evaluate(parents);
		sort(parents);
		
		for(size_t generation = 0; generation < MaxGen; generation++)
		{
			foreach(ii, ref indiv; parents)
			{
				size_t r1, r2, r3, r4;
				/* Pick 4 distinct members of the population */
				do
				{
				   r1 = Rand.uniformR(PopSize);
				} while(r1 == ii);

				do
				{
				   r2 = Rand.uniformR(PopSize);
				} while((r2 == ii) || (r2 == r1));

				do
				{
				   r3 = Rand.uniformR(PopSize);
				} while((r3 == ii) || (r3 == r1) || (r3 == r2));

				do
				{
				   r4 = Rand.uniformR(PopSize);
				} while((r4 == ii) || (r4 == r1) || (r4 == r2) || (r4 == r3));
				
				double[] origin_params;
				
				{
					size_t jj = Rand.uniformR(limits.length);
					size_t kk = 0;
					
					switch(Strategy)
					{
						default:
						case 0:
						{
							origin_params = parents[r1].Params;
							do
							{
								children[ii].Params[jj] = parents[r1].Params[jj] + Factor * (parents[r2].Params[jj] - parents[r3].Params[jj]);
								
								jj = (jj + 1) % limits.length;
								kk++;
							} while((Rand.uniformR(1.0) < Cross) && (jj < limits.length));
							break;
						}
						case 1:
						{
							origin_params = parents[ii].Params;
							do
							{
								children[ii].Params[jj] = parents[ii].Params[jj] + Factor * (Population[best_idx].Params[jj] - parents[ii].Params[jj])
								                                                 + Factor * (parents[r2].Params[jj] - parents[r3].Params[jj]);
								
								jj = (jj + 1) % limits.length;
								kk++;
							} while((Rand.uniformR(1.0) < Cross) && (jj < limits.length));
							break;
						}
					}
				}
				
				/* Bounds checking */
				foreach(jj, limit; limits)
				{
					if(children[ii].Params[jj] < limit.Min)
					{
						children[ii].Params[jj] = limit.Min + Rand.uniformR(1.0) * (origin_params[jj] - limit.Min);
					}
					if(children[ii].Params[jj] > limit.Max)
					{
						children[ii].Params[jj] = limit.Max + Rand.uniformR(1.0) * (origin_params[jj] - limit.Max);
					}
				}
			}
			
			evaluate(children);
			sort(Population);
			
			if(Verbose)
				Stdout.formatln("Generation {}\nBest:\n{:e6}: {:e6}", generation + 1, Population[best_idx].Params, Population[best_idx].Fitness).nl;
		}
		
		//CRunner.SResult(Population[best_idx].Params, Population[best_idx].Fitness);
		return Runner.Minimum();
	}
	
protected:
	uint Strategy = 0;
	size_t MaxGen = 100;
	size_t PopSize = 0;
	double Factor = 0.8;
	double Cross = 0.9;
	
	SIndividual[] Population;
}

struct SIndividual
{
	double[] Params;
	double Fitness;
	
	int opCmp(SIndividual b)
	{
		if(b.Fitness < Fitness)
			return 1;
		else if(b.Fitness > Fitness)
			return -1;
		else
			return 0;
	}
}
