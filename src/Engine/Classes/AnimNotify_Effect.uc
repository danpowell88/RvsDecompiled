//=============================================================================
// AnimNotify_Effect - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class AnimNotify_Effect extends AnimNotify
	native
	editinlinenew
	collapsecategories
 hidecategories(Object);

var() bool Attach;
var() float DrawScale;
var() name Bone;
var() name Tag;
var() Class<Actor> EffectClass;
var() Vector OffsetLocation;
var() Rotator OffsetRotation;
var() Vector DrawScale3D;
var private transient Actor LastSpawnedEffect;  // Valid only in the editor.

defaultproperties
{
	DrawScale=1.0000000
	DrawScale3D=(X=1.0000000,Y=1.0000000,Z=1.0000000)
}
