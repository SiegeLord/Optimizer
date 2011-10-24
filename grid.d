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

module grid;

import algorithm;
import runner;
import limits;

import tango.text.Arguments;
import tango.io.Stdout;
import Integer = tango.text.convert.Integer;

class CGrid : CAlgorithm
{
	static void RegisterArguments(Arguments args)
	{
		args("grid_size").params();
	}
	
	this(Arguments args, CRunner runner, bool verbose)
	{
		super(runner, verbose);
		
		foreach(grid_str; args("grid_size").assigned)
		{
			int grid_size = Integer.toInt(grid_str);
			if(grid_size < 2)
				throw new Exception("Grid size needs to be >= 2");
			
			GridSize ~= cast(size_t)grid_size;
		}
	}
	
	override
	CRunner.SResult Run(SLimits[] limits)
	{
		if(GridSize.length < limits.length)
		{
			auto old_len = GridSize.length;
			GridSize.length = limits.length;
			GridSize[old_len..$] = 2;
		}
		
		assert(GridSize.length <= limits.length, "Dimensionality of the grid size is greater that the dimensionality of the limits");
		
		size_t num_grid_elements = GridSize[0];
		foreach(sz; GridSize[1..$])
		{
			num_grid_elements *= sz;
		}
		
		auto params = new double[][](num_grid_elements, limits.length);
		
		auto grid_location = new size_t[](limits.length);
		
		size_t params_idx = 0;
		
		while(grid_location[limits.length - 1] < GridSize[limits.length - 1])
		{
			foreach(idx, ref param; params[params_idx])
			{
				param = limits[idx].Min + cast(double)grid_location[idx] / cast(double)(GridSize[idx] - 1) * (limits[idx].Max - limits[idx].Min);
			}
			
			params_idx++;
			grid_location[0]++;
			
			for(size_t ii = 0; ii < limits.length - 1; ii++)
			{
				if(grid_location[ii] >= GridSize[ii])
				{
					grid_location[ii] = 0;
					grid_location[ii + 1]++;
				}
			}
		}
		
		Runner.RunBatch(params);
		
		return Runner.Minimum();
	}
	
protected:
	size_t[] GridSize;
}
