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

	__NFUN_231__("Simple commandlet says hi.");
	__NFUN_231__("Testing function calling.");
	temp = TestFunction();
	__NFUN_231__(__NFUN_168__("Function call returned", string(temp)));
	__NFUN_231__("Testing cast to int.");
	floattemp = 3.0000000;
	temp = int(floattemp);
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Temp is cast from ", string(floattemp)), " to "), string(temp)));
	__NFUN_231__("Testing min()");
	temp = __NFUN_249__(32, TestFunction());
	__NFUN_231__(__NFUN_112__("Temp is min(32, 666): ", string(temp)));
	textstring = "wookie";
	__NFUN_231__(__NFUN_112__("3 is a ", __NFUN_128__(textstring, 3)));
	otherstring = "skywalker";
	otherstring = __NFUN_127__(otherstring, __NFUN_126__(otherstring, "a"));
	__NFUN_231__(__NFUN_168__("otherstring:", otherstring));
	return 0;
	return;
}

defaultproperties
{
	HelpCmd="Simple"
	HelpOneLiner="Simple test commandlet"
	HelpUsage="Simple (no parameters)"
}
