//=============================================================================
// ActorManager - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// ActorManager
//
// Same as SceneManager except for an actor
// Note: R6 is not added to keep the same naming convention as SceneManager
//=============================================================================
class ActorManager extends SceneManager
	native
	config
	placeable
 hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

defaultproperties
{
	Affect=1
	m_Alias="ActorManager"
	Texture=Texture'Engine.S_ActorManager'
	Tag="SceneManager"
}
