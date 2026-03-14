//=============================================================================
//  R6BreachingChargeUnit.uc : World unit (deployed actor) for an active breaching charge.
//  Extends R6DemolitionsUnit; handles the placed-charge state, timer, and blast on detonation.
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/08 * Created by Rima Brek
//=============================================================================
class R6BreachingChargeUnit extends R6DemolitionsUnit;

// --- Functions ---
function HurtPawns() {}
//a bullet hit the demolition charge
function bool DestroyedByImpact() {}
// ^ NEW IN 1.60

defaultproperties
{
}
