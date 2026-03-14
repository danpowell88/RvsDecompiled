//=============================================================================
// The Karma Collision parameters class.
// This provides 'extra' parameters needed to create Karma collision for this Actor.
// You can _only_ turn on collision, not dynamics.
// NB: All parameters are in KARMA scale!
//=============================================================================
class KarmaParamsCollision extends Object
    native;

// --- Variables ---
// Used internally for Karma stuff - DO NOT CHANGE!
var transient const int KarmaData;
// Usually kept in sync with actor's DrawScale, this is how much to scale moi/com-offset (but not mass!)
var const float KScale;
var const Vector KScale3D;
var float KFriction;
// ^ NEW IN 1.60
var float KRestitution;
// ^ NEW IN 1.60
var float KImpactThreshold;
// ^ NEW IN 1.60

defaultproperties
{
}
