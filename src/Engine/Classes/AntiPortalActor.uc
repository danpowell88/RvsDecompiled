//=============================================================================
// AntiPortalActor - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// AntiPortalActor.
// An actor that is drawn using a static mesh(a mesh that never changes, and
// can be cached in video memory, resulting in a speed boost).
//=============================================================================
class AntiPortalActor extends Actor
	native
 placeable;

defaultproperties
{
	RemoteRole=0
	DrawType=11
	bEdShouldSnap=true
}
