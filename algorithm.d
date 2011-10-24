module algorithm;

import runner;
import normal_runner;
import limits;

import tango.math.random.Random;

class CAlgorithm
{
	this(CRunner runner, bool verbose)
	{
		Runner = runner;
		Verbose = verbose;
	}
	
	abstract
	CRunner.SResult Run(SLimits[] limits);
	
	Random Rand()
	{
		return Runner.Rand;
	}
	
protected:
	CRunner Runner;
	bool Verbose = false;
}

