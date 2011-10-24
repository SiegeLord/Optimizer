/*
Optimizer, a command line function minimization software.
Copyright (C) 2011  Pavel Sountsov

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

