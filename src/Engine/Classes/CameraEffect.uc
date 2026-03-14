//=============================================================================
// CameraEffect - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class CameraEffect extends Object
    abstract
    native
    noexport;

var float Alpha;  // Used to transition camera effects. 0 = no effect, 1 = full effect
var bool FinalEffect;  // Forces the renderer to ignore effects on the stack below this one.

defaultproperties
{
	Alpha=1.0000000
}
