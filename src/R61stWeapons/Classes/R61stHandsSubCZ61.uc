//=============================================================================
// R61stHandsSubCZ61 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsSubCZ61] 
//===============================================================================
class R61stHandsSubCZ61 extends R61stHandsGripP90;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSubCZ61A');
	super.PostBeginPlay();
	return;
}

