//=============================================================================
// R6DecalsBase - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
// Class            R6DecalsBase.uc 
// Created By       Jean-Francois Dube
// Date             14/11/2002
// Description      R6 base class for decals effect.
//============================================================================//
class R6DecalsBase extends Actor
	native
 notplaceable;

simulated function PostBeginPlay()
{
	return;
}

defaultproperties
{
	RemoteRole=2
	DrawType=0
	bNetTemporary=true
	bReplicateMovement=false
	bNetInitialRotation=true
	bUnlit=true
	bGameRelevant=true
}
