//=============================================================================
// R61stHandsAssaultL85A1 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  [R61stHandsAssaultL85A1] 
//===============================================================================
class R61stHandsAssaultL85A1 extends R61stHandsGripUZI;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultL85A1A');
	super.PostBeginPlay();
	return;
}

