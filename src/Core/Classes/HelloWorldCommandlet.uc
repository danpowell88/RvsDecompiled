//=============================================================================
// HelloWorldCommandlet - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
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
	Log("Hello, world!");
	// End:0x40
	if((Parms != ""))
	{
		Log(("Command line parameters=" $ Parms));
	}
	// End:0x6E
	if((intparm != 0))
	{
		Log(("You specified intparm=" $ string(intparm)));
	}
	// End:0x9B
	if((strparm != ""))
	{
		Log(("You specified strparm=" $ strparm));
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
