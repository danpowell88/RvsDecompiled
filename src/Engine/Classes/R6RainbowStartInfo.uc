// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6RainbowStartInfo extends Actor
    native;

// --- Variables ---
var string m_CharacterName;
var string m_ArmorName;
var string m_szSpecialityID;
var string m_WeaponName[2];
var string m_BulletType[2];
var string m_WeaponGadgetName[2];
var string m_GadgetName[2];
// for the skills see definition in class r6pawn
var float m_fSkillAssault;
var float m_fSkillDemolitions;
var float m_fSkillElectronics;
var float m_fSkillSniper;
var float m_fSkillStealth;
var float m_fSkillSelfControl;
var float m_fSkillLeadership;
var float m_fSkillObservation;
//0= Ready, 1=Wounded, 2=Incapacitated, 3=Dead
var int m_iHealth;
//Allow us to retreive the corresponding R6Operative
var int m_iOperativeID;
//Sex of the operative
var bool m_bIsMale;
var Plane m_FaceCoords;
var Material m_FaceTexture;

defaultproperties
{
}
