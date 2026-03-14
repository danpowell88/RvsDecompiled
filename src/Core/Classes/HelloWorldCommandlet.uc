//=============================================================================
// HelloWorldCommandlet - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
/// UnrealScript "hello world" sample Commandlet.
///
/// Usage:
///     ucc.exe HelloWorld
//=============================================================================
class HelloWorldCommandlet extends Commandlet
 transient;

var int intparm;
var string strparm;

function int Main(string Parms)
{
	__NFUN_231__("Hello, world!");
	// End:0x40
	if(__NFUN_123__(Parms, ""))
	{
		__NFUN_231__(__NFUN_112__("Command line parameters=", Parms));
	}
	// End:0x6E
	if(__NFUN_155__(intparm, 0))
	{
		__NFUN_231__(__NFUN_112__("You specified intparm=", string(intparm)));
	}
	// End:0x9B
	if(__NFUN_123__(strparm, ""))
	{
		__NFUN_231__(__NFUN_112__("You specified strparm=", strparm));
	}
	return 0;
	return;
}

defaultproperties
{
	HelpCmd="HelloWorld"
	HelpOneLiner="Sample 'hello world' commandlet"
	HelpUsage="HelloWorld (no parameters)"
	HelpParm[0]="IntParm"
	HelpParm[1]="StrParm"
	HelpDesc[0]="An integer parameter"
	HelpDesc[1]="A string parameter"
}
