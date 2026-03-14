//=============================================================================
// R61stHandsGripSPP - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsGripSPP] 
//===============================================================================
class R61stHandsGripSPP extends R6
    AbstractFirstPersonHands;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripSPPA');
	super.PostBeginPlay();
	return;
}

defaultproperties
{
	DrawType=0
	Mesh=SkeletalMesh'R61stHands_UKX.R61stHands'
}
