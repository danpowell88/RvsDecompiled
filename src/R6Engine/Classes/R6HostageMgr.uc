//=============================================================================
// R6HostageMgr - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6HostageMgr extends R6AbstractHostageMgr;

const HSTSNDEvent_None = 0;
const HSTSNDEvent_HearShooting = 1;
const HSTSNDEvent_CivSurrender = 2;
const HSTSNDEvent_RunForCover = 3;
const HSTSNDEvent_CivRunTowardRainbow = 4;
const HSTSNDEvent_HstRunTowardRainbow = 5;
const HSTSNDEvent_SeeRainbowBaitOrGoFrozen = 6;
const HSTSNDEvent_GoFoetal = 7;
const HSTSNDEvent_FollowRainbow = 8;
const HSTSNDEvent_AskedToStayPut = 9;
const HSTSNDEvent_InjuredByRainbow = 10;
const HSTSNDEvent_Max = 11;

enum EThreatType
{
	THREAT_none,                    // 0
	THREAT_friend,                  // 1
	THREAT_sound,                   // 2
	THREAT_surrender,               // 3
	THREAT_enemy,                   // 4
	THREAT_underFire,               // 5
	THREAT_neutral,                 // 6
	THREAT_misc                     // 7
};

enum EPlayAnimType
{
	ePlayType_Default,              // 0
	ePlayType_Random                // 1
};

enum EGroupAnimType
{
	eGroupAnim_none,                // 0
	eGroupAnim_transition,          // 1
	eGroupAnim_wait,                // 2
	eGroupAnim_reaction             // 3
};

enum EAnimTransType
{
	eAnimTrans_none,                // 0
	eAnimTrans_animTransInfo,       // 1
	eAnimTrans_groupTransition,     // 2
	eAnimTrans_manual               // 3
};

struct ThreatDefinition
{
    //todop: optimize loop search by using the groupname and exiting if no longer in the groupd
	var name m_groupName;  // Civ / Freed / Guarded
	var string m_szName;  // "a rainbow"
	var R6HostageMgr.EThreatType m_eThreatType;  // THREAT_rainbow
	var Actor.ENoiseType m_eNoiseType;  // NOISE_Grenade
	var int m_iThreatLevel;  // 0: no level...
	var int m_iCaringDistance;  // distance to start to care about this threat
	var name m_considerThreat;  // extra check for this threat. handle exception for a threat, if == none, yes.
};

struct ThreatInfo
{
    // **** if modified, update this struct in r6engine.h ****
	var int m_id;  // index in m_aThreatDefinition
	var int m_iThreatLevel;  // 0: no level...
	var Pawn m_pawn;  // the actor
	var Actor m_actorExt;  // the actor extention; ie like his grenade
	var int m_bornTime;  // born time
	var Vector m_originalLocation;  // original location
	var name m_state;
};

struct ReactionInfo
{
    //todop: optimize loop search by using the groupname and exiting if no longer in the groupd
	var name m_groupName;  // Civ / Freed / Guarded
	var int m_iThreatLevel;  // 0: no level...
	var int m_iChance;
	var name m_gotoState;
};

struct HstSndEventInfo
{
	var int m_iHstSndEvent;
	var R6Pawn.EHostagePersonality m_ePerso;
	var Pawn.EHostageVoices m_eVoice;
};

struct AnimInfo
{
	var name m_name;  // name of the anim
    // **** if modified, update this struct in r6engine.h ****
	var int m_id;  // index in m_aThreatDefinition
	var float m_fRate;  // the rate to play the anim
	var R6HostageMgr.EPlayAnimType m_ePlayType;  // play the anim normal or in reverse
	var R6HostageMgr.EGroupAnimType m_eGroupAnim;
};

struct AnimTransInfo
{
    // **** if modified, update this struct in r6engine.h ****
	var name m_AIState;
	var name m_pawnState;
	var name m_sourceAnimName;
	var int m_iSourceAnim;
	var name m_targetAnimName;
	var int m_iTargetAnim;
	var float m_fTime;
	var float m_fTargetAnimRate;
};

var const int c_iSurrenderRadius;  // the hostage should surrender when they are X meter from Pawn
var const int c_iDetectUnderFireRadius;  // the hostage consider being under fire when in this radius
var const int c_iDetectThreatSound;  // distance from a sound that he react...
var const int c_iDetectGrenadeRadius;
var const int c_ThreatLevel_Surrender;
//------------------------------------------------------------------
//	Animation
//------------------------------------------------------------------
var int ANIM_eBlinded;
var int ANIM_eCrouchToProne;
var int ANIM_eCrouchToScaredStand;
var int ANIM_eCrouchWait01;
var int ANIM_eCrouchWait02;
var int ANIM_eCrouchWalkBack;
var int ANIM_eFoetusToCrouch;
var int ANIM_eFoetusToKneel;
var int ANIM_eFoetusToProne;
var int ANIM_eFoetusToStand;
var int ANIM_eFoetusWait01;
var int ANIM_eFoetusWait02;
var int ANIM_eFoetus_nt;
var int ANIM_eGazed;
var int ANIM_eKneelFreeze;
var int ANIM_eKneelReact01;
var int ANIM_eKneelReact02;
var int ANIM_eKneelReact03;
var int ANIM_eKneelToCrouch;
var int ANIM_eKneelToFoetus;
var int ANIM_eKneelToProne;
var int ANIM_eKneelToStand;
var int ANIM_eKneelWait01;
var int ANIM_eKneelWait02;
var int ANIM_eKneelWait03;
var int ANIM_eKneel_nt;
var int ANIM_eScaredStandWait01;
var int ANIM_eScaredStandWait02;
var int ANIM_eScaredStand_nt;
var int ANIM_eStandHandUpFreeze;
var int ANIM_eStandHandUpReact01;
var int ANIM_eStandHandUpReact02;
var int ANIM_eStandHandUpReact03;
var int ANIM_eStandHandUpToDown;
var int ANIM_eStandHandDownToUp;
var int ANIM_eStandHandUpWait01;
var int ANIM_eStandToFoetus;
var int ANIM_eStandToKneel;
var int ANIM_eStandWaitCough;
var int ANIM_eStandWaitShiftWeight;
var int ANIM_eProneToCrouch;
var int ANIM_eProneWaitBreathe;
var int ANIM_eMAX;  // ** last one **
var int m_iThreatDefinitionIndex;
var int m_iReactionIndex;
var int m_iAnimTransIndex;
var bool bShowLog;
var const name c_ThreatGroup_Civ;
var const name c_ThreatGroup_HstFreed;
var const name c_ThreatGroup_HstGuarded;
var const name c_ThreatGroup_HstBait;
var const name c_ThreatGroup_HstEscorted;
var name m_noReactionName;
var HstSndEventInfo m_aHstSndEventInfo[24];
var AnimInfo m_aAnimInfo[40];
// NEW IN 1.60
var ThreatDefinition m_aThreatDefinition[27];
var ReactionInfo m_aReactions[24];
var AnimTransInfo m_aAnimTransInfo[32];

//============================================================================
// logX - Log with more information for debugging.  Display:
//          controller, source, controller state, pawn state and a string
//============================================================================
function logX(string szText, optional int iSource)
{
	local string szSource, Time;

	Time = string(Level.TimeSeconds);
	Time = __NFUN_128__(Time, __NFUN_146__(__NFUN_126__(Time, "."), 3));
	szSource = __NFUN_112__(__NFUN_112__("(", Time), ":X) ");
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(szSource, string(Name)), ""), szText));
	return;
}

//------------------------------------------------------------------
// InsertAnimTransInfo
//	
//------------------------------------------------------------------
function InsertAnimTransInfo(int iSourceAnim, int iTargetAnim, name pawnState, float fTime)
{
	// End:0x10
	if(__NFUN_153__(m_iAnimTransIndex, 32))
	{
		assert(false);
	}
	m_aAnimTransInfo[m_iAnimTransIndex].m_fTime = fTime;
	m_aAnimTransInfo[m_iAnimTransIndex].m_pawnState = pawnState;
	m_aAnimTransInfo[m_iAnimTransIndex].m_iSourceAnim = iSourceAnim;
	m_aAnimTransInfo[m_iAnimTransIndex].m_sourceAnimName = GetAnimInfo(iSourceAnim).m_name;
	m_aAnimTransInfo[m_iAnimTransIndex].m_iTargetAnim = iTargetAnim;
	m_aAnimTransInfo[m_iAnimTransIndex].m_targetAnimName = GetAnimInfo(iTargetAnim).m_name;
	m_aAnimTransInfo[m_iAnimTransIndex].m_fTargetAnimRate = GetAnimInfo(iTargetAnim).m_fRate;
	__NFUN_165__(m_iAnimTransIndex);
	return;
}

function string GetAnimTransInfoLog(AnimTransInfo Info, optional R6HostageMgr.EAnimTransType eType)
{
	local string szLog, szType;

	// End:0x1F
	if(__NFUN_154__(int(eType), int(1)))
	{
		szType = "data";		
	}
	else
	{
		// End:0x3F
		if(__NFUN_154__(int(eType), int(2)))
		{
			szType = "group";			
		}
		else
		{
			// End:0x60
			if(__NFUN_154__(int(eType), int(3)))
			{
				szType = "manual";				
			}
			else
			{
				szType = "none";
			}
		}
	}
	szLog = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("AnimTransType: ", szType), " src: "), string(Info.m_sourceAnimName)), " target: "), string(Info.m_targetAnimName)), " time: "), string(Info.m_fTime)), " rate: "), string(Info.m_fTargetAnimRate)), " toAIstate: "), string(Info.m_AIState)), " toPawnState: "), string(Info.m_pawnState));
	return szLog;
	return;
}

//------------------------------------------------------------------
// GetAnimTransInfo: get the animTransiitionInfo for this source
//	and target, and it fills info. If not found return false
//------------------------------------------------------------------
function bool GetAnimTransInfo(name sourceAnimName, int iTargetAnim, out AnimTransInfo Info)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x69 [Loop If]
	if(__NFUN_150__(i, m_iAnimTransIndex))
	{
		// End:0x5F
		if(__NFUN_130__(__NFUN_254__(sourceAnimName, m_aAnimTransInfo[i].m_sourceAnimName), __NFUN_154__(iTargetAnim, m_aAnimTransInfo[i].m_iTargetAnim)))
		{
			Info = m_aAnimTransInfo[i];
			return true;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// GetAnimInfo: workaround for "variable name is too long"
//	
//------------------------------------------------------------------
function AnimInfo GetAnimInfo(int ID)
{
	return m_aAnimInfo[ID];
	return;
}

//------------------------------------------------------------------
// GetAnimIndex
//	
//------------------------------------------------------------------
function int GetAnimIndex(name animName)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x3D [Loop If]
	if(__NFUN_150__(i, 40))
	{
		// End:0x33
		if(__NFUN_254__(m_aAnimInfo[i].m_name, animName))
		{
			return i;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return 0;
	return;
}

//------------------------------------------------------------------
// GetAnimInfoSize: workaround for "variable name is too long"
//	
//------------------------------------------------------------------
function int GetAnimInfoSize()
{
	return 40;
	return;
}

//------------------------------------------------------------------
// InsertAnimInfo: insert an anim in m_aAnimInfo and sets all his
//	properties
//------------------------------------------------------------------
function InsertAnimInfo(name aName, out int ID, optional R6HostageMgr.EGroupAnimType eGroupAnim, optional R6HostageMgr.EPlayAnimType ePlayType, optional float fRate)
{
	ID = ANIM_eMAX;
	__NFUN_165__(ANIM_eMAX);
	// End:0x2A
	if(__NFUN_180__(fRate, float(0)))
	{
		fRate = 1.0000000;
	}
	// End:0xBF
	if(__NFUN_255__(m_aAnimInfo[ID].m_name, 'None'))
	{
		__NFUN_231__(__NFUN_112__(__NFUN_168__(__NFUN_168__(__NFUN_168__(__NFUN_168__("ScriptWarning: Hostage anim ", string(aName)), " was not inserted. Conflict with "), string(m_aAnimInfo[ID].m_name)), " at index "), string(ID)));
		return;
	}
	m_aAnimInfo[ID].m_id = ID;
	m_aAnimInfo[ID].m_name = aName;
	m_aAnimInfo[ID].m_fRate = fRate;
	m_aAnimInfo[ID].m_ePlayType = ePlayType;
	m_aAnimInfo[ID].m_eGroupAnim = eGroupAnim;
	return;
}

//------------------------------------------------------------------
// ValidAnimInfo: do some validation of all animInfo. Called after the
//	last insertAnimInfo
//------------------------------------------------------------------
function ValidAnimInfo()
{
	local int i, j;
	local string playType;

	// End:0x6A
	if(__NFUN_155__(40, ANIM_eMAX))
	{
		__NFUN_231__(__NFUN_112__(__NFUN_168__(__NFUN_168__("ScriptWarning: m_aAnimInfo wrong size. Array size is ", string(40)), " and ANIM_eMAX is "), string(ANIM_eMAX)));
	}
	i = 0;
	J0x71:

	// End:0x10F [Loop If]
	if(__NFUN_150__(i, 40))
	{
		// End:0xCA
		if(__NFUN_254__(m_aAnimInfo[i].m_name, 'None'))
		{
			__NFUN_231__(__NFUN_112__("ScriptWarning: missing anim index: ", string(i)));
			// [Explicit Continue]
			goto J0x105;
		}
		// End:0xF6
		if(__NFUN_154__(int(m_aAnimInfo[i].m_ePlayType), int(1)))
		{
			playType = "random";
			// [Explicit Continue]
			goto J0x105;
		}
		playType = "default";
		J0x105:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x71;
	}
	i = 0;
	J0x116:

	// End:0x209 [Loop If]
	if(__NFUN_150__(i, 40))
	{
		// End:0x13F
		if(__NFUN_254__(m_aAnimInfo[i].m_name, 'None'))
		{
			// [Explicit Continue]
			goto J0x1FF;
		}
		j = 0;
		J0x146:

		// End:0x1FF [Loop If]
		if(__NFUN_150__(j, 40))
		{
			// End:0x164
			if(__NFUN_154__(i, j))
			{
				// [Explicit Continue]
				goto J0x1F5;
			}
			// End:0x1F5
			if(__NFUN_254__(m_aAnimInfo[i].m_name, m_aAnimInfo[j].m_name))
			{
				// End:0x1F5
				if(__NFUN_180__(m_aAnimInfo[i].m_fRate, m_aAnimInfo[j].m_fRate))
				{
					__NFUN_231__(__NFUN_112__(__NFUN_168__(__NFUN_168__("ScriptWarning: identical anim at index: ", string(i)), " and "), string(j)));
				}
			}
			J0x1F5:

			__NFUN_165__(j);
			// [Loop Continue]
			goto J0x146;
		}
		J0x1FF:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x116;
	}
	return;
}

//------------------------------------------------------------------
// PostBeginPlay: init and valid data for the manager
//	
//------------------------------------------------------------------
function PostBeginPlay()
{
	m_noReactionName = 'HostageMgrNone';
	InitSndEventInfo();
	InitThreatDefinition();
	// End:0x32
	if(Level.m_bIsClassicMission)
	{
		InitReactionForClassicMissionCivilian();		
	}
	else
	{
		InitReaction();
	}
	InsertAnimInfo('Blinded', ANIM_eBlinded);
	InsertAnimInfo('CrouchToProne', ANIM_eCrouchToProne, 1);
	InsertAnimInfo('CrouchToScaredStand', ANIM_eCrouchToScaredStand, 1);
	InsertAnimInfo('CrouchWait01', ANIM_eCrouchWait01, 2, 1);
	InsertAnimInfo('CrouchWait02', ANIM_eCrouchWait02, 2);
	InsertAnimInfo('FoetusToCrouch', ANIM_eFoetusToCrouch, 1);
	InsertAnimInfo('FoetusToKneel', ANIM_eFoetusToKneel, 1);
	InsertAnimInfo('FoetusToProne', ANIM_eFoetusToProne, 1);
	InsertAnimInfo('FoetusToStand', ANIM_eFoetusToStand, 1);
	InsertAnimInfo('FoetusWait01', ANIM_eFoetusWait01, 2, 1);
	InsertAnimInfo('FoetusWait02', ANIM_eFoetusWait02, 2, 1);
	InsertAnimInfo('Foetus_nt', ANIM_eFoetus_nt);
	InsertAnimInfo('Gazed', ANIM_eGazed);
	InsertAnimInfo('KneelFreeze', ANIM_eKneelFreeze,, 1);
	InsertAnimInfo('KneelReact01', ANIM_eKneelReact01, 3, 1);
	InsertAnimInfo('KneelReact02', ANIM_eKneelReact02, 3, 1);
	InsertAnimInfo('KneelReact03', ANIM_eKneelReact03, 3, 1);
	InsertAnimInfo('KneelToCrouch', ANIM_eKneelToCrouch, 1);
	InsertAnimInfo('KneelToFoetus', ANIM_eKneelToFoetus, 1);
	InsertAnimInfo('KneelToProne', ANIM_eKneelToProne, 1);
	InsertAnimInfo('KneelToStand', ANIM_eKneelToStand, 1);
	InsertAnimInfo('KneelWait01', ANIM_eKneelWait01, 2, 1);
	InsertAnimInfo('KneelWait02', ANIM_eKneelWait02, 2, 1);
	InsertAnimInfo('KneelWait03', ANIM_eKneelWait03, 2, 1);
	InsertAnimInfo('Kneel_nt', ANIM_eKneel_nt);
	InsertAnimInfo('ScaredStandWait01', ANIM_eScaredStandWait01, 2, 1);
	InsertAnimInfo('ScaredStandWait02', ANIM_eScaredStandWait02, 2, 1);
	InsertAnimInfo('StandHandUpFreeze', ANIM_eStandHandUpFreeze,, 1);
	InsertAnimInfo('StandHandUpReact01', ANIM_eStandHandUpReact01, 3, 1);
	InsertAnimInfo('StandHandUpReact02', ANIM_eStandHandUpReact02, 3, 1);
	InsertAnimInfo('StandHandUpReact03', ANIM_eStandHandUpReact03, 3, 1);
	InsertAnimInfo('StandHandUpToDown', ANIM_eStandHandUpToDown, 1);
	InsertAnimInfo('StandHandDownToUp', ANIM_eStandHandDownToUp, 1);
	InsertAnimInfo('StandHandUpWait01', ANIM_eStandHandUpWait01, 2, 1);
	InsertAnimInfo('StandToFoetus', ANIM_eStandToFoetus, 1);
	InsertAnimInfo('StandToKneel', ANIM_eStandToKneel, 1);
	InsertAnimInfo('StandWaitCough', ANIM_eStandWaitCough, 2);
	InsertAnimInfo('StandWaitShiftWeight', ANIM_eStandWaitShiftWeight, 2, 1);
	InsertAnimInfo('ProneToCrouch', ANIM_eProneToCrouch, 1);
	InsertAnimInfo('ProneWaitBreathe', ANIM_eProneWaitBreathe, 2);
	ValidAnimInfo();
	return;
}

//------------------------------------------------------------------
// InsertThreatDefinition
//	
//------------------------------------------------------------------
function InsertThreatDefinition(name GroupName, string szName, R6HostageMgr.EThreatType EThreatType, Actor.ENoiseType ENoiseType, int iThreatLevel, int iCaringDistance, optional name considerThreat)
{
	assert(__NFUN_150__(m_iThreatDefinitionIndex, 27));
	// End:0x9A
	if(__NFUN_151__(m_iThreatDefinitionIndex, 1))
	{
		// End:0x9A
		if(__NFUN_130__(__NFUN_150__(m_aThreatDefinition[__NFUN_147__(m_iThreatDefinitionIndex, 1)].m_iThreatLevel, iThreatLevel), __NFUN_254__(m_aThreatDefinition[__NFUN_147__(m_iThreatDefinitionIndex, 1)].m_groupName, GroupName)))
		{
			__NFUN_231__(__NFUN_112__("ScriptWarning: InsertThreatDefinition wrong ThreatLevel for ", szName));
		}
	}
	m_aThreatDefinition[m_iThreatDefinitionIndex].m_groupName = GroupName;
	m_aThreatDefinition[m_iThreatDefinitionIndex].m_szName = szName;
	m_aThreatDefinition[m_iThreatDefinitionIndex].m_eThreatType = EThreatType;
	m_aThreatDefinition[m_iThreatDefinitionIndex].m_eNoiseType = ENoiseType;
	m_aThreatDefinition[m_iThreatDefinitionIndex].m_iThreatLevel = iThreatLevel;
	m_aThreatDefinition[m_iThreatDefinitionIndex].m_iCaringDistance = iCaringDistance;
	m_aThreatDefinition[m_iThreatDefinitionIndex].m_considerThreat = considerThreat;
	__NFUN_165__(m_iThreatDefinitionIndex);
	return;
}

//------------------------------------------------------------------
// GetThreatInfoLog: 
//	
//------------------------------------------------------------------
function string GetThreatInfoLog(ThreatInfo Info)
{
	local string szOutput;
	local name pawnName, ActorName;
	local int Index;

	Index = __NFUN_251__(Info.m_id, 0, Info.m_id);
	// End:0x3B
	if(__NFUN_114__(Info.m_pawn, none))
	{
		pawnName = ' ';		
	}
	else
	{
		pawnName = Info.m_pawn.Name;
	}
	// End:0x72
	if(__NFUN_114__(Info.m_actorExt, none))
	{
		ActorName = ' ';		
	}
	else
	{
		ActorName = Info.m_actorExt.Name;
	}
	szOutput = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("", string(m_aThreatDefinition[Index].m_groupName)), ": "), GetThreatName(Index)), ", a:"), string(ActorName)), " "), string(Info.m_iThreatLevel)), "s:"), string(Info.m_state)), " a2:"), string(ActorName));
	return szOutput;
	return;
}

//------------------------------------------------------------------
// GetThreatDefinition:  
//	
//------------------------------------------------------------------
function GetThreatDefinition(int Index, out ThreatDefinition oDefinition)
{
	oDefinition = m_aThreatDefinition[Index];
	return;
}

//------------------------------------------------------------------
// getDefaulThreatInfo
//	
//------------------------------------------------------------------
function ThreatInfo getDefaulThreatInfo()
{
	local ThreatInfo Info;

	Info.m_bornTime = 0;
	Info.m_id = 0;
	Info.m_originalLocation = vect(0.0000000, 0.0000000, 0.0000000);
	Info.m_pawn = none;
	Info.m_iThreatLevel = 0;
	Info.m_state = 'None';
	return Info;
	return;
}

//------------------------------------------------------------------
// GetThreatName
//------------------------------------------------------------------
function string GetThreatName(int Index)
{
	return m_aThreatDefinition[Index].m_szName;
	return;
}

//------------------------------------------------------------------
// GetThreatInfoFromThreat: return the ThreatInfo associated with
//	the current info of threat based on the highest level of
//  of the threat (ie: the more dangerous to the civilian)
//------------------------------------------------------------------
function bool GetThreatInfoFromThreat(name threatGroupName, R6Hostage hostage, Actor threat, Actor.ENoiseType eType, out ThreatInfo oThreatInfo)
{
	local bool bRealThreat;
	local int i;
	local Vector vDistance;
	local name threatClass;
	local bool bCheckDistance;
	local R6Pawn aPawn;

	bRealThreat = false;
	// End:0x34
	if(__NFUN_155__(int(eType), int(0)))
	{
		aPawn = R6Pawn(threat.Instigator);		
	}
	else
	{
		aPawn = R6Pawn(threat);
	}
	i = 1;
	J0x4B:

	// End:0x297 [Loop If]
	if(__NFUN_150__(i, 27))
	{
		bCheckDistance = false;
		// End:0x7F
		if(__NFUN_255__(m_aThreatDefinition[i].m_groupName, threatGroupName))
		{
			// [Explicit Continue]
			goto J0x28D;			
		}
		else
		{
			// End:0xB8
			if(__NFUN_155__(int(eType), int(0)))
			{
				// End:0xB5
				if(__NFUN_154__(int(m_aThreatDefinition[i].m_eNoiseType), int(eType)))
				{
					bCheckDistance = true;
				}				
			}
			else
			{
				// End:0x1C9
				if(__NFUN_119__(aPawn, none))
				{
					// End:0x12A
					if(__NFUN_154__(int(m_aThreatDefinition[i].m_eThreatType), int(4)))
					{
						// End:0x127
						if(__NFUN_130__(__NFUN_130__(hostage.IsEnemy(aPawn), aPawn.IsAlive()), __NFUN_129__(aPawn.m_bIsKneeling)))
						{
							bCheckDistance = true;
						}						
					}
					else
					{
						// End:0x17B
						if(__NFUN_154__(int(m_aThreatDefinition[i].m_eThreatType), int(1)))
						{
							// End:0x178
							if(__NFUN_130__(hostage.IsFriend(aPawn), aPawn.IsAlive()))
							{
								bCheckDistance = true;
							}							
						}
						else
						{
							// End:0x1C9
							if(__NFUN_154__(int(m_aThreatDefinition[i].m_eThreatType), int(6)))
							{
								// End:0x1C9
								if(__NFUN_130__(hostage.IsNeutral(aPawn), aPawn.IsAlive()))
								{
									bCheckDistance = true;
								}
							}
						}
					}
				}
			}
		}
		// End:0x28D
		if(bCheckDistance)
		{
			// End:0x28D
			if(__NFUN_132__(__NFUN_154__(m_aThreatDefinition[i].m_iCaringDistance, 2147483647), __NFUN_178__(__NFUN_225__(__NFUN_216__(hostage.Location, threat.Location)), float(m_aThreatDefinition[i].m_iCaringDistance))))
			{
				// End:0x282
				if(__NFUN_255__(m_aThreatDefinition[i].m_considerThreat, 'None'))
				{
					// End:0x27F
					if(hostage.m_controller.CanConsiderThreat(aPawn, threat, m_aThreatDefinition[i].m_considerThreat))
					{
						bRealThreat = true;
						// [Explicit Break]
						goto J0x297;
					}
					// [Explicit Continue]
					goto J0x28D;
				}
				bRealThreat = true;
				// [Explicit Break]
				goto J0x297;
			}
		}
		J0x28D:

		__NFUN_163__(i);
		// [Loop Continue]
		goto J0x4B;
	}
	J0x297:

	// End:0x360
	if(bRealThreat)
	{
		oThreatInfo.m_id = i;
		oThreatInfo.m_bornTime = int(Level.TimeSeconds);
		oThreatInfo.m_originalLocation = threat.Location;
		oThreatInfo.m_iThreatLevel = m_aThreatDefinition[i].m_iThreatLevel;
		// End:0x34D
		if(__NFUN_155__(int(eType), int(0)))
		{
			oThreatInfo.m_pawn = aPawn;
			// End:0x34A
			if(__NFUN_154__(int(m_aThreatDefinition[i].m_eNoiseType), int(3)))
			{
				oThreatInfo.m_actorExt = threat;
			}			
		}
		else
		{
			oThreatInfo.m_pawn = aPawn;
		}		
	}
	else
	{
		oThreatInfo.m_id = 0;
	}
	return bRealThreat;
	return;
}

//------------------------------------------------------------------
// GetThreatInfoFromThreatSurrender
//	
//------------------------------------------------------------------
function GetThreatInfoFromThreatSurrender(Pawn threat, out ThreatInfo oThreatInfo)
{
	oThreatInfo.m_id = -1;
	oThreatInfo.m_bornTime = int(Level.TimeSeconds);
	oThreatInfo.m_originalLocation = threat.Location;
	oThreatInfo.m_iThreatLevel = c_ThreatLevel_Surrender;
	oThreatInfo.m_pawn = threat;
	oThreatInfo.m_actorExt = none;
	oThreatInfo.m_state = 'None';
	return;
}

//------------------------------------------------------------------
// InsertReaction
//	
//------------------------------------------------------------------
function InsertReaction(name GroupName, int iLevel, int iRoll, name stateName)
{
	assert(__NFUN_150__(m_iReactionIndex, 24));
	m_aReactions[m_iReactionIndex].m_groupName = GroupName;
	m_aReactions[m_iReactionIndex].m_iThreatLevel = iLevel;
	m_aReactions[m_iReactionIndex].m_iChance = iRoll;
	m_aReactions[m_iReactionIndex].m_gotoState = stateName;
	__NFUN_165__(m_iReactionIndex);
	return;
}

//------------------------------------------------------------------
// InitThreatDefinition: insert all the threat definition in an array
//	
//------------------------------------------------------------------
function InitThreatDefinition()
{
	local string szName;
	local R6HostageMgr.EThreatType EThreatType;
	local name GroupName;
	local int i, iNoiseType, iCaringDistance, iThreatLevel;

	InsertThreatDefinition(c_ThreatGroup_Civ, "no threat", 0, 0, 0, 0);
	InsertThreatDefinition(c_ThreatGroup_Civ, "2m of enemy", 4, 0, 6, c_iSurrenderRadius);
	InsertThreatDefinition(c_ThreatGroup_Civ, "surrender", 3, 0, c_ThreatLevel_Surrender, 0);
	InsertThreatDefinition(c_ThreatGroup_Civ, "near grenade", 5, 3, 4, c_iDetectGrenadeRadius);
	InsertThreatDefinition(c_ThreatGroup_Civ, "under fire", 5, 2, 4, c_iDetectUnderFireRadius);
	InsertThreatDefinition(c_ThreatGroup_Civ, "see enemy", 4, 0, 3, 2147483647);
	InsertThreatDefinition(c_ThreatGroup_Civ, "see friend", 1, 0, 2, 2147483647);
	InsertThreatDefinition(c_ThreatGroup_Civ, "hear sound", 2, 2, 1, 2147483647);
	InsertThreatDefinition(c_ThreatGroup_Civ, "hear sound", 2, 3, 1, 2147483647);
	InsertThreatDefinition(c_ThreatGroup_Civ, "hear sound", 5, 1, 4, 2147483647);
	InsertThreatDefinition(c_ThreatGroup_HstEscorted, "hear sound", 2, 2, 1, 2147483647, 'IsEnemySound');
	InsertThreatDefinition(c_ThreatGroup_HstEscorted, "hear sound", 2, 3, 1, 2147483647, 'IsEnemySound');
	InsertThreatDefinition(c_ThreatGroup_HstEscorted, "hear sound", 2, 4, 1, 2147483647, 'IsEnemySound');
	InsertThreatDefinition(c_ThreatGroup_HstFreed, "near grenade", 5, 3, 4, c_iDetectGrenadeRadius);
	InsertThreatDefinition(c_ThreatGroup_HstFreed, "see enemy", 4, 0, 3, 2147483647);
	InsertThreatDefinition(c_ThreatGroup_HstFreed, "see friend", 1, 0, 2, 2147483647, 'CanSeeFriend');
	InsertThreatDefinition(c_ThreatGroup_HstFreed, "hear sound", 2, 2, 1, 2147483647);
	InsertThreatDefinition(c_ThreatGroup_HstFreed, "hear sound", 2, 3, 1, 2147483647);
	InsertThreatDefinition(c_ThreatGroup_HstFreed, "hear sound", 2, 4, 1, 2147483647);
	InsertThreatDefinition(c_ThreatGroup_HstGuarded, "near grenade", 5, 3, 3, c_iDetectGrenadeRadius);
	InsertThreatDefinition(c_ThreatGroup_HstGuarded, "see friend", 1, 0, 2, 2147483647, 'CanSeeFriend');
	InsertThreatDefinition(c_ThreatGroup_HstGuarded, "hear sound", 2, 4, 1, 2147483647);
	InsertThreatDefinition(c_ThreatGroup_HstGuarded, "hear sound", 2, 2, 1, 2147483647);
	InsertThreatDefinition(c_ThreatGroup_HstBait, "near grenade", 5, 3, 2, c_iDetectGrenadeRadius);
	InsertThreatDefinition(c_ThreatGroup_HstBait, "see friend", 1, 0, 1, 2147483647);
	InsertThreatDefinition(c_ThreatGroup_HstBait, "hear sound", 2, 2, 1, 2147483647);
	InsertThreatDefinition(c_ThreatGroup_HstBait, "hear sound", 2, 4, 1, 2147483647);
	assert(__NFUN_154__(m_aThreatDefinition[0].m_iThreatLevel, 0));
	assert(__NFUN_154__(m_iThreatDefinitionIndex, 27));
	return;
}

//------------------------------------------------------------------
// InitReaction
//	
//------------------------------------------------------------------
function InitReaction()
{
	local R6Hostage hostageDbg;
	local R6HostageAI hostageAIDbg;
	local int i;

	InsertReaction(c_ThreatGroup_Civ, 1, 33, 'CivRunForCover');
	InsertReaction(c_ThreatGroup_Civ, 1, 66, 'GoCivScareToDeath');
	InsertReaction(c_ThreatGroup_Civ, 1, 100, m_noReactionName);
	InsertReaction(c_ThreatGroup_Civ, 2, 25, 'CivRunForCover');
	InsertReaction(c_ThreatGroup_Civ, 2, 50, 'GoCivScareToDeath');
	InsertReaction(c_ThreatGroup_Civ, 2, 100, 'CivRunTowardRainbow');
	InsertReaction(c_ThreatGroup_Civ, 3, 50, 'GoCivScareToDeath');
	InsertReaction(c_ThreatGroup_Civ, 3, 100, 'CivRunForCover');
	InsertReaction(c_ThreatGroup_Civ, 4, 100, 'CivRunForCover');
	InsertReaction(c_ThreatGroup_Civ, c_ThreatLevel_Surrender, 50, 'CivSurrender');
	InsertReaction(c_ThreatGroup_Civ, c_ThreatLevel_Surrender, 100, 'CivRunForCover');
	InsertReaction(c_ThreatGroup_Civ, 6, 100, 'CivSurrender');
	InsertReaction(c_ThreatGroup_HstGuarded, 1, 100, 'GuardedPlayReaction');
	InsertReaction(c_ThreatGroup_HstGuarded, 2, 40, 'GoGuarded_Foetus');
	InsertReaction(c_ThreatGroup_HstGuarded, 2, 60, 'GoGuarded_frozen');
	InsertReaction(c_ThreatGroup_HstGuarded, 2, 100, 'GoHstRunTowardRainbow');
	InsertReaction(c_ThreatGroup_HstGuarded, 3, 100, 'GoHstRunForCover');
	InsertReaction(c_ThreatGroup_HstEscorted, 1, 100, 'HearShootingReaction');
	InsertReaction(c_ThreatGroup_HstFreed, 1, 100, 'GoHstRunForCover');
	InsertReaction(c_ThreatGroup_HstFreed, 2, 100, 'GoHstRunTowardRainbow');
	InsertReaction(c_ThreatGroup_HstFreed, 3, 100, 'GoHstFreedButSeeEnemy');
	InsertReaction(c_ThreatGroup_HstFreed, 4, 100, 'GoHstRunForCover');
	InsertReaction(c_ThreatGroup_HstBait, 1, 100, 'BaitPlayReaction');
	InsertReaction(c_ThreatGroup_HstBait, 2, 100, 'GoHstRunForCover');
	assert(__NFUN_154__(m_iReactionIndex, 24));
	return;
}

// NEW IN 1.60
function InitReactionForClassicMissionCivilian()
{
	local R6Hostage hostageDbg;
	local R6HostageAI hostageAIDbg;
	local int i;

	InsertReaction(c_ThreatGroup_Civ, 1, 33, 'm_noReactionName');
	InsertReaction(c_ThreatGroup_Civ, 1, 66, 'm_noReactionName');
	InsertReaction(c_ThreatGroup_Civ, 1, 100, m_noReactionName);
	InsertReaction(c_ThreatGroup_Civ, 2, 25, 'm_noReactionName');
	InsertReaction(c_ThreatGroup_Civ, 2, 50, 'm_noReactionName');
	InsertReaction(c_ThreatGroup_Civ, 2, 100, 'm_noReactionName');
	InsertReaction(c_ThreatGroup_Civ, 3, 50, 'm_noReactionName');
	InsertReaction(c_ThreatGroup_Civ, 3, 100, 'm_noReactionName');
	InsertReaction(c_ThreatGroup_Civ, 4, 100, 'CivRunForCover');
	InsertReaction(c_ThreatGroup_Civ, c_ThreatLevel_Surrender, 50, 'm_noReactionName');
	InsertReaction(c_ThreatGroup_Civ, c_ThreatLevel_Surrender, 100, 'm_noReactionName');
	InsertReaction(c_ThreatGroup_Civ, 6, 100, 'm_noReactionName');
	InsertReaction(c_ThreatGroup_HstGuarded, 1, 100, 'GuardedPlayReaction');
	InsertReaction(c_ThreatGroup_HstGuarded, 2, 40, 'GoGuarded_Foetus');
	InsertReaction(c_ThreatGroup_HstGuarded, 2, 60, 'GoGuarded_frozen');
	InsertReaction(c_ThreatGroup_HstGuarded, 2, 100, 'GoHstRunTowardRainbow');
	InsertReaction(c_ThreatGroup_HstGuarded, 3, 100, 'GoHstRunForCover');
	InsertReaction(c_ThreatGroup_HstEscorted, 1, 100, 'HearShootingReaction');
	InsertReaction(c_ThreatGroup_HstFreed, 1, 100, 'GoHstRunForCover');
	InsertReaction(c_ThreatGroup_HstFreed, 2, 100, 'GoHstRunTowardRainbow');
	InsertReaction(c_ThreatGroup_HstFreed, 3, 100, 'GoHstFreedButSeeEnemy');
	InsertReaction(c_ThreatGroup_HstFreed, 4, 100, 'GoHstRunForCover');
	InsertReaction(c_ThreatGroup_HstBait, 1, 100, 'BaitPlayReaction');
	InsertReaction(c_ThreatGroup_HstBait, 2, 100, 'GoHstRunForCover');
	assert(__NFUN_154__(m_iReactionIndex, 24));
	return;
}

//------------------------------------------------------------------
// GetReaction: return the state to go
//	if '' is return, do nothing
//------------------------------------------------------------------
function name GetReaction(name GroupName, int iLevel, int iRoll)
{
	local int i;
	local bool bFound;
	local name stateName;

	bFound = false;
	i = 0;
	J0x0F:

	// End:0x9E [Loop If]
	if(__NFUN_150__(i, 24))
	{
		// End:0x94
		if(__NFUN_254__(m_aReactions[i].m_groupName, GroupName))
		{
			// End:0x77
			if(__NFUN_154__(m_aReactions[i].m_iThreatLevel, iLevel))
			{
				// End:0x74
				if(__NFUN_152__(iRoll, m_aReactions[i].m_iChance))
				{
					bFound = true;
					// [Explicit Break]
					goto J0x9E;
				}
				// [Explicit Continue]
				goto J0x94;
			}
			// End:0x94
			if(__NFUN_151__(m_aReactions[i].m_iThreatLevel, iLevel))
			{
				// [Explicit Break]
				goto J0x9E;
			}
		}
		J0x94:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x0F;
	}
	J0x9E:

	// End:0xC0
	if(bFound)
	{
		stateName = m_aReactions[i].m_gotoState;		
	}
	else
	{
		stateName = m_noReactionName;
	}
	return stateName;
	return;
}

//------------------------------------------------------------------
// ValidMgr: valid some data of manager. can be called only once
//	
//------------------------------------------------------------------
function ValidMgr(R6HostageAI AI)
{
	return;
}

function Pawn.EHostageVoices GetHostageVoices(int Index)
{
	return m_aHstSndEventInfo[Index].m_eVoice;
	return;
}

//------------------------------------------------------------------
// GetHostageSndEvent: depending of the snd event and the perso.
// Exception when hostage sees Rainbow but is also close to Terrorist,
// the personnality is not used
//------------------------------------------------------------------
function int GetHostageSndEvent(int iSndEvent, R6Hostage H)
{
	local R6Pawn.EHostagePersonality ePerso;
	local int i;
	local bool bFound;

	ePerso = H.m_ePersonality;
	// End:0x2C
	if(__NFUN_154__(int(ePerso), int(3)))
	{
		ePerso = 0;
	}
	i = 0;
	J0x33:

	// End:0x6E [Loop If]
	if(__NFUN_150__(i, 24))
	{
		// End:0x64
		if(__NFUN_154__(m_aHstSndEventInfo[i].m_iHstSndEvent, iSndEvent))
		{
			bFound = true;
			// [Explicit Break]
			goto J0x6E;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x33;
	}
	J0x6E:

	// End:0x7B
	if(__NFUN_129__(bFound))
	{
		return 0;
	}
	return i;
	return;
}

//------------------------------------------------------------------
// InsertSndEventInfo
//	
//------------------------------------------------------------------
function InsertSndEventInfo(int Index, int iSndEvent, R6Pawn.EHostagePersonality ePerso, Pawn.EHostageVoices eVoice)
{
	local name A;

	m_aHstSndEventInfo[Index].m_iHstSndEvent = iSndEvent;
	m_aHstSndEventInfo[Index].m_ePerso = ePerso;
	m_aHstSndEventInfo[Index].m_eVoice = eVoice;
	return;
}

//------------------------------------------------------------------
// InitSndEventInfo
//	
//------------------------------------------------------------------
function InitSndEventInfo()
{
	local int Index;

	InsertSndEventInfo(__NFUN_165__(Index), 1, 4, 3);
	InsertSndEventInfo(__NFUN_165__(Index), 6, 4, 1);
	InsertSndEventInfo(__NFUN_165__(Index), 5, 4, 0);
	InsertSndEventInfo(__NFUN_165__(Index), 7, 4, 2);
	InsertSndEventInfo(__NFUN_165__(Index), 8, 4, 4);
	InsertSndEventInfo(__NFUN_165__(Index), 9, 4, 5);
	InsertSndEventInfo(__NFUN_165__(Index), 10, 2, 6);
	return;
}

defaultproperties
{
	c_iSurrenderRadius=200
	c_iDetectUnderFireRadius=500
	c_iDetectThreatSound=1000
	c_iDetectGrenadeRadius=1000
	c_ThreatLevel_Surrender=5
	c_ThreatGroup_Civ="Civ"
	c_ThreatGroup_HstFreed="Freed"
	c_ThreatGroup_HstGuarded="Guarded"
	c_ThreatGroup_HstBait="Bait"
	c_ThreatGroup_HstEscorted="Escorted"
	RemoteRole=0
	bHidden=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_aThreatDefinition26
