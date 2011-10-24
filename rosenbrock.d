import tango.io.Stdout;
import tango.math.Math;
import tango.core.Exception;
import Float = tango.text.convert.Float;

void main(char[][] args)
{
	void error()
	{
		throw new Exception("Need 2 numerical arguments. E.g. " ~ args[0] ~ " 1 1");
	}
	
	if(args.length < 3)
		error();
	
	try
	{
		auto x = Float.toFloat(args[1]);
		auto y = Float.toFloat(args[2]);
		auto r = pow(1.0 - x, 2) + 100 * pow((y - x * x), 2);
		Stdout.formatln("{:e6}", r);
	}
	catch(IllegalArgumentException e)
	{
		error();
	}
}
