//=============================================================================
// R61stHandsSniperPSG1 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsSniperPSG1] 
//===============================================================================
class R61stHandsSniperPSG1 extends R61stHandsGripSniper;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSniperPSG1A');
	super.PostBeginPlay();
	return;
}

