//=============================================================================
// R61stHandsSubSR2 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsSubSR2] 
//===============================================================================
class R61stHandsSubSR2 extends R61stHandsGripSPP;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSubSR2A');
	super.PostBeginPlay();
	return;
}

