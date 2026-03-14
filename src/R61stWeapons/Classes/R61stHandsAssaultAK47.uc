//=============================================================================
// R61stHandsAssaultAK47 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsAssaultAK47] 
//===============================================================================
class R61stHandsAssaultAK47 extends R61stHandsGripMP5;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultAK47A');
	super.PostBeginPlay();
	return;
}

