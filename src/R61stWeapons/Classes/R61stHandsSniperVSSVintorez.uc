//=============================================================================
// R61stHandsSniperVSSVintorez - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  [R61stHandsSniperVSSVintorez] 
//===============================================================================
class R61stHandsSniperVSSVintorez extends R61stHandsSniperDragunov;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSniperVSSVintorezA');
	super.PostBeginPlay();
	return;
}

