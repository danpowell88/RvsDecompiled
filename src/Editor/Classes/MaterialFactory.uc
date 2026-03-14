//=============================================================================
// MaterialFactory - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class MaterialFactory extends Object
    abstract
    native;

const RF_Public = 0x0000004;
const RF_Standalone = 0x00080000;

var string Description;

event Material CreateMaterial(Object InOuter, string InPackage, string InGroup, string InName)
{
	return;
}

// Export UMaterialFactory::execConsoleCommand(FFrame&, void* const)
native function ConsoleCommand(string Cmd);

