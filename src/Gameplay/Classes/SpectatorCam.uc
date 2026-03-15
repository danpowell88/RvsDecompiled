//=============================================================================
// SpectatorCam - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// SpectatorCam.
//=============================================================================
class SpectatorCam extends Keypoint;

var() bool bSkipView;  // spectators skip this camera when flipping through cams
var() float FadeOutTime;  // fade out time if used as EndCam

defaultproperties
{
	FadeOutTime=5.0000000
	DrawType=2
	bClientAnim=true
	bDirectional=true
	CollisionRadius=20.0000000
	CollisionHeight=40.0000000
	Texture=Texture'Engine.S_Camera'
}
