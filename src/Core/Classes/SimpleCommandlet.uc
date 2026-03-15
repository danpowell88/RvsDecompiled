//=============================================================================
// SimpleCommandlet - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class SimpleCommandlet extends Commandlet
    transient;

var int intparm;

function int TestFunction()
{
	return 666;
	return;
}

function int Main(string Parms)
{
	local int temp;
	local float floattemp;
	local string textstring, otherstring;

	Log("Simple commandlet says hi.");
	Log("Testing function calling.");
	temp = TestFunction();
	Log(("Function call returned" @ string(temp)));
	Log("Testing cast to int.");
	floattemp = 3.0000000;
	temp = int(floattemp);
	Log(((("Temp is cast from " $ string(floattemp)) $ " to ") $ string(temp)));
	Log("Testing min()");
	temp = Min(32, TestFunction());
	Log(("Temp is min(32, 666): " $ string(temp)));
	textstring = "wookie";
	Log(("3 is a " $ Left(textstring, 3)));
	otherstring = "skywalker";
	otherstring = Mid(otherstring, InStr(otherstring, "a"));
	Log(("otherstring:" @ otherstring));
	return 0;
	return;
}

defaultproperties
{
	HelpCmd="Simple"
	HelpOneLiner="Simple test commandlet"
	HelpUsage="Simple (no parameters)"
}
