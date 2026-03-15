//=============================================================================
// R61stHandsPistolMicroUzi - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  [R61stHandsPistolMicroUzi] 
//===============================================================================
class R61stHandsPistolMicroUzi extends R61stHandsGripPistol;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stPistol_UKX.R61stHandsPistolMicroUziA');
	super.PostBeginPlay();
	return;
}

