//=============================================================================
// R61stHandsSubTMP - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsSubTMP] 
//===============================================================================
class R61stHandsSubTMP extends R61stHandsGripP90;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsSubTMPA');
	super.PostBeginPlay();
	return;
}

