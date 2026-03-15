//=============================================================================
// R61stHandsLMGRPD - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  [R61stHandsLMGRPD] 
//===============================================================================
class R61stHandsLMGRPD extends R61stHandsGripLMG;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsLMGRPDA');
	super.PostBeginPlay();
	return;
}

