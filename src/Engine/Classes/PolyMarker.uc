//=============================================================================
// PolyMarker - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// PolyMarker.
//
// These are markers for the polygon drawing mode.
//
// These should NOT be manually added to the level.  The editor adds and
// deletes them on it's own.
//
//=============================================================================
class PolyMarker extends Keypoint
    native
    placeable;

defaultproperties
{
	bEdShouldSnap=true
	Texture=Texture'Engine.S_PolyMarker'
}
