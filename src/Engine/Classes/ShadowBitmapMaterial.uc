// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ShadowBitmapMaterial extends BitmapMaterial
    native;

// --- Variables ---
var Actor ShadowActor;
var Vector m_LightLocation;
//R6SHADOW
var byte m_bOpacity;
var bool Dirty;
var float LightFOV;
// ^ NEW IN 1.60
var float LightDistance;
// ^ NEW IN 1.60
var Vector LightDirection;
var transient const int TextureInterfaces[2];
var bool m_bValid;

defaultproperties
{
}
