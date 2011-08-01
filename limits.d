module limits;

import tango.text.Util;
import tango.core.Exception;
import Float = tango.text.convert.Float;

struct SLimits
{
	double Min = 0;
	double Max = 1;
}

SLimits[] ParseLimits(char[][] desc)
{
	auto ret = new SLimits[](desc.length);
	
	if(desc.length == 0)
		return ret ~ SLimits();
	
	foreach(idx, limit; desc)
	{
		void parse_error()
		{
			throw new Exception("'" ~ limit ~ "' parameter limits are invalid, expected limits formatted like this: 'min:max'.");
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
			throw new Exception("'" ~ limit ~ "' parameter limits are invalid, minimum should be smaller than the maximum.");
		}
	}
	
	return ret;
}
