//=============================================================================
// SubActionSceneSpeed - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// SubActionSceneSpeed:
//
// Alters the speed of the scene without affecting the engine speed.
//=============================================================================
class SubActionSceneSpeed extends MatSubAction
	native
	editinlinenew;

var(SceneSpeed) Range SceneSpeed;

defaultproperties
{
	Icon=Texture'Engine.SubActionSceneSpeed'
	Desc="Scene Speed"
}
