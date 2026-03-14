//=============================================================================
// R61stHandsSubMp5KPDW - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsSubMp5KPDW] 
//===============================================================================
class R61stHandsSubMp5KPDW extends R61stHandsGripAUG;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSubMp5KPDWA');
	super.PostBeginPlay();
	return;
}

