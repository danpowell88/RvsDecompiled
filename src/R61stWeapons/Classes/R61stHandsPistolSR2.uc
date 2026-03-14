//=============================================================================
// R61stHandsPistolSR2 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsPistolSR2] 
//===============================================================================
class R61stHandsPistolSR2 extends R61stHandsGripSPP;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsPistolSR2A');
	super.PostBeginPlay();
	return;
}

