//=============================================================================
//  R6ColBox.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6ColBox extends Actor
    native
    notplaceable;

// --- Variables ---
// true when colliding, cannot be replaced by bCollideWorld/bCollideActor
var /* replicated */ bool m_bActive;
// check for edges (not when peeking)
var bool m_bCheckForEdges;
// when prone, will try to step up/down
var bool m_bCanStepUp;
// true when collide with something for a tick.
var bool m_bCollisionDetected;
var /* replicated */ float m_fFeetColBoxRadius;

// --- Functions ---
final native function EnableCollision(optional bool bCanStepUp, optional bool bCheckForEdges, bool bEnable) {}
// ^ NEW IN 1.60
event Trigger(Pawn EventInstigator, Actor Other) {}
event UnTrigger(Pawn EventInstigator, Actor Other) {}
event HitWall(Actor HitWall, Vector HitNormal) {}
event Touch(Actor Other) {}
event PostTouch(Actor Other) {}
event UnTouch(Actor Other) {}
event Bump(Actor Other) {}
event bool EncroachingOn(Actor Other) {}
// ^ NEW IN 1.60
event EncroachedBy(Actor Other) {}
function int R6TakeDamage(optional int iBulletGoup, int iBulletToArmorModifier, Vector vMomentum, Vector vHitLocation, Pawn instigatedBy, int iStunValue, int iKillValue) {}
// ^ NEW IN 1.60
simulated event bool GetReticuleInfo(out string szName, Pawn ownerReticule) {}
// ^ NEW IN 1.60
event R6QueryCircumstantialAction(out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController, float fDistance) {}
function logC(string S) {}
event BaseChange() {}
simulated event Destroyed() {}

defaultproperties
{
}
