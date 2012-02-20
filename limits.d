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

module limits;

import tango.text.Util;
import tango.core.Exception;
import Float = tango.text.convert.Float;

struct SLimits
{
	double Min = 0;
	double Max = 1;
}

SLimits[] ParseLimits(const(char[])[] desc)
{
	auto ret = new SLimits[](desc.length);
	
	if(desc.length == 0)
		return ret ~ SLimits();
	
	foreach(idx, limit; desc)
	{
		void parse_error()
		{
			throw new Exception("'" ~ limit.idup ~ "' parameter limits are invalid, expected limits formatted like this: 'min:max'.");
		}
		
		auto colon_idx = locate(limit, ':');
		if(colon_idx == limit.length)
			parse_error();
		
		try
		{
			ret[idx].Min = Float.toFloat(limit[0..colon_idx]);
			ret[idx].Max = Float.toFloat(limit[colon_idx + 1..$]);
		}
		catch(IllegalArgumentException e)
		{
			parse_error();
		}
		
		if(ret[idx].Min >= ret[idx].Max)
		{
			throw new Exception("'" ~ limit.idup ~ "' parameter limits are invalid, minimum should be smaller than the maximum.");
		}
	}
	
	return ret;
}
