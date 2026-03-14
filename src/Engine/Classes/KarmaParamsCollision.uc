//=============================================================================
// KarmaParamsCollision - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// The Karma Collision parameters class.
// This provides 'extra' parameters needed to create Karma collision for this Actor.
// You can _only_ turn on collision, not dynamics.
// NB: All parameters are in KARMA scale!
//=============================================================================
class KarmaParamsCollision extends Object
	native
	editinlinenew;

var const float KScale;  // Usually kept in sync with actor's DrawScale, this is how much to scale moi/com-offset (but not mass!)
var() float KFriction;  // Multiplied pairwise to get contact friction
var() float KRestitution;  // 'Bouncy-ness' - Normally between 0 and 1. Multiplied pairwise to get contact restitution.
var() float KImpactThreshold;  // threshold velocity magnitude to call KImpact event
var const Vector KScale3D;
// Used internally for Karma stuff - DO NOT CHANGE!
var const transient int KarmaData;

defaultproperties
{
	KScale=1.0000000
	KFriction=1.0000000
	KImpactThreshold=1000000.0000000
	KScale3D=(X=1.0000000,Y=1.0000000,Z=1.0000000)
}
