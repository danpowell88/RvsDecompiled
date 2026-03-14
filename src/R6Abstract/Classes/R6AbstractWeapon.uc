//=============================================================================
// R6AbstractWeapon - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
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
	abstract
 native;

var bool m_bHiddenWhenNotInUse;
var R6AbstractGadget m_SelectedWeaponGadget;
var R6AbstractGadget m_ScopeGadget;
var R6AbstractGadget m_BipodGadget;
var R6AbstractGadget m_MuzzleGadget;
var R6AbstractGadget m_MagazineGadget;
var R6AbstractFirstPersonWeapon m_FPHands;
var R6AbstractFirstPersonWeapon m_FPWeapon;
var R6AbstractGadget m_FPGadget;
var Class<R6AbstractGadget> m_WeaponGadgetClass;
var(R6GunProperties) Class<R6AbstractFirstPersonWeapon> m_pFPHandsClass;
var(R6GunProperties) Class<R6AbstractFirstPersonWeapon> m_pFPWeaponClass;

replication
{
	// Pos:0x000
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		m_WeaponGadgetClass;
}

function R6AbstractBulletManager GetBulletManager()
{
	return;
}

simulated event SpawnSelectedGadget()
{
	return;
}

simulated function R6SetGadget(Class<R6AbstractGadget> pWeaponGadgetClass)
{
	return;
}

simulated function CreateWeaponEmitters()
{
	return;
}

// NEW IN 1.60
simulated function R6SetReticule(optional Controller LocalPlayerController)
{
	return;
}

