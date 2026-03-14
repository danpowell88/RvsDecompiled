// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6HostageMgr extends R6AbstractHostageMgr;

// --- Constants ---
const HSTSNDEvent_Max =  11;
const HSTSNDEvent_InjuredByRainbow =  10;
const HSTSNDEvent_AskedToStayPut =  9;
const HSTSNDEvent_FollowRainbow =  8;
const HSTSNDEvent_GoFoetal =  7;
const HSTSNDEvent_SeeRainbowBaitOrGoFrozen =  6;
const HSTSNDEvent_HstRunTowardRainbow =  5;
const HSTSNDEvent_CivRunTowardRainbow =  4;
const HSTSNDEvent_RunForCover =  3;
const HSTSNDEvent_CivSurrender =  2;
const HSTSNDEvent_HearShooting =  1;
const HSTSNDEvent_None =  0;

// --- Enums ---
enum EThreatType
{
    THREAT_none,        // do nothing
    THREAT_friend,      // is a friend and alive
    THREAT_sound,
    THREAT_surrender,
    THREAT_enemy,
    THREAT_underFire,
    THREAT_neutral,
    THREAT_misc
};
enum EPlayAnimType
{
    ePlayType_Default,  // play the anim like specified by his rate
    ePlayType_Random    // play the anim normal or in reverse
};
enum EGroupAnimType
{
    eGroupAnim_none,
    eGroupAnim_transition,
    eGroupAnim_wait,
    eGroupAnim_reaction
};
enum EAnimTransType 
{
    eAnimTrans_none,
    eAnimTrans_animTransInfo,      // defined has a animation transition info
    eAnimTrans_groupTransition,    // the animation is of group sequence 'Transition'
    eAnimTrans_manual              // manually set to blend with what is playing right now
};

// --- Structs ---
struct ThreatInfo
{
    // **** if modified, update this struct in r6engine.h ****
    var INT           m_id;                 // index in m_aThreatDefinition
    var INT           m_iThreatLevel;       // directly copied from ThreatDefinition for quick access
    var Pawn          m_pawn;               // the actor
    var Actor         m_actorExt;           // the actor extention; ie like his grenade
    var INT           m_bornTime;           // born time
    var vector        m_originalLocation;   // original location
    var name          m_state;
    // **** if modified, update this struct in r6engine.h ****
};

struct AnimInfo
{
    var name            m_name;         // name of the anim
    var INT             m_id;           // index in the array of m_aAnimInfo
    var float           m_fRate;        // the rate to play the anim
    var EPlayAnimType   m_ePlayType;    // play the anim normal or in reverse
    var EGroupAnimType  m_eGroupAnim;
};

struct AnimTransInfo
{
    // **** if modified, update this struct in r6engine.h ****
    var name  m_AIState;
    var name  m_pawnState;
    var name  m_sourceAnimName;
    var INT   m_iSourceAnim;
    var name  m_targetAnimName;
    var INT   m_iTargetAnim;
    var float m_fTime;
    var float m_fTargetAnimRate;
    // **** if modified, update this struct in r6engine.h ****
};

struct ThreatDefinition
{
    //todop: optimize loop search by using the groupname and exiting if no longer in the groupd
    var name          m_groupName;          // Civ / Freed / Guarded 
    var string        m_szName;             // "a rainbow"
    var EThreatType   m_eThreatType;        // THREAT_rainbow
    var ENoiseType    m_eNoiseType;         // NOISE_Grenade
    var INT           m_iThreatLevel;       // 0: no level... 
    var INT           m_iCaringDistance;    // distance to start to care about this threat
    var name          m_considerThreat;     // extra check for this threat. handle exception for a threat, if == none, yes.
};

struct ReactionInfo
{
    var name    m_groupName; // same one used for ThreatDefinition
    var INT     m_iThreatLevel;
    var INT     m_iChance;
    var name    m_gotoState;
};

struct HstSndEventInfo 
{
    var int                          m_iHstSndEvent;
    var R6Pawn.EHostagePersonality   m_ePerso;
    var R6Pawn.EHostageVoices        m_eVoice;
};

// --- Variables ---
// var ? m_AIState; // REMOVED IN 1.60
// var ? m_actorExt; // REMOVED IN 1.60
// var ? m_bornTime; // REMOVED IN 1.60
// var ? m_considerThreat; // REMOVED IN 1.60
// var ? m_eGroupAnim; // REMOVED IN 1.60
// var ? m_eNoiseType; // REMOVED IN 1.60
// var ? m_ePerso; // REMOVED IN 1.60
// var ? m_ePlayType; // REMOVED IN 1.60
// var ? m_eThreatType; // REMOVED IN 1.60
// var ? m_eVoice; // REMOVED IN 1.60
// var ? m_fRate; // REMOVED IN 1.60
// var ? m_fTargetAnimRate; // REMOVED IN 1.60
// var ? m_fTime; // REMOVED IN 1.60
// var ? m_gotoState; // REMOVED IN 1.60
// var ? m_groupName; // REMOVED IN 1.60
// var ? m_iCaringDistance; // REMOVED IN 1.60
// var ? m_iChance; // REMOVED IN 1.60
// var ? m_iHstSndEvent; // REMOVED IN 1.60
// var ? m_iSourceAnim; // REMOVED IN 1.60
// var ? m_iTargetAnim; // REMOVED IN 1.60
// var ? m_iThreatLevel; // REMOVED IN 1.60
// var ? m_id; // REMOVED IN 1.60
// var ? m_name; // REMOVED IN 1.60
// var ? m_originalLocation; // REMOVED IN 1.60
// var ? m_pawn; // REMOVED IN 1.60
// var ? m_pawnState; // REMOVED IN 1.60
// var ? m_sourceAnimName; // REMOVED IN 1.60
// var ? m_state; // REMOVED IN 1.60
// var ? m_szName; // REMOVED IN 1.60
// var ? m_targetAnimName; // REMOVED IN 1.60
var const name c_ThreatGroup_Civ;
var ThreatDefinition m_aThreatDefinition[27];
var AnimInfo m_aAnimInfo[40];
var const name c_ThreatGroup_HstGuarded;
var const name c_ThreatGroup_HstFreed;
var int m_iThreatDefinitionIndex;
var AnimTransInfo m_aAnimTransInfo[32];
var int m_iAnimTransIndex;
var const name c_ThreatGroup_HstBait;
var ReactionInfo m_aReactions[24];
var int m_iReactionIndex;
var const int c_ThreatLevel_Surrender;
var const name c_ThreatGroup_HstEscorted;
var HstSndEventInfo m_aHstSndEventInfo[24];
var name m_noReactionName;
var int ANIM_eStandWaitShiftWeight;
var int ANIM_eScaredStandWait01;
// ** last one **
var int ANIM_eMAX;
var const int c_iDetectGrenadeRadius;
var int ANIM_eFoetusWait01;
var int ANIM_eFoetusWait02;
var int ANIM_eKneelFreeze;
var int ANIM_eKneelReact01;
var int ANIM_eKneelReact02;
var int ANIM_eKneelReact03;
var int ANIM_eKneelWait01;
var int ANIM_eScaredStandWait02;
var int ANIM_eStandHandUpFreeze;
var int ANIM_eStandHandUpReact01;
var int ANIM_eStandHandUpReact02;
var int ANIM_eStandHandUpReact03;
var int ANIM_eStandHandUpToDown;
var int ANIM_eStandWaitCough;
var int ANIM_eProneToCrouch;
var int ANIM_eCrouchToProne;
var int ANIM_eCrouchToScaredStand;
var int ANIM_eCrouchWait01;
var int ANIM_eCrouchWait02;
var int ANIM_eFoetusToCrouch;
var int ANIM_eFoetusToKneel;
var int ANIM_eFoetusToProne;
var int ANIM_eFoetusToStand;
var int ANIM_eFoetus_nt;
var int ANIM_eKneelToCrouch;
var int ANIM_eKneelToFoetus;
var int ANIM_eKneelToProne;
var int ANIM_eKneelToStand;
var int ANIM_eKneelWait02;
var int ANIM_eKneelWait03;
var int ANIM_eStandHandDownToUp;
var int ANIM_eStandHandUpWait01;
var int ANIM_eStandToFoetus;
var int ANIM_eStandToKneel;
var int ANIM_eProneWaitBreathe;
// the hostage should surrender when they are X meter from Pawn
var const int c_iSurrenderRadius;
// the hostage consider being under fire when in this radius
var const int c_iDetectUnderFireRadius;
//------------------------------------------------------------------
//	Animation
//------------------------------------------------------------------
var int ANIM_eBlinded;
var int ANIM_eGazed;
var int ANIM_eKneel_nt;
var bool bShowLog;
var int ANIM_eScaredStand_nt;
var int ANIM_eCrouchWalkBack;
// distance from a sound that he react...
var const int c_iDetectThreatSound;

// --- Functions ---
//------------------------------------------------------------------
// InsertThreatDefinition
//
//------------------------------------------------------------------
function InsertThreatDefinition(name GroupName, string szName, int iThreatLevel, EThreatType EThreatType, ENoiseType ENoiseType, int iCaringDistance, optional name considerThreat) {}
//------------------------------------------------------------------
// InsertAnimTransInfo
//
//------------------------------------------------------------------
function InsertAnimTransInfo(int iTargetAnim, int iSourceAnim, name pawnState, float fTime) {}
//------------------------------------------------------------------
// InsertSndEventInfo
//
//------------------------------------------------------------------
function InsertSndEventInfo(int Index, int iSndEvent, EHostagePersonality ePerso, EHostageVoices eVoice) {}
//------------------------------------------------------------------
// GetAnimInfo: workaround for "variable name is too long"
//
//------------------------------------------------------------------
function AnimInfo GetAnimInfo(int ID) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetThreatDefinition:
//
//------------------------------------------------------------------
function GetThreatDefinition(int Index, out ThreatDefinition oDefinition) {}
//------------------------------------------------------------------
// GetThreatName
//------------------------------------------------------------------
function string GetThreatName(int Index) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// InsertReaction
//
//------------------------------------------------------------------
function InsertReaction(name GroupName, int iLevel, int iRoll, name stateName) {}
//------------------------------------------------------------------
// GetHostageSndEventPlay
//
//------------------------------------------------------------------
function EHostageVoices GetHostageVoices(int Index) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetHostageSndEvent: depending of the snd event and the perso.
// Exception when hostage sees Rainbow but is also close to Terrorist,
// the personnality is not used
//------------------------------------------------------------------
function int GetHostageSndEvent(int iSndEvent, R6Hostage H) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetAnimIndex
//
//------------------------------------------------------------------
function int GetAnimIndex(name animName) {}
// ^ NEW IN 1.60
//============================================================================
// logX - Log with more information for debugging.  Display:
//          controller, source, controller state, pawn state and a string
//============================================================================
function logX(string szText, optional int iSource) {}
//------------------------------------------------------------------
// GetAnimTransInfo: get the animTransiitionInfo for this source
//	and target, and it fills info. If not found return false
//------------------------------------------------------------------
function bool GetAnimTransInfo(name sourceAnimName, int iTargetAnim, out AnimTransInfo Info) {}
// ^ NEW IN 1.60
function string GetAnimTransInfoLog(AnimTransInfo Info, optional EAnimTransType eType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// InitSndEventInfo
//
//------------------------------------------------------------------
function InitSndEventInfo() {}
//------------------------------------------------------------------
// getDefaulThreatInfo
//
//------------------------------------------------------------------
function ThreatInfo getDefaulThreatInfo() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetThreatInfoFromThreatSurrender
//
//------------------------------------------------------------------
function GetThreatInfoFromThreatSurrender(out ThreatInfo oThreatInfo, Pawn threat) {}
//------------------------------------------------------------------
// GetReaction: return the state to go
//	if '' is return, do nothing
//------------------------------------------------------------------
function name GetReaction(int iLevel, name GroupName, int iRoll) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetThreatInfoLog:
//
//------------------------------------------------------------------
function string GetThreatInfoLog(ThreatInfo Info) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// InsertAnimInfo: insert an anim in m_aAnimInfo and sets all his
//	properties
//------------------------------------------------------------------
function InsertAnimInfo(out int ID, optional float fRate, name aName, optional EGroupAnimType eGroupAnim, optional EPlayAnimType ePlayType) {}
//------------------------------------------------------------------
// ValidAnimInfo: do some validation of all animInfo. Called after the
//	last insertAnimInfo
//------------------------------------------------------------------
function ValidAnimInfo() {}
//------------------------------------------------------------------
// GetThreatInfoFromThreat: return the ThreatInfo associated with
//	the current info of threat based on the highest level of
//  of the threat (ie: the more dangerous to the civilian)
//------------------------------------------------------------------
function bool GetThreatInfoFromThreat(out ThreatInfo oThreatInfo, Actor threat, R6Hostage hostage, ENoiseType eType, name threatGroupName) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ValidMgr: valid some data of manager. can be called only once
//
//------------------------------------------------------------------
function ValidMgr(R6HostageAI AI) {}
function InitReactionForClassicMissionCivilian() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// InitReaction
//
//------------------------------------------------------------------
function InitReaction() {}
//------------------------------------------------------------------
// InitThreatDefinition: insert all the threat definition in an array
//
//------------------------------------------------------------------
function InitThreatDefinition() {}
//------------------------------------------------------------------
// PostBeginPlay: init and valid data for the manager
//
//------------------------------------------------------------------
function PostBeginPlay() {}
//------------------------------------------------------------------
// GetAnimInfoSize: workaround for "variable name is too long"
//
//------------------------------------------------------------------
function int GetAnimInfoSize() {}
// ^ NEW IN 1.60

defaultproperties
{
}
