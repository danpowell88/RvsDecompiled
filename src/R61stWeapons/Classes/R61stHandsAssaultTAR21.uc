//=============================================================================
// R61stHandsAssaultTAR21 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsAssaultTAR21] 
//===============================================================================
class R61stHandsAssaultTAR21 extends R61stHandsGripMP5;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultTAR21A');
	super.PostBeginPlay();
	return;
}

