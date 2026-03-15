//=============================================================================
// R61stHandsSubMac119 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  [R61stHandsSubMac119] 
//===============================================================================
class R61stHandsSubMac119 extends R61stHandsGripSPP;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSubMac119A');
	super.PostBeginPlay();
	return;
}

