// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Editor.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class MaterialFactory extends Object
    native
    abstract;

// --- Constants ---
const RF_Standalone =  0x00080000;
const RF_Public =  0x0000004;

// --- Variables ---
var string Description;

// --- Functions ---
event Material CreateMaterial(string InName, string InGroup, string InPackage, Object InOuter) {}
// ^ NEW IN 1.60
native function ConsoleCommand(string Cmd) {}

defaultproperties
{
}
