//=============================================================================
// R61stHandsPistolCZ61 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  [R61stHandsPistolCZ61] 
//===============================================================================
class R61stHandsPistolCZ61 extends R61stHandsGripP90;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsPistolCZ61A');
	super.PostBeginPlay();
	return;
}

