//=============================================================================
// R61stHandsSubMicroUzi - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsSubMicroUzi] 
//===============================================================================
class R61stHandsSubMicroUzi extends R61stHandsPistolMicroUzi;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSubMicroUziA');
	super.PostBeginPlay();
	return;
}

