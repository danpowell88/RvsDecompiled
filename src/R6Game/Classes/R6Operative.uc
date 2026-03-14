//=============================================================================
//  R6Operative.uc : This class describes a rainbow officer
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/18 * Created by Alexandre Dionne
//=============================================================================
class R6Operative extends Object
    native;

// --- Variables ---
//Used to get operative Localized info
var string m_szOperativeClass;
//According to the index of the rockie operative
var int m_iRookieID;
//Status
//0= Ready, 1=Wounded, 2=Incapacitated, 3=Dead
var int m_iHealth;
var string m_szSpecialityID;
//Skills
var float m_fAssault;
var float m_fElectronics;
var float m_fSniper;
var float m_fStealth;
var float m_fDemolitions;
var float m_fSelfControl;
var float m_fLeadership;
var float m_fObservation;
var int m_iRoundsfired;
var int m_iRoundsOntarget;
var array<array> m_OperativeFaces;
var int m_iTerrokilled;
var int m_iNbMissionPlayed;
var string m_szGenderID;
var string m_szEyesColorID;
var string m_szHairColorID;
var string m_szStateID;
var string m_szCityID;
var string m_szCountryID;
var string m_szGender;
var Texture m_TMenuFace;
//According to the index of the operative in the operative collection
var int m_iUniqueID;
var Texture m_TMenuFaceSmall;
var int m_RMenuFaceSmallX;
// ^ NEW IN 1.60
var int m_RMenuFaceSmallY;
// ^ NEW IN 1.60
var int m_RMenuFaceSmallW;
// ^ NEW IN 1.60
var int m_RMenuFaceSmallH;
var int m_RMenuFaceX;
// ^ NEW IN 1.60
var int m_RMenuFaceY;
// ^ NEW IN 1.60
var int m_RMenuFaceW;
// ^ NEW IN 1.60
//God this is ugly, hack cuz Region is Uwindowbase
var int m_RMenuFaceH;
//Weapons
//R6PrimaryWeaponDescription class name
var string m_szPrimaryWeapon;
//Token representing type of weapon gadget
var string m_szPrimaryWeaponGadget;
//Token representing type of bullets
var string m_szPrimaryWeaponBullet;
//R6GadgetDescription class name
var string m_szPrimaryGadget;
//R6SecondaryWeaponDescription class name
var string m_szSecondaryWeapon;
//Token representing type of weapon gadget
var string m_szSecondaryWeaponGadget;
///Token representing type of bullets
var string m_szSecondaryWeaponBullet;
//R6GadgetDescription class name
var string m_szSecondaryGadget;
//R6ArmorDescription class name
var string m_szArmor;
//If the operative is limited to use specific armors
var name m_CanUseArmorType;

// --- Functions ---
function string GetTextDescription() {}
// ^ NEW IN 1.60
function CopyOperative(R6Operative aOperative) {}
function UpdateSkills() {}
function string GetHealthStatus() {}
// ^ NEW IN 1.60
function string GetRealOperativeClass() {}
// ^ NEW IN 1.60
function string GetName() {}
// ^ NEW IN 1.60
function string GetShortName() {}
// ^ NEW IN 1.60
function string GetSpeciality() {}
// ^ NEW IN 1.60
function string GetHistory() {}
// ^ NEW IN 1.60
function string GetGender() {}
// ^ NEW IN 1.60
function string GetCountry() {}
// ^ NEW IN 1.60
function string GetCity() {}
// ^ NEW IN 1.60
function string GetState() {}
// ^ NEW IN 1.60
function string GetHairColor() {}
// ^ NEW IN 1.60
function string GetEyesColor() {}
// ^ NEW IN 1.60
function string GetIDNumber() {}
// ^ NEW IN 1.60
function string GetBirthDate() {}
// ^ NEW IN 1.60
function string GetHeight() {}
// ^ NEW IN 1.60
function string GetWeight() {}
// ^ NEW IN 1.60
function string GetNbMissionPlayed() {}
// ^ NEW IN 1.60
function string GetNbTerrokilled() {}
// ^ NEW IN 1.60
function string GetNbRoundsfired() {}
// ^ NEW IN 1.60
function string GetNbRoundsOnTarget() {}
// ^ NEW IN 1.60
function string GetShootPercent() {}
// ^ NEW IN 1.60
//=============================================================
// IsOperativeReady: return true if operative health status is ready (0)
//=============================================================
function bool IsOperativeReady() {}
// ^ NEW IN 1.60
function DisplayStats() {}

defaultproperties
{
}
