//=============================================================================
// R61stHandsSubM12S - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  [R61stHandsSubM12S] 
//===============================================================================
class R61stHandsSubM12S extends R61stHandsGripAUG;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSubM12SA');
	super.PostBeginPlay();
	return;
}

