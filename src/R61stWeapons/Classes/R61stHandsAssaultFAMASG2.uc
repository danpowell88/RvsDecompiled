//=============================================================================
// R61stHandsAssaultFAMASG2 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  [R61stHandsAssaultFAMASG2] 
//===============================================================================
class R61stHandsAssaultFAMASG2 extends R61stHandsGripUZI;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultFAMASG2A');
	super.PostBeginPlay();
	return;
}

