//=============================================================================
// ActionMoveActor - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// Action MoveActor:
//
// Simple class to provide a better name for action that need to move an actor.
// Note: R6 is not added to keep the same naming convention as ActionMoveCamera
//=============================================================================
class ActionMoveActor extends ActionMoveCamera
    native
    config;

defaultproperties
{
	Icon=Texture'Engine.ActionActorMoveIcon'
}
