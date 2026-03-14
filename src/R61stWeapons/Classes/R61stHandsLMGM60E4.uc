//=============================================================================
// R61stHandsLMGM60E4 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsLMGM60E4] 
//===============================================================================
class R61stHandsLMGM60E4 extends R6AbstractFirstPersonHands;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsLMGM60E4A');
	super.PostBeginPlay();
	return;
}

defaultproperties
{
	DrawType=0
	Mesh=SkeletalMesh'R61stHands_UKX.R61stHands'
}
