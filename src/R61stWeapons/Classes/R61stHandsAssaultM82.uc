//=============================================================================
// R61stHandsAssaultM82 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  [R61stHandsAssaultM82] 
//===============================================================================
class R61stHandsAssaultM82 extends R61stHandsGripUZI;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultM82A');
	super.PostBeginPlay();
	return;
}

