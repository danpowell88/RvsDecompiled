// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class CameraEffect extends Object
    native
    abstract
    noexport;

// --- Variables ---
// Used to transition camera effects. 0 = no effect, 1 = full effect
var float Alpha;
// Forces the renderer to ignore effects on the stack below this one.
var bool FinalEffect;

defaultproperties
{
}
