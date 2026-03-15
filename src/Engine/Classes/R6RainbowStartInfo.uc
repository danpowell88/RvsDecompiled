//=============================================================================
// R6RainbowStartInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
/********************************************************************
	created:	2001/06/19
	filename: 	R6RainbowStartInfo.uc
	author:		Joel Tremblay
	
	purpose:	Informations set by the menu 
                list all the selected equipment for characters
	
	Modification:

*********************************************************************/
class R6RainbowStartInfo extends Actor
    native
    notplaceable;

var int m_iHealth;  // 0= Ready, 1=Wounded, 2=Incapacitated, 3=Dead
var int m_iOperativeID;  // Allow us to retreive the corresponding R6Operative
var bool m_bIsMale;  // Sex of the operative
var float m_fSkillAssault;  // for the skills see definition in class r6pawn
var float m_fSkillDemolitions;
var float m_fSkillElectronics;
var float m_fSkillSniper;
var float m_fSkillStealth;
var float m_fSkillSelfControl;
var float m_fSkillLeadership;
var float m_fSkillObservation;
var Material m_FaceTexture;
var Plane m_FaceCoords;
var string m_CharacterName;
var string m_ArmorName;
var string m_szSpecialityID;
var string m_WeaponName[2];
var string m_BulletType[2];
var string m_WeaponGadgetName[2];
var string m_GadgetName[2];

defaultproperties
{
	m_bIsMale=true
	bHidden=true
}
