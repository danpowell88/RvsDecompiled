//=============================================================================
// R61stHandsAssaultGalilARM - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsAssaultGalilARM] 
//===============================================================================
class R61stHandsAssaultGalilARM extends R61stHandsGripMP5;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultGalilARMA');
	super.PostBeginPlay();
	return;
}

simulated function SwitchFPAnim()
{
	__NFUN_2210__();
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsAssaultGalilARMWithScopeA');
	PostBeginPlay();
	return;
}

