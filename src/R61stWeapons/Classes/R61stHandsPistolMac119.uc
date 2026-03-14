//=============================================================================
// R61stHandsPistolMac119 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsPistolMac119] 
//===============================================================================
class R61stHandsPistolMac119 extends R61stHandsGripSPP;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stPistol_UKX.R61stHandsPistolMac119A');
	super.PostBeginPlay();
	return;
}

