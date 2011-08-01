module algorithm;

import runner;
import normal_runner;
import limits;

class CAlgorithm
{
	this(CRunner runner)
	{
		Runner = runner;
		Runner.Algorithm = this;
	}
	
	abstract
	CRunner.SResult Run(SLimits[] limits);
	
protected:
	CRunner Runner;
}
