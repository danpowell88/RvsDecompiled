//=============================================================================
// R61stHandsAssaultM16A2 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsAssaultM16A2] 
//===============================================================================
class R61stHandsAssaultM16A2 extends R61stHandsGripMP5;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultM16A2A');
	super.PostBeginPlay();
	return;
}

