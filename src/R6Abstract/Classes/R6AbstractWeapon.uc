//========================================================================================
//  R6AbstractWeapon.uc :   This is the abstract class for the r6Weapon class.  We
//                          use an abstract class without any declared function.  
//                          This is useful to avoid circular references and accessing 
//                          classes that are declared in a package that is compiled later
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    July 18th, 2001 * Created by Eric Begin
//=============================================================================
class R6AbstractWeapon extends R6EngineWeapon
    native
    abstract;

// --- Variables ---
var /* replicated */ class<R6AbstractGadget> m_WeaponGadgetClass;
var R6AbstractGadget m_SelectedWeaponGadget;
var R6AbstractGadget m_ScopeGadget;
var R6AbstractGadget m_BipodGadget;
var R6AbstractGadget m_MuzzleGadget;
var R6AbstractGadget m_MagazineGadget;
var class<R6AbstractFirstPersonWeapon> m_pFPHandsClass;
var R6AbstractFirstPersonWeapon m_FPHands;
var class<R6AbstractFirstPersonWeapon> m_pFPWeaponClass;
var R6AbstractFirstPersonWeapon m_FPWeapon;
var R6AbstractGadget m_FPGadget;
var bool m_bHiddenWhenNotInUse;

// --- Functions ---
function R6AbstractBulletManager GetBulletManager() {}
// ^ NEW IN 1.60
simulated event SpawnSelectedGadget() {}
simulated function R6SetGadget(class<R6AbstractGadget> pWeaponGadgetClass) {}
simulated function CreateWeaponEmitters() {}
simulated function R6SetReticule(optional Controller LocalPlayerController) {}
// ^ NEW IN 1.60

defaultproperties
{
}
