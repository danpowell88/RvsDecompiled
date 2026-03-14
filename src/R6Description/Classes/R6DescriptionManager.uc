//=============================================================================
//  R6DescriptionManager.uc : Class providing manipulation tools
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/09/10 * Created by Alexandre Dionne
//=============================================================================
class R6DescriptionManager extends Object;

// --- Functions ---
static final function class<R6BulletDescription> GetSecondaryBulletDesc(class<R6SecondaryWeaponDescription> WeaponDescription, string token) {}
static final function class<R6Description> findSecondaryDefaultAmmo(class<R6SecondaryWeaponDescription> WeaponDescriptionClass) {}
static final function class<R6WeaponGadgetDescription> GetPrimaryWeaponGadgetDesc(class<R6PrimaryWeaponDescription> WeaponDescription, string token) {}
static final function class<R6Description> findPrimaryDefaultAmmo(class<R6PrimaryWeaponDescription> WeaponDescriptionClass) {}
static final function class<R6WeaponGadgetDescription> GetSecondaryWeaponGadgetDesc(class<R6SecondaryWeaponDescription> WeaponDescription, string token) {}
static final function class<R6BulletDescription> GetPrimaryBulletDesc(class<R6PrimaryWeaponDescription> WeaponDescription, string token) {}

defaultproperties
{
}
