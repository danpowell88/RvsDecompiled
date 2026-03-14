//=============================================================================
//  R6DemolitionsUnit.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/09 * Created by Rima Brek
//=============================================================================
class R6DemolitionsUnit extends R6Grenade;

// --- Variables ---
var bool m_bExploding;

// --- Functions ---
//a bullet hit the demolition charge
function bool DestroyedByImpact() {}
// ^ NEW IN 1.60
function DistributeDamage(Actor anActor, Vector vLocationOfExplosion) {}
function Activate() {}
simulated function HitWall(Vector HitNormal, Actor Wall) {}
simulated function Landed(Vector HitNormal) {}
singular simulated function Touch(Actor Other) {}
simulated function ProcessTouch(Actor Other, Vector vHitLocation) {}
function Explode() {}
function DoorExploded() {}

defaultproperties
{
}
