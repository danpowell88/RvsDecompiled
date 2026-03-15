//=============================================================================
// R6Operative - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6Operative.uc : This class describes a rainbow officer
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/18 * Created by Alexandre Dionne
//=============================================================================
class R6Operative extends Object
    native;

var int m_iUniqueID;  // According to the index of the operative in the operative collection
var int m_iRookieID;  // According to the index of the rockie operative
var int m_RMenuFaceX;  // God this is ugly, hack cuz Region is Uwindowbase
// NEW IN 1.60
var int m_RMenuFaceY;
// NEW IN 1.60
var int m_RMenuFaceW;
// NEW IN 1.60
var int m_RMenuFaceH;
var int m_RMenuFaceSmallX;
// NEW IN 1.60
var int m_RMenuFaceSmallY;
// NEW IN 1.60
var int m_RMenuFaceSmallW;
// NEW IN 1.60
var int m_RMenuFaceSmallH;
//Status
var int m_iHealth;  // 0= Ready, 1=Wounded, 2=Incapacitated, 3=Dead
var int m_iNbMissionPlayed;
var int m_iTerrokilled;
var int m_iRoundsfired;
var int m_iRoundsOntarget;
//Skills
var float m_fAssault;
var float m_fDemolitions;
var float m_fElectronics;
var float m_fSniper;
var float m_fStealth;
var float m_fSelfControl;
var float m_fLeadership;
var float m_fObservation;
var Texture m_TMenuFace;
var Texture m_TMenuFaceSmall;
var name m_CanUseArmorType;  // If the operative is limited to use specific armors
var array<Texture> m_OperativeFaces;
var string m_szOperativeClass;  // Used to get operative Localized info
var string m_szCountryID;
var string m_szCityID;
var string m_szStateID;
var string m_szSpecialityID;
var string m_szHairColorID;
var string m_szEyesColorID;
var string m_szGenderID;
var string m_szGender;
//Weapons
var string m_szPrimaryWeapon;  // R6PrimaryWeaponDescription class name
var string m_szPrimaryWeaponGadget;  // Token representing type of weapon gadget
var string m_szPrimaryWeaponBullet;  // Token representing type of bullets
var string m_szPrimaryGadget;  // R6GadgetDescription class name
var string m_szSecondaryWeapon;  // R6SecondaryWeaponDescription class name
var string m_szSecondaryWeaponGadget;  // Token representing type of weapon gadget
var string m_szSecondaryWeaponBullet;  // /Token representing type of bullets
var string m_szSecondaryGadget;  // R6GadgetDescription class name
var string m_szArmor;  // R6ArmorDescription class name

function string GetName()
{
	// End:0x40
	if((m_iRookieID != -1))
	{
		return (Localize(m_szOperativeClass, "ID_NAME", "R6Operatives", true, true) $ string(m_iRookieID));		
	}
	else
	{
		return Localize(m_szOperativeClass, "ID_NAME", "R6Operatives", true, true);
	}
	return;
}

function string GetShortName()
{
	// End:0x45
	if((m_iRookieID != -1))
	{
		return (Localize(m_szOperativeClass, "ID_SHORTNAME", "R6Operatives", true, true) $ string(m_iRookieID));		
	}
	else
	{
		return Localize(m_szOperativeClass, "ID_SHORTNAME", "R6Operatives", true, true);
	}
	return;
}

function string GetSpeciality()
{
	return Localize("Speciality", m_szSpecialityID, "R6Operatives");
	return;
}

function string GetHistory()
{
	return Localize(m_szOperativeClass, "ID_HISTORY", "R6Operatives", false, true);
	return;
}

function string GetGender()
{
	return Localize("Gender", m_szGenderID, "R6Common");
	return;
}

function string GetCountry()
{
	return Localize("Country", m_szCountryID, "R6Common");
	return;
}

function string GetCity()
{
	return Localize("City", m_szCityID, "R6Common");
	return;
}

function string GetState()
{
	return Localize("State", m_szStateID, "R6Common");
	return;
}

function string GetHairColor()
{
	return Localize("Color", m_szHairColorID, "R6Common");
	return;
}

function string GetEyesColor()
{
	return Localize("Color", m_szEyesColorID, "R6Common");
	return;
}

function string GetIDNumber()
{
	return Localize(m_szOperativeClass, "ID_IDNUMBER", "R6Operatives");
	return;
}

function string GetBirthDate()
{
	return Localize(GetRealOperativeClass(), "ID_BIRTHDATE", "R6Operatives");
	return;
}

function string GetHeight()
{
	return Localize(GetRealOperativeClass(), "ID_HEIGHT", "R6Operatives");
	return;
}

function string GetWeight()
{
	return Localize(GetRealOperativeClass(), "ID_WEIGHT", "R6Operatives");
	return;
}

function string GetNbMissionPlayed()
{
	return string(m_iNbMissionPlayed);
	return;
}

function string GetNbTerrokilled()
{
	return string(m_iTerrokilled);
	return;
}

function string GetNbRoundsfired()
{
	return string(m_iRoundsfired);
	return;
}

function string GetNbRoundsOnTarget()
{
	return string(m_iRoundsOntarget);
	return;
}

function string GetShootPercent()
{
	// End:0x29
	if((m_iRoundsfired > 0))
	{
		return string(int(((float(m_iRoundsOntarget) / float(m_iRoundsfired)) * float(100))));		
	}
	else
	{
		return "0";
	}
	return;
}

function string GetTextDescription()
{
	local string szDescription, szTemp;

	szDescription = (((Localize("IdentificationField", "ID_IDNUMBER", "R6Operatives") $ " ") $ GetIDNumber()) $ Chr(13));
	szDescription = (((szDescription $ Localize("IdentificationField", "ID_BIRTHPLACE", "R6Operatives")) $ " ") $ GetCountry());
	szTemp = GetCountry();
	// End:0xCB
	if((szTemp != ""))
	{
		szDescription = (szDescription $ szTemp);
	}
	szTemp = GetCity();
	// End:0xFB
	if((szTemp != ""))
	{
		szDescription = ((szDescription $ ") $ szTemp);
	}
	szTemp = GetState();
	// End:0x12B
	if((szTemp != ""))
	{
		szDescription = ((szDescription $ ") $ szTemp);
	}
	szDescription = (szDescription $ Chr(13));
	szDescription = ((((szDescription $ Localize("IdentificationField", "ID_SPECIALITY", "R6Operatives")) $ " ") $ GetSpeciality()) $ Chr(13));
	szDescription = ((((szDescription $ Localize("IdentificationField", "ID_BIRTHDATE", "R6Operatives")) $ " ") $ GetBirthDate()) $ Chr(13));
	szDescription = ((((szDescription $ Localize("IdentificationField", "ID_HEIGHT", "R6Operatives")) $ " ") $ GetHeight()) $ Chr(13));
	szDescription = ((((szDescription $ Localize("IdentificationField", "ID_WEIGHT", "R6Operatives")) $ " ") $ GetWeight()) $ Chr(13));
	szDescription = ((((szDescription $ Localize("IdentificationField", "ID_HAIR", "R6Operatives")) $ " ") $ GetHairColor()) $ Chr(13));
	szDescription = ((((szDescription $ Localize("IdentificationField", "ID_EYES", "R6Operatives")) $ " ") $ GetEyesColor()) $ Chr(13));
	szDescription = (((szDescription $ Localize("IdentificationField", "ID_GENDER", "R6Operatives")) $ " ") $ GetGender());
	return szDescription;
	return;
}

function string GetHealthStatus()
{
	local string Result;

	switch(m_iHealth)
	{
		// End:0x36
		case 0:
			Result = Localize("Health", "ID_READY", "R6Common");
			// End:0xE3
			break;
		// End:0x67
		case 1:
			Result = Localize("Health", "ID_WOUNDED", "R6Common");
			// End:0xE3
			break;
		// End:0x9F
		case 2:
			Result = Localize("Health", "ID_INCAPACITATED", "R6Common");
			// End:0xE3
			break;
		// End:0xCE
		case 3:
			Result = Localize("Health", "ID_DEAD", "R6Common");
			// End:0xE3
			break;
		// End:0xFFFF
		default:
			Result = "UNKNOWN";
			// End:0xE3
			break;
			break;
	}
	return Result;
	return;
}

//=============================================================
// IsOperativeReady: return true if operative health status is ready (0)
//=============================================================
function bool IsOperativeReady()
{
	return (m_iHealth == 0);
	return;
}

function string GetRealOperativeClass()
{
	local int ITemp;

	// End:0x15
	if((m_iRookieID == -1))
	{
		return m_szOperativeClass;
	}
	// End:0x33
	if((m_iRookieID < 30))
	{
		ITemp = (29 - m_iRookieID);		
	}
	else
	{
		ITemp = ((m_iRookieID / 30) - 1);
		ITemp = (m_iRookieID - (29 + (ITemp * 30)));
	}
	return ("R6Operative" $ string(ITemp));
	return;
}

function UpdateSkills()
{
	local int iD5, iD2;
	local float fDecision, fIncreaseSkill;

	fIncreaseSkill = 0.5000000;
	iD5 = (Rand(5) + 1);
	iD2 = (Rand(2) + 1);
	fDecision = FRand();
	// End:0x42
	if((m_iHealth == 1))
	{
		m_iHealth = 0;		
	}
	else
	{
		// End:0x4F
		if((m_iHealth > 1))
		{
			return;
		}
	}
	// End:0x95
	if((m_szSpecialityID == "ID_ASSAULT"))
	{
		(m_fAssault += ((fIncreaseSkill * (float((iD5 + 5)) / 100.0000000)) * (float(100) - m_fAssault)));		
	}
	else
	{
		(m_fAssault += ((fIncreaseSkill * (float((iD2 + 2)) / 100.0000000)) * (float(100) - m_fAssault)));
	}
	// End:0x10C
	if((m_szSpecialityID == "ID_DEMOLITIONS"))
	{
		(m_fDemolitions += ((fIncreaseSkill * (float((iD5 + 5)) / 100.0000000)) * (float(100) - m_fDemolitions)));		
	}
	else
	{
		// End:0x13B
		if((fDecision <= 0.2000000))
		{
			(m_fDemolitions += (fIncreaseSkill * (0.0200000 * (float(100) - m_fDemolitions))));
		}
		fDecision = FRand();
	}
	// End:0x18D
	if((m_szSpecialityID == "ID_ELECTRONICS"))
	{
		(m_fElectronics += ((fIncreaseSkill * (float((iD5 + 5)) / 100.0000000)) * (float(100) - m_fElectronics)));		
	}
	else
	{
		// End:0x1BC
		if((fDecision <= 0.2000000))
		{
			(m_fElectronics += (fIncreaseSkill * (0.0200000 * (float(100) - m_fElectronics))));
		}
		fDecision = FRand();
	}
	// End:0x20A
	if((m_szSpecialityID == "ID_STEALTH"))
	{
		(m_fStealth += ((fIncreaseSkill * (float((iD5 + 5)) / 100.0000000)) * (float(100) - m_fStealth)));		
	}
	else
	{
		// End:0x239
		if((fDecision <= 0.2000000))
		{
			(m_fStealth += (fIncreaseSkill * (0.0200000 * (float(100) - m_fStealth))));
		}
		fDecision = FRand();
	}
	// End:0x286
	if((m_szSpecialityID == "ID_SNIPER"))
	{
		(m_fSniper += ((fIncreaseSkill * (float((iD5 + 5)) / 100.0000000)) * (float(100) - m_fSniper)));		
	}
	else
	{
		// End:0x2B5
		if((fDecision <= 0.2000000))
		{
			(m_fSniper += (fIncreaseSkill * (0.0200000 * (float(100) - m_fSniper))));
		}
		fDecision = FRand();
	}
	// End:0x2EC
	if((fDecision <= 0.2000000))
	{
		(m_fSelfControl += (fIncreaseSkill * (0.0200000 * (float(100) - m_fSelfControl))));
	}
	fDecision = FRand();
	// End:0x323
	if((fDecision <= 0.2000000))
	{
		(m_fLeadership += (fIncreaseSkill * (0.0200000 * (float(100) - m_fLeadership))));
	}
	fDecision = FRand();
	// End:0x35A
	if((fDecision <= 0.2000000))
	{
		(m_fObservation += (fIncreaseSkill * (0.0200000 * (float(100) - m_fObservation))));
	}
	fDecision = FRand();
	return;
}

function DisplayStats()
{
	Log("------------------------");
	Log(GetName());
	Log(("m_fAssault     =" @ string(m_fAssault)));
	Log(("m_fElectronics =" @ string(m_fElectronics)));
	Log(("m_fSniper      =" @ string(m_fSniper)));
	Log(("m_fStealth     =" @ string(m_fStealth)));
	Log(("m_fSelfControl =" @ string(m_fSelfControl)));
	Log(("m_fLeadership  =" @ string(m_fLeadership)));
	Log(("m_fObservation =" @ string(m_fObservation)));
	Log("========================");
	return;
}

function CopyOperative(R6Operative aOperative)
{
	local int i;

	aOperative.m_szOperativeClass = m_szOperativeClass;
	aOperative.m_szCountryID = m_szCountryID;
	aOperative.m_szCityID = m_szCityID;
	aOperative.m_szStateID = m_szStateID;
	aOperative.m_szSpecialityID = m_szSpecialityID;
	aOperative.m_szHairColorID = m_szHairColorID;
	aOperative.m_szEyesColorID = m_szEyesColorID;
	aOperative.m_szGenderID = m_szGenderID;
	aOperative.m_TMenuFace = m_TMenuFace;
	i = 0;
	J0xBB:

	// End:0xFF [Loop If]
	if((i < m_OperativeFaces.Length))
	{
		aOperative.m_OperativeFaces[aOperative.m_OperativeFaces.Length] = m_OperativeFaces[i];
		(i++);
		// [Loop Continue]
		goto J0xBB;
	}
	aOperative.m_szGender = m_szGender;
	aOperative.m_fAssault = m_fAssault;
	aOperative.m_fDemolitions = m_fDemolitions;
	aOperative.m_fElectronics = m_fElectronics;
	aOperative.m_fSniper = m_fSniper;
	aOperative.m_fStealth = m_fStealth;
	aOperative.m_fSelfControl = m_fSelfControl;
	aOperative.m_fLeadership = m_fLeadership;
	aOperative.m_fObservation = m_fObservation;
	aOperative.m_iHealth = m_iHealth;
	aOperative.m_iNbMissionPlayed = m_iNbMissionPlayed;
	aOperative.m_iTerrokilled = m_iTerrokilled;
	aOperative.m_iRoundsfired = m_iRoundsfired;
	aOperative.m_iRoundsOntarget = m_iRoundsOntarget;
	return;
}

defaultproperties
{
	m_iUniqueID=-1
	m_iRookieID=-1
	m_RMenuFaceY=420
	m_RMenuFaceW=175
	m_RMenuFaceH=81
	m_RMenuFaceSmallX=456
	m_RMenuFaceSmallY=132
	m_RMenuFaceSmallW=38
	m_RMenuFaceSmallH=42
	m_TMenuFace=Texture'R6MenuOperative.RS6_Memeber_03'
	m_TMenuFaceSmall=Texture'R6MenuOperative.RS6_Memeber_01'
	m_CanUseArmorType="R6ArmorDescription"
	m_szOperativeClass="R6Operative"
	m_szCountryID="ID_SPAIN"
	m_szCityID="ID_MALAGA"
	m_szSpecialityID="ID_ASSAULT"
	m_szHairColorID="ID_BROWN"
	m_szEyesColorID="ID_BLUE"
	m_szGenderID="ID_MALE"
	m_szGender="M"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var Y
// REMOVED IN 1.60: var W
// REMOVED IN 1.60: var H
