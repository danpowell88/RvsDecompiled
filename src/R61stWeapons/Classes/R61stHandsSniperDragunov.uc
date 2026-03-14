//=============================================================================
// R61stHandsSniperDragunov - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsSniperDragunov] 
//===============================================================================
class R61stHandsSniperDragunov extends R61stHandsGripSniper;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSniperDragunovA');
	super.PostBeginPlay();
	return;
}

