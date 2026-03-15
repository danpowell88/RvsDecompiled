//=============================================================================
// R61stHandsSniperWA2000 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  [R61stHandsSniperWA2000] 
//===============================================================================
class R61stHandsSniperWA2000 extends R61stHandsGripSniper;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSniperWA2000A');
	super.PostBeginPlay();
	return;
}

