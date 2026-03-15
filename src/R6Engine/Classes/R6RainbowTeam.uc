//=============================================================================
// R6RainbowTeam - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6RainbowTeam.uc : The R6RainbowTeam class is where the AI for the Rainbow
//					   team will be implemented.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//=============================================================================
class R6RainbowTeam extends Actor
    native
    notplaceable;

const c_iMaxTeam = 4;

enum ePlayerRoomEntry
{
	PRE_Center,                     // 0
	PRE_Left,                       // 1
	PRE_Right                       // 2
};

enum eTeamState
{
	TS_None,                        // 0
	TS_Waiting,                     // 1
	TS_Holding,                     // 2
	TS_Moving,                      // 3
	TS_Following,                   // 4
	TS_Regrouping,                  // 5
	TS_Engaging,                    // 6
	TS_Sniping,                     // 7
	TS_LockPicking,                 // 8
	TS_OpeningDoor,                 // 9
	TS_ClosingDoor,                 // 10
	TS_Opening,                     // 11
	TS_Closing,                     // 12
	TS_ClearingRoom,                // 13
	TS_Grenading,                   // 14
	TS_DisarmingBomb,               // 15
	TS_InteractWithDevice,          // 16
	TS_SecuringTerrorist,           // 17
	TS_ClimbingLadder,              // 18
	TS_WaitingForOrders,            // 19
	TS_SettingBreach,               // 20
	TS_Retired                      // 21
};

// each bit is used by the client for the RoseDesVents. 
// and is examined to see if we have a team member with
// a specific grenade type, this is more effecient than 
// replicate all the info for all weapons
var byte m_bHasGrenade;
var R6RainbowAI.eFormation m_eFormation;  // team formation
var R6RainbowAI.eFormation m_eRequestedFormation;
// NEW IN 1.60
var R6RainbowTeam.ePlayerRoomEntry m_ePlayerRoomEntry;
var R6EngineWeapon.eWeaponGrenadeType m_eEntryGrenadeType;
// Rules Of Engagement determines speed and hostility of unit
var Object.EMovementMode m_eMovementMode;  // Rules Of Engagement
var Object.EMovementSpeed m_eMovementSpeed;
var Object.EPlanAction m_ePlanAction;
var Object.EPlanAction m_eNextAPAction;
var Object.EPlanAction m_ePlayerAPAction;
// NEW IN 1.60
var R6RainbowTeam.eTeamState m_eTeamState;
// NEW IN 1.60
var R6RainbowTeam.eTeamState m_eBackupTeamState;
// GOCODE_Alpha, GOCODE_Bravo, GOCODE_Charlie, GOCODE_Delta, GOCODE_None
var Object.EGoCode m_eGoCode;
var Object.EGoCode m_eBackupGoCode;
var int m_iMemberCount;
var int m_iIDVoicesMgr;
var int m_iFormationDistance;  // standard distance between members when in a movement formation
var int m_iDiagonalDistance;
// NEW IN 1.60
var int m_iTeamHealth[4];
var int m_iMembersLost;
var int m_iGrenadeThrower;  // index of the last member who throwed a grenade
var int m_iIntermLeader;  // used for temporary reorganisation of team; to keep track of who original lead was
var int m_iSpawnDistance;  // distance used to spawn characters next to the start point
var int m_iSpawnDiagDist;  // distance used to spawn characters diagonaly to the start point
var int m_iSpawnDiagOther;  // distance used to spawn characters around the start point(not diagonaly or next to)
// door control, room entry
//var         INT                     m_iAction;                          // contains the desired action to take... (door: OPEN/CLOSE)
var int m_iSubAction;  // contains the desired sub action to take...
var int m_iRainbowTeamName;
var int m_iTeamAction;
// status flags
var bool m_bLeaderIsAPlayer;  // the leader of this team is not an NPC (is a player)
var bool m_bPlayerHasFocus;  // When the player is in observer mode on the current team
var bool m_bPlayerInGhostMode;
var bool m_bTeamIsClimbingLadder;  // team is in the process of climbing a ladder
var bool m_bTeamIsSeparatedFromLeader;  // team was either told to hold position or to perform an action (e.g. climb ladder)
var bool m_bGrenadeInProximity;  // frag grenade
var bool m_bGasGrenadeInProximity;  // tear gas grenade
// doors & room entry
var bool m_bEntryInProgress;  // a room entry is in progress
var bool m_bDoorOpensTowardTeam;
var bool m_bDoorOpensClockWise;
var bool m_bRainbowIsInFrontOfDoor;
var bool m_bWoundedHostage;  // true if an escorted hostage is wounded
var bool m_bCAWaitingForZuluGoCode;
// Prevent using team for training
var bool m_bPreventUsingTeam;
var bool m_bSniperReady;
var bool m_bSkipAction;
var bool m_bWasSeparatedFromLeader;
var bool m_bAllTeamsHold;
var bool m_bTeamIsHoldingPosition;
var bool m_bSniperHold;
var bool m_bTeamIsRegrouping;
var bool m_bPlayerRequestedTeamReform;
var bool m_bPendingSnipeUntilGoCode;
var bool m_bTeamIsEngagingEnemy;
//#ifdefDEBUG	
var bool bShowLog;
var bool bPlanningLog;
var bool m_bFirstTimeInGas;
var float m_fEngagingTimer;
// NEW IN 1.60
var R6Rainbow m_Team[4];
var R6GameColors Colors;
var R6RainbowPlayerVoices m_PlayerVoicesMgr;
var R6RainbowMemberVoices m_MemberVoicesMgr;
var R6RainbowOtherTeamVoices m_OtherTeamVoicesMgr;
var R6MultiCommonVoices m_MultiCommonVoicesMgr;
var R6MultiCoopVoices m_MultiCoopPlayerVoicesMgr;
var R6MultiCoopVoices m_MultiCoopMemberVoicesMgr;
var R6PreRecordedMsgVoices m_PreRecMsgVoicesMgr;
var R6Rainbow m_TeamLeader;
var R6AbstractPlanningInfo m_TeamPlanning;
var R6Pawn m_PawnControllingDoor;
// ladder climbing
var R6Ladder m_TeamLadder;
var R6Door m_Door;  // reference to a door actor involved in a room entry
var R6CircumstantialActionQuery m_actionRequested;
var Actor m_PlanActionPoint;
var R6IORotatingDoor m_BreachingDoor;
var Actor m_LastActionPoint;
var R6Pawn m_SurrenderedTerrorist;
var R6Pawn m_HostageToRescue;
var Actor m_PlayerLastActionPoint;
var array<R6InteractiveObject> m_InteractiveObjectList;
var Color m_TeamColour;
// team info to maintain for members
var Rotator m_rTeamDirection;  // rotator that maintains the direction of movement of the team leader
var Vector m_vActionLocation;
var Vector m_vPlanActionLocation;
var Rotator m_rSnipingDir;
var Vector m_vPreviousPosition;
var Vector m_vNoiseSource;

replication
{
	// Pos:0x000
	reliable if((int(Role) == int(ROLE_Authority)))
		m_Team, m_TeamColour, 
		m_bHasGrenade, m_eGoCode, 
		m_eTeamState, m_iMemberCount, 
		m_iMembersLost;

	// Pos:0x00D
	reliable if((int(Role) == int(ROLE_Authority)))
		m_bTeamIsClimbingLadder;

	// Pos:0x01A
	reliable if((int(Role) == int(ROLE_Authority)))
		ClientUpdateFirstPersonWpnAndPeeking;

	// Pos:0x027
	reliable if((int(Role) < int(ROLE_Authority)))
		TeamActionRequest, TeamActionRequestFromRoseDesVents, 
		TeamActionRequestWaitForZuluGoCode;
}

function SetTeamState(R6RainbowTeam.eTeamState eNewState)
{
	// End:0x3B
	if(((m_bLeaderIsAPlayer && (m_iMemberCount == 1)) || ((!m_bLeaderIsAPlayer) && (m_iMemberCount == 0))))
	{
		m_eTeamState = 21;		
	}
	else
	{
		// End:0x59
		if((int(m_eTeamState) != int(6)))
		{
			m_eTeamState = eNewState;			
		}
		else
		{
			m_eBackupTeamState = eNewState;
		}
	}
	return;
}

function TeamIsSeparatedFromLead(bool bSeparated)
{
	// End:0x0D
	if((m_iMemberCount <= 1))
	{
		return;
	}
	m_bTeamIsSeparatedFromLeader = bSeparated;
	return;
}

function TeamIsRegroupingOnLead(bool bIsRegrouping)
{
	local bool bPreviousTeamIsRegrouping;

	bPreviousTeamIsRegrouping = m_bTeamIsRegrouping;
	// End:0x59
	if((((m_bLeaderIsAPlayer && m_bPlayerRequestedTeamReform) && m_bTeamIsRegrouping) && (!bIsRegrouping)))
	{
		m_bPlayerRequestedTeamReform = false;
		m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 5);
	}
	m_bTeamIsRegrouping = bIsRegrouping;
	TeamIsSeparatedFromLead(bIsRegrouping);
	// End:0x83
	if(bIsRegrouping)
	{
		SetTeamState(5);
	}
	// End:0x9F
	if(((!bIsRegrouping) && bPreviousTeamIsRegrouping))
	{
		Escort_ManageList();
	}
	return;
}

simulated event Destroyed()
{
	// End:0x1E
	if((m_actionRequested != none))
	{
		m_actionRequested.Destroy();
		m_actionRequested = none;
	}
	super.Destroyed();
	return;
}

event PostBeginPlay()
{
	local R6InteractiveObject IntObject;

	super.PostBeginPlay();
	// End:0x3B
	foreach AllActors(Class'R6Engine.R6InteractiveObject', IntObject)
	{
		// End:0x3A
		if(IntObject.m_bRainbowCanInteract)
		{
			m_InteractiveObjectList[m_InteractiveObjectList.Length] = IntObject;
		}		
	}	
	m_actionRequested = Spawn(Class'R6Engine.R6CircumstantialActionQuery');
	return;
}

//------------------------------------------------------------------
// PostNetBeginPlay
//	create Colors on the server and on the Client
//------------------------------------------------------------------
simulated event PostNetBeginPlay()
{
	Colors = new (none) Class'Engine.R6GameColors';
	return;
}

//------------------------------------------------------------------
// CreateMPPlayerTeam
//  used in multiplayer
//	create the team member base on the player controller
//------------------------------------------------------------------
function CreateMPPlayerTeam(PlayerController MyPlayer, R6RainbowStartInfo Info, int iMemberCount, PlayerStart Start)
{
	local int i, iMembersToSpawn;

	// End:0x0D
	if((m_iMemberCount > 0))
	{
		return;
	}
	m_bLeaderIsAPlayer = true;
	m_Team[0] = R6Rainbow(MyPlayer.Pawn);
	m_TeamLeader = m_Team[0];
	m_iTeamHealth[0] = 0;
	m_iMemberCount = 1;
	m_Team[0].m_FaceTexture = Info.m_FaceTexture;
	m_Team[0].m_FaceCoords = Info.m_FaceCoords;
	i = 1;
	J0x92:

	// End:0xC9 [Loop If]
	if((i < iMemberCount))
	{
		CreateTeamMember(Info, Start, false);
		m_iTeamHealth[i] = 0;
		(i++);
		// [Loop Continue]
		goto J0x92;
	}
	UpdateTeamGrenadeStatus();
	Info.Destroy();
	return;
}

function SetMultiVoicesMgr(R6AbstractGameInfo aGameInfo, int iTeamNumber, int iMemberCount)
{
	local bool bCoopGameType;

	m_MultiCommonVoicesMgr = none;
	m_MultiCoopPlayerVoicesMgr = none;
	m_MultiCoopMemberVoicesMgr = none;
	m_PreRecMsgVoicesMgr = none;
	bCoopGameType = Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag);
	// End:0xB1
	if((bCoopGameType || Level.IsGameTypeTeamAdversarial(Level.Game.m_szGameTypeFlag)))
	{
		m_MultiCommonVoicesMgr = R6MultiCommonVoices(aGameInfo.GetMultiCommonVoicesMgr());
		m_PreRecMsgVoicesMgr = R6PreRecordedMsgVoices(aGameInfo.GetPreRecordedMsgVoicesMgr());
	}
	// End:0xF2
	if((bCoopGameType || Level.IsGameTypePlayWithNonRainbowNPCs(Level.Game.m_szGameTypeFlag)))
	{
		SetVoicesMgr(aGameInfo, true, true);
	}
	// End:0x16A
	if(bCoopGameType)
	{
		m_MultiCoopPlayerVoicesMgr = R6MultiCoopVoices(aGameInfo.GetMultiCoopPlayerVoicesMgr((Level.Game.CurrentID - Level.Game.default.CurrentID)));
		// End:0x16A
		if((iMemberCount > 1))
		{
			m_MultiCoopMemberVoicesMgr = R6MultiCoopVoices(aGameInfo.GetMultiCoopMemberVoicesMgr());
		}
	}
	return;
}

//------------------------------------------------------------------//
// SetVoicesMgr()												    //
//------------------------------------------------------------------//
function SetVoicesMgr(R6AbstractGameInfo aGameInfo, bool bPlayerTeamStart, bool bPlayerInTeam, optional int iIDVoicesMgr, optional bool bInGhostMode)
{
	m_PlayerVoicesMgr = none;
	m_MemberVoicesMgr = none;
	m_OtherTeamVoicesMgr = none;
	m_bPlayerInGhostMode = bInGhostMode;
	// End:0x43
	if(((!bPlayerTeamStart) && bPlayerInTeam))
	{
		m_bPlayerHasFocus = true;		
	}
	else
	{
		m_bPlayerHasFocus = false;
	}
	m_PlayerVoicesMgr = R6RainbowPlayerVoices(aGameInfo.GetRainbowPlayerVoicesMgr());
	// End:0x96
	if(bPlayerTeamStart)
	{
		// End:0x93
		if((m_iMemberCount > 1))
		{
			m_MemberVoicesMgr = R6RainbowMemberVoices(aGameInfo.GetRainbowMemberVoicesMgr());
		}		
	}
	else
	{
		// End:0xE3
		if((m_bPlayerHasFocus && (!m_bPlayerInGhostMode)))
		{
			m_MemberVoicesMgr = R6RainbowMemberVoices(aGameInfo.GetRainbowMemberVoicesMgr());
			m_MultiCoopMemberVoicesMgr = R6MultiCoopVoices(aGameInfo.GetMultiCoopMemberVoicesMgr());			
		}
		else
		{
			// End:0x10C
			if((m_iMemberCount > 1))
			{
				aGameInfo.GetRainbowMemberVoicesMgr();
				aGameInfo.GetCommonRainbowMemberVoicesMgr();
			}
			m_iIDVoicesMgr = iIDVoicesMgr;
			m_OtherTeamVoicesMgr = R6RainbowOtherTeamVoices(aGameInfo.GetRainbowOtherTeamVoicesMgr(iIDVoicesMgr));
		}
	}
	return;
}

//------------------------------------------------------------------//
// CreatePlayerTeam()												//
//------------------------------------------------------------------//
function CreatePlayerTeam(R6TeamStartInfo TeamInfo, NavigationPoint StartingPoint, PlayerController aRainbowPC)
{
	local int i;

	// End:0x0D
	if((m_iMemberCount > 0))
	{
		return;
	}
	m_bLeaderIsAPlayer = true;
	m_iMemberCount = 0;
	i = 0;
	J0x23:

	// End:0x9F [Loop If]
	if((i < TeamInfo.m_iNumberOfMembers))
	{
		CreateTeamMember(TeamInfo.m_CharacterInTeam[i], StartingPoint, (m_iMemberCount == 0), R6PlayerController(aRainbowPC));
		m_iTeamHealth[i] = TeamInfo.m_CharacterInTeam[i].m_iHealth;
		(i++);
		// [Loop Continue]
		goto J0x23;
	}
	UpdateTeamGrenadeStatus();
	return;
}

//------------------------------------------------------------------//
// CreateAITeam()													//
//------------------------------------------------------------------//
function CreateAITeam(R6TeamStartInfo TeamInfo, NavigationPoint StartingPoint)
{
	local int i;

	// End:0x0D
	if((m_iMemberCount > 0))
	{
		return;
	}
	m_bLeaderIsAPlayer = false;
	m_TeamLeader = none;
	m_iMemberCount = 0;
	i = 0;
	J0x2A:

	// End:0x95 [Loop If]
	if((i < TeamInfo.m_iNumberOfMembers))
	{
		CreateTeamMember(TeamInfo.m_CharacterInTeam[i], StartingPoint, false);
		m_iTeamHealth[i] = TeamInfo.m_CharacterInTeam[i].m_iHealth;
		(i++);
		// [Loop Continue]
		goto J0x2A;
	}
	UpdateTeamGrenadeStatus();
	return;
}

//------------------------------------------------------------------//
// CreateTeamMember()												//
//------------------------------------------------------------------//
function CreateTeamMember(R6RainbowStartInfo RainbowToCreate, NavigationPoint StartingPoint, optional bool bPlayer, optional R6PlayerController RainbowPC)
{
	local R6RainbowAI rainbowAI;
	local Vector vOriginStart, vStart;
	local Class<R6Rainbow> rainbowPawnClass, armorClass;
	local R6Rainbow Rainbow;
	local int iSpawnTry;
	local Rotator rPosOrientation, rStartingPointRot;

	// End:0x1B
	if((int(Level.NetMode) == int(NM_Client)))
	{
		return;
	}
	// End:0x8C
	if(((int(Level.NetMode) == int(NM_Standalone)) && (m_TeamPlanning.m_NodeList.Length != 0)))
	{
		vOriginStart = m_TeamPlanning.m_NodeList[0].Location;
		rStartingPointRot = m_TeamPlanning.m_NodeList[0].Rotation;		
	}
	else
	{
		vOriginStart = StartingPoint.Location;
		rStartingPointRot = StartingPoint.Rotation;
	}
	rStartingPointRot.Roll = 0;
	iSpawnTry = 0;
	J0xC7:

	// End:0x7B9 [Loop If]
	if((iSpawnTry != -1))
	{
		// End:0xEF
		if((iSpawnTry == 0))
		{
			vStart = vOriginStart;			
		}
		else
		{
			// End:0x19D
			if((iSpawnTry < 8))
			{
				rPosOrientation = rStartingPointRot;
				(rPosOrientation.Yaw += (32768 + (8192 * (iSpawnTry + 1))));
				// End:0x17D
				if(((((iSpawnTry == 1) || (iSpawnTry == 3)) || (iSpawnTry == 5)) || (iSpawnTry == 7)))
				{
					vStart = (vOriginStart - (float(m_iSpawnDistance) * Vector(rPosOrientation)));					
				}
				else
				{
					vStart = (vOriginStart - (float(m_iSpawnDiagDist) * Vector(rPosOrientation)));
				}				
			}
			else
			{
				// End:0x2B2
				if((iSpawnTry < 24))
				{
					rPosOrientation = rStartingPointRot;
					(rPosOrientation.Yaw += ((32768 + 16384) + (4096 * (iSpawnTry - 9))));
					// End:0x238
					if(((((iSpawnTry == 9) || (iSpawnTry == 13)) || (iSpawnTry == 17)) || (iSpawnTry == 21)))
					{
						vStart = (vOriginStart - (float((m_iSpawnDistance * 2)) * Vector(rPosOrientation)));						
					}
					else
					{
						// End:0x292
						if(((((iSpawnTry == 11) || (iSpawnTry == 15)) || (iSpawnTry == 19)) || (iSpawnTry == 23)))
						{
							vStart = (vOriginStart - (float((m_iSpawnDiagDist * 2)) * Vector(rPosOrientation)));							
						}
						else
						{
							vStart = (vOriginStart - (float(m_iSpawnDiagOther) * Vector(rPosOrientation)));
						}
					}					
				}
				else
				{
					Log("    Rainbow6    <R6GameInfo::CreateTeamMember> attempt to create a rainbow member failed!!");
					return;
				}
			}
		}
		// End:0x4A5
		if((iSpawnTry == 0))
		{
			// End:0x32A
			if(__NFUN_114__(RainbowToCreate, none))
			{
				return;
			}
			// End:0x341
			if(__NFUN_122__(RainbowToCreate.m_ArmorName, ""))
			{
				return;
			}
			armorClass = Class<R6Rainbow>(DynamicLoadObject(RainbowToCreate.m_ArmorName, Class'Core.Class'));
			// End:0x436
			if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
			{
				Level.GreenTeamSkin = armorClass.default.Skins[0];
				Level.GreenHeadSkin = armorClass.default.Skins[1];
				Level.GreenGogglesSkin = armorClass.default.Skins[2];
				Level.GreenHandSkin = armorClass.default.Skins[5];
				Level.GreenMesh = armorClass.default.Mesh;
				Level.GreenHelmet = armorClass.default.m_HelmetClass;
			}
			rainbowPawnClass = Class<R6Rainbow>(Class'Engine.Actor'.static.__NFUN_1524__().GetDefaultRainbowPawn(int(armorClass.default.m_eArmorType)));
			rainbowPawnClass.default.m_iOperativeID = RainbowToCreate.m_iOperativeID;
			rainbowPawnClass.default.bIsFemale = __NFUN_129__(RainbowToCreate.m_bIsMale);
		}
		Rainbow = __NFUN_278__(rainbowPawnClass,,, vStart, rStartingPointRot, false);
		// End:0x4D5
		if(__NFUN_114__(Rainbow, none))
		{
			__NFUN_165__(iSpawnTry);			
		}
		else
		{
			Rainbow.m_szPrimaryWeapon = RainbowToCreate.m_WeaponName[0];
			Rainbow.m_szPrimaryGadget = RainbowToCreate.m_WeaponGadgetName[0];
			Rainbow.m_szPrimaryBulletType = RainbowToCreate.m_BulletType[0];
			Rainbow.m_szSecondaryWeapon = RainbowToCreate.m_WeaponName[1];
			Rainbow.m_szSecondaryGadget = RainbowToCreate.m_WeaponGadgetName[1];
			Rainbow.m_szSecondaryBulletType = RainbowToCreate.m_BulletType[1];
			Rainbow.m_szPrimaryItem = RainbowToCreate.m_GadgetName[0];
			Rainbow.m_szSecondaryItem = RainbowToCreate.m_GadgetName[1];
			Rainbow.m_szSpecialityID = RainbowToCreate.m_szSpecialityID;
			Rainbow.m_FaceTexture = RainbowToCreate.m_FaceTexture;
			Rainbow.m_FaceCoords = RainbowToCreate.m_FaceCoords;
			// End:0x725
			if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
			{
				Rainbow.m_fSkillAssault = RainbowToCreate.m_fSkillAssault;
				Rainbow.m_fSkillDemolitions = RainbowToCreate.m_fSkillDemolitions;
				Rainbow.m_fSkillElectronics = RainbowToCreate.m_fSkillElectronics;
				Rainbow.m_fSkillSniper = RainbowToCreate.m_fSkillSniper;
				Rainbow.m_fSkillStealth = RainbowToCreate.m_fSkillStealth;
				Rainbow.m_fSkillSelfControl = RainbowToCreate.m_fSkillSelfControl;
				Rainbow.m_fSkillLeadership = RainbowToCreate.m_fSkillLeadership;
				Rainbow.m_fSkillObservation = RainbowToCreate.m_fSkillObservation;
			}
			switch(RainbowToCreate.m_iHealth)
			{
				// End:0x74D
				case 0:
					Rainbow.m_eHealth = 0;
					// End:0x7AB
					break;
				// End:0x765
				case 1:
					Rainbow.m_eHealth = 1;
					// End:0x7AB
					break;
				// End:0x77E
				case 2:
					Rainbow.m_eHealth = 2;
					// End:0x7AB
					break;
				// End:0x797
				case 3:
					Rainbow.m_eHealth = 3;
					// End:0x7AB
					break;
				// End:0xFFFF
				default:
					Rainbow.m_eHealth = 0;
					break;
			}
			iSpawnTry = -1;
		}
		// [Loop Continue]
		goto J0xC7;
	}
	Rainbow.m_vStartLocation = vStart;
	Rainbow.m_CharacterName = RainbowToCreate.m_CharacterName;
	// End:0x8DF
	if(bPlayer)
	{
		// End:0x8DC
		if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
		{
			RainbowPC.__NFUN_267__(vStart);
			R6AbstractGameInfo(Level.Game).m_Player = RainbowPC;
			RainbowPC.m_CurrentVolumeSound = Rainbow.m_CurrentVolumeSound;
			RainbowPC.Possess(Rainbow);
			RainbowPC.GameReplicationInfo = Level.Game.GameReplicationInfo;
			Rainbow.Controller = RainbowPC;
			RainbowPC.Focus = none;
			RainbowPC.m_CurrentAmbianceObject = Rainbow.Region.Zone;
		}		
	}
	else
	{
		// End:0x934
		if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
		{
			rainbowAI = R6RainbowAI(__NFUN_278__(Class'Engine.Actor'.static.__NFUN_1524__().GetDefaultRainbowAI(),,, vStart, StartingPoint.Rotation));			
		}
		else
		{
			rainbowAI = R6RainbowAI(R6AbstractGameInfo(Level.Game).GetRainbowAIFromTable());
		}
		rainbowAI.Possess(Rainbow);
		Rainbow.Controller = rainbowAI;
		rainbowAI.Focus = none;
	}
	m_Team[m_iMemberCount] = Rainbow;
	// End:0xA03
	if(__NFUN_114__(m_TeamLeader, none))
	{
		m_TeamLeader = Rainbow;
		// End:0x9FA
		if(__NFUN_129__(bPlayer))
		{
			rainbowAI.m_TeamLeader = none;
			rainbowAI.NextState = 'Patrol';
			rainbowAI.__NFUN_113__('WaitForGameToStart');
		}
		GetFirstActionPoint();		
	}
	else
	{
		rainbowAI.m_TeamLeader = m_TeamLeader;
		rainbowAI.NextState = 'FollowLeader';
		rainbowAI.__NFUN_113__('WaitForGameToStart');
	}
	// End:0xA8A
	if(bPlayer)
	{
		// End:0xA87
		if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
		{
			RainbowPC.__NFUN_299__(StartingPoint.Rotation);
			RainbowPC.m_TeamManager = self;
		}		
	}
	else
	{
		rainbowAI.__NFUN_299__(StartingPoint.Rotation);
		rainbowAI.m_TeamManager = self;
	}
	Rainbow.m_iID = m_iMemberCount;
	Rainbow.m_iPermanentID = Rainbow.m_iID;
	__NFUN_165__(m_iMemberCount);
	Rainbow.GiveDefaultWeapon();
	return;
}

//------------------------------------------------------------------//
// rbrek - 11 may 2002												//
// ResetRainbowTeam()												//
//	 resets all variables and rainbow states						//
//------------------------------------------------------------------//
function ResetRainbowTeam()
{
	local int i;

	m_bTeamIsClimbingLadder = false;
	m_bEntryInProgress = false;
	m_bRainbowIsInFrontOfDoor = false;
	// End:0x25
	if(__NFUN_152__(m_iMemberCount, 1))
	{
		return;
	}
	i = 1;
	J0x2C:

	// End:0x64 [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		m_Team[i].Controller.__NFUN_113__('FollowLeader');
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x2C;
	}
	return;
}

//------------------------------------------------------------------//
// LastMemberIsStationary()											//
//------------------------------------------------------------------//
function bool LastMemberIsStationary()
{
	// End:0x1D
	if(m_Team[__NFUN_147__(m_iMemberCount, 1)].IsStationary())
	{
		return true;
	}
	return false;
	return;
}

//------------------------------------------------------------------//
// ResetGrenadeAction()											
//------------------------------------------------------------------//
function ResetGrenadeAction()
{
	m_iTeamAction = __NFUN_156__(m_iTeamAction, -65);
	return;
}

//------------------------------------------------------------------//
// UpdateTeamGrenadeStatus()										//
//------------------------------------------------------------------//
function UpdateTeamGrenadeStatus()
{
	m_bHasGrenade = 0;
	// End:0x21
	if(__NFUN_119__(FindRainbowWithGrenadeType(1, false), none))
	{
		__NFUN_135__(m_bHasGrenade, byte(1));
	}
	// End:0x3B
	if(__NFUN_119__(FindRainbowWithGrenadeType(2, false), none))
	{
		__NFUN_135__(m_bHasGrenade, byte(2));
	}
	// End:0x55
	if(__NFUN_119__(FindRainbowWithGrenadeType(3, false), none))
	{
		__NFUN_135__(m_bHasGrenade, byte(4));
	}
	// End:0x6F
	if(__NFUN_119__(FindRainbowWithGrenadeType(4, false), none))
	{
		__NFUN_135__(m_bHasGrenade, byte(8));
	}
	return;
}

//------------------------------------------------------------------//
// HaveRainbowWithGrenadeType()										//
//------------------------------------------------------------------//
simulated function bool HaveRainbowWithGrenadeType(R6EngineWeapon.eWeaponGrenadeType grenadeType)
{
	switch(grenadeType)
	{
		// End:0x1A
		case 1:
			return __NFUN_155__(__NFUN_156__(int(m_bHasGrenade), 1), 0);
		// End:0x2E
		case 2:
			return __NFUN_155__(__NFUN_156__(int(m_bHasGrenade), 2), 0);
		// End:0x42
		case 3:
			return __NFUN_155__(__NFUN_156__(int(m_bHasGrenade), 4), 0);
		// End:0x56
		case 4:
			return __NFUN_155__(__NFUN_156__(int(m_bHasGrenade), 8), 0);
		// End:0xFFFF
		default:
			return false;
			break;
	}
	return;
}

function UpdateLocalActionRequest(R6CircumstantialActionQuery actionRequested)
{
	m_actionRequested.aQueryOwner = actionRequested.aQueryOwner;
	m_actionRequested.aQueryTarget = actionRequested.aQueryTarget;
	m_actionRequested.iMenuChoice = actionRequested.iMenuChoice;
	m_actionRequested.iSubMenuChoice = actionRequested.iSubMenuChoice;
	return;
}

//------------------------------------------------------------------//
// rbrek - 4 sept 2001                                              //
// TeamActionRequested()											//
//   this is the function that dispatches an action request to a    //
//   player's team.                                                 //
//------------------------------------------------------------------//
function TeamActionRequest(R6CircumstantialActionQuery actionRequested)
{
	local int iHostage;
	local Vector vActorDir;

	// End:0x39
	if(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_129__(m_bLeaderIsAPlayer), __NFUN_152__(m_iMemberCount, 1)), m_bTeamIsClimbingLadder), Level.m_bInGamePlanningActive))
	{
		return;
	}
	RestoreTeamOrder();
	// End:0x4E
	if(m_bCAWaitingForZuluGoCode)
	{
		ResetZuluGoCode();
	}
	UpdateLocalActionRequest(actionRequested);
	m_bTeamIsHoldingPosition = false;
	// End:0xA5
	if(actionRequested.aQueryTarget.__NFUN_303__('R6Terrorist'))
	{
		m_iTeamAction = 1024;
		InstructTeamToArrestTerrorist(R6Terrorist(actionRequested.aQueryTarget));		
	}
	else
	{
		// End:0xED
		if(actionRequested.aQueryTarget.__NFUN_303__('R6Hostage'))
		{
			m_iTeamAction = 2048;
			MoveTeamTo(actionRequested.aQueryTarget.Location);			
		}
		else
		{
			// End:0x131
			if(actionRequested.aQueryTarget.__NFUN_303__('R6LadderVolume'))
			{
				m_iTeamAction = 512;
				InstructTeamToClimbLadder(R6LadderVolume(actionRequested.aQueryTarget));				
			}
			else
			{
				// End:0x1AD
				if(actionRequested.aQueryTarget.__NFUN_303__('R6IORotatingDoor'))
				{
					// End:0x179
					if(R6IORotatingDoor(actionRequested.aQueryTarget).m_bIsDoorClosed)
					{
						m_iTeamAction = 16;						
					}
					else
					{
						m_iTeamAction = 32;
					}
					ChooseOpenSound(actionRequested);
					AssignAction(R6IORotatingDoor(actionRequested.aQueryTarget), -1);					
				}
				else
				{
					// End:0x239
					if(actionRequested.aQueryTarget.__NFUN_303__('R6IOBomb'))
					{
						m_iTeamAction = 4096;
						vActorDir = __NFUN_212__(Vector(R6IOBomb(actionRequested.aQueryTarget).Rotation), float(-80));
						vActorDir.Z = 0.0000000;
						MoveTeamTo(__NFUN_215__(actionRequested.aQueryTarget.Location, vActorDir));						
					}
					else
					{
						// End:0x2C5
						if(actionRequested.aQueryTarget.__NFUN_303__('R6IODevice'))
						{
							m_iTeamAction = 8192;
							vActorDir = __NFUN_212__(Vector(R6IODevice(actionRequested.aQueryTarget).Rotation), float(-80));
							vActorDir.Z = 0.0000000;
							MoveTeamTo(__NFUN_215__(actionRequested.aQueryTarget.Location, vActorDir));							
						}
						else
						{
							// End:0x328
							if(actionRequested.aQueryTarget.__NFUN_303__('R6PlayerController'))
							{
								m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 1);
								m_iTeamAction = 256;
								MoveTeamTo(R6PlayerController(m_TeamLeader.Controller).m_vRequestedLocation);								
							}
						}
					}
				}
			}
		}
	}
	return;
}

//------------------------------------------------------------------//
// rbrek - 5 sept 2001                                              //
// TeamActionRequestFromRoseDesVents()								//
//   this is the function that dispatches a action request to a     //
//   rainbow team that comes from the rose des vents                //
//------------------------------------------------------------------//
function TeamActionRequestFromRoseDesVents(R6CircumstantialActionQuery actionRequested, int iMenuChoice, int iSubMenuChoice, optional bool bOrderOnZulu)
{
	local R6IORotatingDoor Door;
	local Vector vActorDir;

	actionRequested.iMenuChoice = iMenuChoice;
	actionRequested.iSubMenuChoice = iSubMenuChoice;
	// End:0x54
	if(__NFUN_132__(__NFUN_132__(__NFUN_152__(m_iMemberCount, 1), m_bTeamIsClimbingLadder), Level.m_bInGamePlanningActive))
	{
		return;
	}
	RestoreTeamOrder();
	// End:0x76
	if(__NFUN_130__(__NFUN_129__(bOrderOnZulu), m_bCAWaitingForZuluGoCode))
	{
		ResetZuluGoCode();
	}
	m_bTeamIsHoldingPosition = false;
	UpdateLocalActionRequest(actionRequested);
	// End:0x2A1
	if(actionRequested.aQueryTarget.__NFUN_303__('R6IORotatingDoor'))
	{
		Door = R6IORotatingDoor(actionRequested.aQueryTarget);
		switch(actionRequested.iMenuChoice)
		{
			// End:0x10E
			case int(Door.5):
				m_iTeamAction = 32;
				ChooseOpenSound(actionRequested);
				AssignAction(Door, actionRequested.iSubMenuChoice);
				// End:0x29E
				break;
			// End:0x14D
			case int(Door.1):
				m_iTeamAction = 16;
				ChooseOpenSound(actionRequested);
				AssignAction(Door, actionRequested.iSubMenuChoice);
				// End:0x29E
				break;
			// End:0x197
			case int(Door.2):
				m_iTeamAction = 144;
				m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 13);
				AssignAction(Door, actionRequested.iSubMenuChoice);
				// End:0x29E
				break;
			// End:0x1CB
			case int(Door.3):
				m_iTeamAction = 80;
				AssignAction(Door, actionRequested.iSubMenuChoice);
				// End:0x29E
				break;
			// End:0x1FF
			case int(Door.4):
				m_iTeamAction = 208;
				AssignAction(Door, actionRequested.iSubMenuChoice);
				// End:0x29E
				break;
			// End:0x233
			case int(Door.6):
				m_iTeamAction = 128;
				AssignAction(Door, actionRequested.iSubMenuChoice);
				// End:0x29E
				break;
			// End:0x267
			case int(Door.7):
				m_iTeamAction = 64;
				AssignAction(Door, actionRequested.iSubMenuChoice);
				// End:0x29E
				break;
			// End:0x29B
			case int(Door.8):
				m_iTeamAction = 192;
				AssignAction(Door, actionRequested.iSubMenuChoice);
				// End:0x29E
				break;
			// End:0xFFFF
			default:
				break;
		}		
	}
	else
	{
		// End:0x35A
		if(actionRequested.aQueryTarget.__NFUN_303__('R6PlayerController'))
		{
			// End:0x32A
			if(__NFUN_154__(actionRequested.iMenuChoice, int(R6PlayerController(actionRequested.aQueryTarget).3)))
			{
				m_iTeamAction = 320;
				MoveTeamTo(R6PlayerController(m_TeamLeader.Controller).m_vRequestedLocation, actionRequested.iSubMenuChoice);				
			}
			else
			{
				m_iTeamAction = 256;
				MoveTeamTo(R6PlayerController(m_TeamLeader.Controller).m_vRequestedLocation);
			}			
		}
		else
		{
			// End:0x39E
			if(actionRequested.aQueryTarget.__NFUN_303__('R6LadderVolume'))
			{
				m_iTeamAction = 512;
				InstructTeamToClimbLadder(R6LadderVolume(actionRequested.aQueryTarget));				
			}
			else
			{
				// End:0x42F
				if(actionRequested.aQueryTarget.__NFUN_303__('R6IOBomb'))
				{
					m_iTeamAction = 4096;
					vActorDir = __NFUN_212__(Vector(R6IOBomb(actionRequested.aQueryTarget).Rotation), float(-80));
					vActorDir.Z = 0.0000000;
					MoveTeamTo(__NFUN_215__(R6IOBomb(actionRequested.aQueryTarget).Location, vActorDir));					
				}
				else
				{
					// End:0x4BB
					if(actionRequested.aQueryTarget.__NFUN_303__('R6IODevice'))
					{
						m_iTeamAction = 8192;
						vActorDir = __NFUN_212__(Vector(R6IODevice(actionRequested.aQueryTarget).Rotation), float(-80));
						vActorDir.Z = 0.0000000;
						MoveTeamTo(__NFUN_215__(actionRequested.aQueryTarget.Location, vActorDir));						
					}
					else
					{
						// End:0x4FF
						if(actionRequested.aQueryTarget.__NFUN_303__('R6Terrorist'))
						{
							m_iTeamAction = 1024;
							InstructTeamToArrestTerrorist(R6Terrorist(actionRequested.aQueryTarget));							
						}
						else
						{
							// End:0x547
							if(actionRequested.aQueryTarget.__NFUN_303__('R6Hostage'))
							{
								m_iTeamAction = 2048;
								MoveTeamTo(actionRequested.aQueryTarget.Location);								
							}
						}
					}
				}
			}
		}
	}
	return;
}

//------------------------------------------------------------------
// ChooseOpenSound()
//	Choose the right sound to be played. If it's a volet say open it 
//------------------------------------------------------------------
function ChooseOpenSound(R6CircumstantialActionQuery actionRequested)
{
	// End:0x72
	if(R6IORotatingDoor(actionRequested.aQueryTarget).m_bIsDoorClosed)
	{
		// End:0x59
		if(R6IORotatingDoor(actionRequested.aQueryTarget).m_bTreatDoorAsWindow)
		{
			m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 11);			
		}
		else
		{
			m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 9);
		}		
	}
	else
	{
		// End:0xAB
		if(R6IORotatingDoor(actionRequested.aQueryTarget).m_bTreatDoorAsWindow)
		{
			m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 12);			
		}
		else
		{
			m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 10);
		}
	}
	return;
}

//------------------------------------------------------------------
// TeamActionRequestWaitForZuluGoCode()
//	Action will be executed at Zulu GoCode
//------------------------------------------------------------------
function TeamActionRequestWaitForZuluGoCode(R6CircumstantialActionQuery actionRequested, int iMenuChoice, int iSubMenuChoice)
{
	actionRequested.iMenuChoice = iMenuChoice;
	actionRequested.iSubMenuChoice = iSubMenuChoice;
	UpdateLocalActionRequest(actionRequested);
	// End:0x59
	if(__NFUN_129__(m_bCAWaitingForZuluGoCode))
	{
		m_bCAWaitingForZuluGoCode = true;
		m_eBackupGoCode = m_eGoCode;
		m_eGoCode = 3;
	}
	TeamActionRequestFromRoseDesVents(m_actionRequested, m_actionRequested.iMenuChoice, m_actionRequested.iSubMenuChoice, true);
	return;
}

//------------------------------------------------------------------//
// ReceivedZuluGoCode()												//
//------------------------------------------------------------------//
function ReceivedZuluGoCode()
{
	// End:0x0F
	if(m_bCAWaitingForZuluGoCode)
	{
		ResetZuluGoCode();
	}
	return;
}

//------------------------------------------------------------------//
// PlaySniperOrder()                                                //
//------------------------------------------------------------------//
function PlaySniperOrder()
{
	// End:0x22
	if(m_bSniperHold)
	{
		m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 44);		
	}
	else
	{
		m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 43);
	}
	return;
}

//------------------------------------------------------------------//
// PlayGoCode()	               									    //
//------------------------------------------------------------------//
function PlayGoCode(Object.EGoCode eGo)
{
	switch(eGo)
	{
		// End:0x25
		case 0:
			m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 33);
			// End:0xB0
			break;
		// End:0x43
		case 1:
			m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 34);
			// End:0xB0
			break;
		// End:0x61
		case 2:
			m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 35);
			// End:0xB0
			break;
		// End:0xAD
		case 3:
			m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 36);
			// End:0xAA
			if(__NFUN_130__(m_bCAWaitingForZuluGoCode, __NFUN_151__(m_iMemberCount, 1)))
			{
				m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 6);
			}
			// End:0xB0
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

//------------------------------------------------------------------
// SetTeamIsClimbingLadder: set the bool and inform the escorted team
//	to climb the ladder.
//------------------------------------------------------------------
function SetTeamIsClimbingLadder(bool bClimbing)
{
	m_bTeamIsClimbingLadder = bClimbing;
	return;
}

//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// TeamLeaderIsClimbingLadder()										//
//   this should be called from the playercontroller as well as the //
//   AIcontroller for the team lead                                 //
//------------------------------------------------------------------//
function TeamLeaderIsClimbingLadder()
{
	local int i;

	// End:0x23
	if(__NFUN_132__(__NFUN_130__(m_bTeamIsSeparatedFromLeader, m_bLeaderIsAPlayer), __NFUN_154__(m_iMemberCount, 1)))
	{
		return;
	}
	// End:0x2E
	if(m_bTeamIsClimbingLadder)
	{
		return;
	}
	SetTeamIsClimbingLadder(true);
	UpdateTeamFormation(0);
	m_TeamLadder = m_TeamLeader.m_Ladder;
	// End:0x10D
	if(__NFUN_151__(m_iMemberCount, 1))
	{
		i = 1;
		J0x63:

		// End:0x10D [Loop If]
		if(__NFUN_150__(i, m_iMemberCount))
		{
			m_Team[i].Controller.MoveTarget = m_TeamLeader.m_Ladder;
			m_Team[i].m_Ladder = m_TeamLeader.m_Ladder;
			R6RainbowAI(m_Team[i].Controller).ResetStateProgress();
			m_Team[i].Controller.__NFUN_113__('TeamClimbLadder');
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x63;
		}
	}
	return;
}

//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// TeamFinishedClimbingLadder()										//
//   called when all team members have finished climbing the ladder //
//------------------------------------------------------------------//
function TeamFinishedClimbingLadder()
{
	// End:0x19
	if(__NFUN_151__(__NFUN_156__(m_iTeamAction, 512), 0))
	{
		ActionCompleted(true);
	}
	UpdateTeamFormation(1);
	SetTeamIsClimbingLadder(false);
	return;
}

//------------------------------------------------------------------
// rbrek 
// 17 sept 2002
//------------------------------------------------------------------
function bool AllMembersAreOnTheSameSideOfTheLadder(R6LadderVolume Ladder)
{
	local bool bLeaderIsAtTopOfLadder;
	local int iLeader, i;

	// End:0x52
	if(m_bTeamIsSeparatedFromLeader)
	{
		// End:0x17
		if(__NFUN_154__(m_iMemberCount, 2))
		{
			return true;
		}
		iLeader = 1;
		bLeaderIsAtTopOfLadder = __NFUN_177__(m_Team[1].Location.Z, Ladder.Location.Z);		
	}
	else
	{
		// End:0x5F
		if(__NFUN_154__(m_iMemberCount, 1))
		{
			return true;
		}
		iLeader = 0;
		bLeaderIsAtTopOfLadder = __NFUN_177__(m_TeamLeader.Location.Z, Ladder.Location.Z);
	}
	i = __NFUN_146__(iLeader, 1);
	J0xA3:

	// End:0xF7 [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		// End:0xED
		if(__NFUN_243__(bLeaderIsAtTopOfLadder, __NFUN_177__(m_Team[i].Location.Z, Ladder.Location.Z)))
		{
			return false;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xA3;
	}
	return true;
	return;
}

//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// MemberFinishedClimbingLadder()									//
//   called when any member of the team finished climbing the       //
//   ladder.  (NPC and player)                                      //
//------------------------------------------------------------------//
function MemberFinishedClimbingLadder(R6Pawn member)
{
	local int i, iTotalMember, iLeader;

	// End:0x42
	if(__NFUN_130__(__NFUN_130__(__NFUN_114__(R6Rainbow(member), m_TeamLeader), member.m_bIsPlayer), __NFUN_132__(m_bTeamIsSeparatedFromLeader, __NFUN_154__(m_iMemberCount, 1))))
	{
		return;
	}
	// End:0x58
	if(__NFUN_129__(member.IsAlive()))
	{
		return;
	}
	// End:0xDA
	if(AllMembersAreOnTheSameSideOfTheLadder(R6LadderVolume(m_TeamLadder.MyLadder)))
	{
		TeamFinishedClimbingLadder();
		// End:0x8D
		if(m_bTeamIsSeparatedFromLeader)
		{
			iLeader = 1;			
		}
		else
		{
			iLeader = 0;
		}
		i = __NFUN_146__(iLeader, 1);
		J0xA2:

		// End:0xDA [Loop If]
		if(__NFUN_150__(i, m_iMemberCount))
		{
			m_Team[i].Controller.__NFUN_113__('FollowLeader');
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0xA2;
		}
	}
	return;
}

//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// TeamHasFinishedClimbingLadder()									//
//   this function returns a boolean that indicates whether the     //
//   entire team has finished climbing the ladder                   //
//------------------------------------------------------------------//
function bool TeamHasFinishedClimbingLadder()
{
	// End:0x0E
	if(m_bTeamIsClimbingLadder)
	{
		return false;		
	}
	else
	{
		return true;
	}
	return;
}

//------------------------------------------------------------------//
// rbrek - 8 feb 2002                                               //
// MembersAreOnSameEndOfLadder()									//
//------------------------------------------------------------------//
function bool MembersAreOnSameEndOfLadder(R6Pawn p1, R6Pawn p2)
{
	// End:0x35
	if(__NFUN_176__(__NFUN_186__(__NFUN_175__(p1.Location.Z, p2.Location.Z)), float(30)))
	{
		return true;
	}
	return false;
	return;
}

//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// InstructTeamToClimbLadder()										//
//   instructs team to climb the ladder without the leader, will    //
//   move to the closest ladder actor, climb to the other end, find //
//   a spot and wait for the leader to call a team regroup          //
//------------------------------------------------------------------//
function InstructTeamToClimbLadder(R6LadderVolume LadderVolume, optional bool bPathFinding, optional int iMemberId)
{
	local float fDistanceToTop, fDistanceToBottom;
	local int i, iMemberLeading;

	// End:0x0E
	if(__NFUN_150__(m_iMemberCount, 2))
	{
		return;
	}
	// End:0x25
	if(bPathFinding)
	{
		iMemberLeading = iMemberId;		
	}
	else
	{
		m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 26);
		PlayOrderTeamOnZulu();
		m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 6);
		iMemberLeading = 1;
	}
	fDistanceToTop = __NFUN_186__(__NFUN_175__(m_Team[iMemberLeading].Location.Z, LadderVolume.m_TopLadder.Location.Z));
	fDistanceToBottom = __NFUN_186__(__NFUN_175__(m_Team[iMemberLeading].Location.Z, LadderVolume.m_BottomLadder.Location.Z));
	// End:0x104
	if(__NFUN_176__(fDistanceToTop, fDistanceToBottom))
	{
		m_TeamLadder = LadderVolume.m_TopLadder;		
	}
	else
	{
		m_TeamLadder = LadderVolume.m_BottomLadder;
	}
	m_Team[iMemberLeading].Controller.MoveTarget = m_TeamLadder;
	// End:0x221
	if(bPathFinding)
	{
		SetTeamState(18);
		// End:0x18A
		if(__NFUN_130__(__NFUN_154__(iMemberLeading, 0), __NFUN_129__(m_bLeaderIsAPlayer)))
		{
			m_Team[iMemberLeading].Controller.NextState = 'WaitForTeam';			
		}
		else
		{
			// End:0x1C6
			if(__NFUN_130__(m_bLeaderIsAPlayer, __NFUN_154__(iMemberLeading, 1)))
			{
				m_Team[iMemberLeading].Controller.NextState = 'TeamClimbEndNoLeader';				
			}
			else
			{
				m_Team[iMemberLeading].Controller.NextState = m_Team[iMemberLeading].Controller.__NFUN_284__();
			}
		}
		m_Team[iMemberLeading].Controller.__NFUN_113__('ApproachLadder');		
	}
	else
	{
		// End:0x267
		if(m_Team[iMemberLeading].m_bIsClimbingLadder)
		{
			SetTeamState(18);
			m_Team[iMemberLeading].Controller.NextState = 'TeamClimbEndNoLeader';			
		}
		else
		{
			m_Team[iMemberLeading].Controller.__NFUN_113__('TeamClimbStartNoLeader');
		}
		TeamIsSeparatedFromLead(true);
	}
	UpdateTeamFormation(0);
	// End:0x349
	if(__NFUN_151__(m_iMemberCount, __NFUN_146__(iMemberLeading, 1)))
	{
		i = __NFUN_146__(iMemberLeading, 1);
		J0x2B5:

		// End:0x349 [Loop If]
		if(__NFUN_150__(i, m_iMemberCount))
		{
			// End:0x33F
			if(MembersAreOnSameEndOfLadder(m_Team[iMemberLeading], m_Team[i]))
			{
				m_Team[i].m_Ladder = m_TeamLadder;
				R6RainbowAI(m_Team[i].Controller).ResetStateProgress();
				m_Team[i].Controller.__NFUN_113__('TeamClimbLadder');
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x2B5;
		}
	}
	return;
}

function PlaySoundTeamStatusReport()
{
	// End:0x3E
	if(__NFUN_132__(__NFUN_132__(m_TeamLeader.m_bIsPlayer, m_bPlayerHasFocus), m_bPlayerInGhostMode))
	{
		m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 30);
	}
	// End:0x29C
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_129__(m_TeamLeader.m_bIsPlayer), __NFUN_129__(m_bPlayerHasFocus)), __NFUN_119__(m_OtherTeamVoicesMgr, none)), __NFUN_151__(m_iMemberCount, 0)))
	{
		switch(m_eTeamState)
		{
			// End:0x10A
			case 1:
				switch(m_eGoCode)
				{
					// End:0xAA
					case 0:
						m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, 24);
						// End:0x107
						break;
					// End:0xC8
					case 1:
						m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, 25);
						// End:0x107
						break;
					// End:0xE6
					case 2:
						m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, 26);
						// End:0x107
						break;
					// End:0x104
					case 3:
						m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, 27);
						// End:0x107
						break;
					// End:0xFFFF
					default:
						break;
				}
				// End:0x29C
				break;
			// End:0x10F
			case 14:
			// End:0x114
			case 15:
			// End:0x119
			case 19:
			// End:0x137
			case 2:
				m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, 23);
				// End:0x29C
				break;
			// End:0x155
			case 6:
				m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, 21);
				// End:0x29C
				break;
			// End:0x1C1
			case 7:
				switch(m_eGoCode)
				{
					// End:0x17F
					case 0:
						m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, 28);
						// End:0x1BE
						break;
					// End:0x19D
					case 1:
						m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, 29);
						// End:0x1BE
						break;
					// End:0x1BB
					case 2:
						m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, 30);
						// End:0x1BE
						break;
					// End:0xFFFF
					default:
						break;
				}
				// End:0x29C
				break;
			// End:0x230
			case 16:
				switch(m_TeamLeader.m_eDeviceAnim)
				{
					// End:0x1F1
					case 2:
						m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_TeamLeader, 8);
					// End:0x20F
					case 3:
						m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_TeamLeader, 0);
						// End:0x22D
						break;
					// End:0x22A
					case 4:
						m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_TeamLeader, 2);
					// End:0xFFFF
					default:
						break;
				}
				// End:0x29C
				break;
			// End:0x24E
			case 20:
				m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_TeamLeader, 6);
				// End:0x29C
				break;
			// End:0x253
			case 21:
			// End:0x258
			case 17:
			// End:0x25D
			case 18:
			// End:0x262
			case 13:
			// End:0x267
			case 4:
			// End:0x26C
			case 3:
			// End:0x271
			case 8:
			// End:0x276
			case 9:
			// End:0x27B
			case 10:
			// End:0x299
			case 5:
				m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, 22);
				// End:0x29C
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		return;
	}
}

//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// InstructPlayerTeamToHoldPosition()								//
//   team holds position, and waits for leader's instruction        //
//------------------------------------------------------------------//  
function InstructPlayerTeamToHoldPosition(optional bool bOtherTeam)
{
	local int i, iMember;

	// End:0x12
	if(m_bTeamIsClimbingLadder)
	{
		m_iTeamAction = 0;
		return;
	}
	TeamIsSeparatedFromLead(true);
	m_bTeamIsHoldingPosition = true;
	m_bPlayerRequestedTeamReform = false;
	// End:0x38
	if(m_bCAWaitingForZuluGoCode)
	{
		ResetZuluGoCode();
	}
	// End:0xAD
	if(m_TeamLeader.m_bIsPlayer)
	{
		// End:0x69
		if(bOtherTeam)
		{
			m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 3);
		}
		// End:0xAD
		if(__NFUN_151__(m_iMemberCount, 1))
		{
			// End:0x95
			if(__NFUN_129__(bOtherTeam))
			{
				m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 2);
			}
			m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 18);
		}
	}
	// End:0x11A
	if(__NFUN_151__(m_iMemberCount, 1))
	{
		iMember = 1;
		J0xBF:

		// End:0x11A [Loop If]
		if(__NFUN_150__(iMember, m_iMemberCount))
		{
			m_Team[iMember].Controller.NextState = 'None';
			m_Team[iMember].Controller.__NFUN_113__('HoldPosition');
			__NFUN_165__(iMember);
			// [Loop Continue]
			goto J0xBF;
		}
	}
	return;
}

//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// InstructPlayerTeamToFollowLead()									//
//   if team is holding position, calling this function will bring  //
//   them out of hold and will resume following leader              //
//------------------------------------------------------------------//        
function InstructPlayerTeamToFollowLead(optional bool bOtherTeam)
{
	local int i;

	// End:0x0B
	if(m_bTeamIsClimbingLadder)
	{
		return;
	}
	m_iTeamAction = 0;
	m_bTeamIsHoldingPosition = false;
	m_bEntryInProgress = false;
	m_bPlayerRequestedTeamReform = false;
	// End:0x39
	if(m_bCAWaitingForZuluGoCode)
	{
		ResetZuluGoCode();
	}
	RestoreTeamOrder();
	// End:0x72
	if(__NFUN_130__(m_TeamLeader.m_bIsPlayer, bOtherTeam))
	{
		m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 4);
	}
	// End:0x198
	if(__NFUN_151__(m_iMemberCount, 1))
	{
		// End:0x12F
		if(m_TeamLeader.m_bIsPlayer)
		{
			// End:0xB0
			if(__NFUN_129__(bOtherTeam))
			{
				m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 0);
			}
			// End:0x10C
			if(__NFUN_177__(__NFUN_225__(__NFUN_216__(m_Team[1].Location, m_TeamLeader.Location)), float(600)))
			{
				// End:0x101
				if(__NFUN_119__(m_MemberVoicesMgr, none))
				{
					m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 4);
				}
				m_bPlayerRequestedTeamReform = true;				
			}
			else
			{
				// End:0x12F
				if(__NFUN_119__(m_MemberVoicesMgr, none))
				{
					m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 5);
				}
			}
		}
		i = 1;
		J0x136:

		// End:0x191 [Loop If]
		if(__NFUN_150__(i, m_iMemberCount))
		{
			m_Team[i].Controller.__NFUN_113__('FollowLeader');
			R6RainbowAI(m_Team[i].Controller).ResetStateProgress();
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x136;
		}
		TeamIsRegroupingOnLead(true);
	}
	return;
}

//------------------------------------------------------------------//
// GrenadeInProximity()												//
// todo : modify this to handle more than one grenade at a time??	//
//------------------------------------------------------------------//
function GrenadeInProximity(R6Rainbow spotter, Vector vGrenadeLocation, float fTimeLeft, float fGrenadeDangerRadius)
{
	local int i;

	// End:0x0B
	if(m_bGrenadeInProximity)
	{
		return;
	}
	m_bGrenadeInProximity = true;
	m_bWasSeparatedFromLeader = m_bTeamIsSeparatedFromLeader;
	// End:0x49
	if(m_bLeaderIsAPlayer)
	{
		TeamIsSeparatedFromLead(true);
		m_vPreviousPosition = m_Team[1].Location;		
	}
	else
	{
		m_vPreviousPosition = m_Team[0].Location;
	}
	// End:0xAC
	if(__NFUN_132__(m_bPlayerHasFocus, Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag)))
	{
		m_MultiCoopMemberVoicesMgr.PlayRainbowTeamVoices(spotter, 11);		
	}
	else
	{
		m_MemberVoicesMgr.PlayRainbowMemberVoices(spotter, 15);
	}
	i = 0;
	J0xC9:

	// End:0x12E [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		// End:0x124
		if(__NFUN_129__(m_Team[i].m_bIsPlayer))
		{
			R6RainbowAI(m_Team[i].Controller).ReactToFragGrenade(vGrenadeLocation, fTimeLeft, fGrenadeDangerRadius);
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xC9;
	}
	return;
}

//------------------------------------------------------------------//
// GasGrenadeInProximity()											//
//------------------------------------------------------------------//
function GasGrenadeInProximity(R6Rainbow spotter)
{
	// End:0x0B
	if(m_bGasGrenadeInProximity)
	{
		return;
	}
	m_bGasGrenadeInProximity = true;
	m_MemberVoicesMgr.PlayRainbowMemberVoices(spotter, 16);
	return;
}

//------------------------------------------------------------------//
// GasGrenadeCleared()												//
//------------------------------------------------------------------//
function GasGrenadeCleared(R6Pawn aPawn)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x74 [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		// End:0x6A
		if(__NFUN_130__(__NFUN_130__(__NFUN_129__(m_Team[i].m_bIsPlayer), __NFUN_119__(m_Team[i], aPawn)), __NFUN_154__(int(m_Team[i].m_eEffectiveGrenade), int(2))))
		{
			return;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	m_bGasGrenadeInProximity = false;
	return;
}

//------------------------------------------------------------------//
// GrenadeThreatIsOver()											//
//------------------------------------------------------------------//
function GrenadeThreatIsOver()
{
	local int i;
	local bool bTeamIsClimbingLadder;

	// End:0x0D
	if(__NFUN_129__(m_bGrenadeInProximity))
	{
		return;
	}
	m_bGrenadeInProximity = false;
	RestoreTeamOrder();
	TeamIsSeparatedFromLead(m_bWasSeparatedFromLeader);
	// End:0x13F
	if(__NFUN_129__(m_bLeaderIsAPlayer))
	{
		i = 0;
		J0x39:

		// End:0x13C [Loop If]
		if(__NFUN_150__(i, m_iMemberCount))
		{
			// End:0x8C
			if(__NFUN_132__(m_Team[i].m_bIsClimbingLadder, __NFUN_154__(int(m_Team[i].Physics), int(11))))
			{
				bTeamIsClimbingLadder = true;
				// [Explicit Continue]
				goto J0x132;
			}
			// End:0x10E
			if(__NFUN_154__(i, 0))
			{
				// End:0xEB
				if(m_bTeamIsHoldingPosition)
				{
					R6RainbowAI(m_Team[0].Controller).FindPathToTargetLocation(m_vPreviousPosition);
					R6RainbowAI(m_Team[0].Controller).m_PostFindPathToState = 'HoldPosition';					
				}
				else
				{
					R6RainbowAI(m_Team[0].Controller).__NFUN_113__('Patrol');
				}
				// [Explicit Continue]
				goto J0x132;
			}
			R6RainbowAI(m_Team[i].Controller).__NFUN_113__('FollowLeader');
			J0x132:

			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x39;
		}		
	}
	else
	{
		// End:0x14C
		if(__NFUN_154__(m_iMemberCount, 1))
		{
			return;
		}
		i = 1;
		J0x153:

		// End:0x24C [Loop If]
		if(__NFUN_150__(i, m_iMemberCount))
		{
			// End:0x1A6
			if(__NFUN_132__(m_Team[i].m_bIsClimbingLadder, __NFUN_154__(int(m_Team[i].Physics), int(11))))
			{
				bTeamIsClimbingLadder = true;
				// [Explicit Continue]
				goto J0x242;
			}
			// End:0x21E
			if(m_bTeamIsSeparatedFromLeader)
			{
				// End:0x1F7
				if(__NFUN_154__(i, 1))
				{
					m_iTeamAction = 256;
					m_vActionLocation = m_vPreviousPosition;
					R6RainbowAI(m_Team[i].Controller).__NFUN_113__('TeamMoveTo');					
				}
				else
				{
					R6RainbowAI(m_Team[i].Controller).__NFUN_113__('FollowLeader');
				}
				// [Explicit Continue]
				goto J0x242;
			}
			R6RainbowAI(m_Team[i].Controller).__NFUN_113__('FollowLeader');
			J0x242:

			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x153;
		}
	}
	m_bTeamIsClimbingLadder = bTeamIsClimbingLadder;
	return;
}

//------------------------------------------------------------------//
// FriendlyFlashBang()												//
//------------------------------------------------------------------//
function bool FriendlyFlashBang(Actor aGrenade)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x40 [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		// End:0x36
		if(__NFUN_114__(aGrenade.Instigator, m_Team[i]))
		{
			return true;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// InstructTeamToArrestTerrorist()									//
//------------------------------------------------------------------//
function InstructTeamToArrestTerrorist(R6Terrorist terrorist)
{
	local int i;

	m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 27);
	TeamIsSeparatedFromLead(true);
	// End:0x85
	if(__NFUN_151__(m_iMemberCount, 1))
	{
		PlayOrderTeamOnZulu();
		m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 6);
		R6RainbowAI(m_Team[1].Controller).m_ActionTarget = terrorist;
		m_Team[1].Controller.__NFUN_113__('TeamSecureTerrorist');
	}
	// End:0xD1
	if(__NFUN_151__(m_iMemberCount, 2))
	{
		i = 2;
		J0x99:

		// End:0xD1 [Loop If]
		if(__NFUN_150__(i, m_iMemberCount))
		{
			m_Team[i].Controller.__NFUN_113__('FollowLeader');
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x99;
		}
	}
	return;
}

//------------------------------------------------------------------//
// rbrek - 5 sept 2001                                              //
// MoveTeamTo()														//
// TODO: add action to the MoveTeamTo...                            //
// TODO: if team does not see the target, do nothing...             //
//------------------------------------------------------------------//
function MoveTeamTo(Vector vLocation, optional int iSubAction)
{
	local int i;
	local R6Pawn actionMember;
	local R6RainbowAI rainbowAI;

	TeamIsSeparatedFromLead(true);
	m_iSubAction = iSubAction;
	// End:0x43A
	if(__NFUN_151__(m_iMemberCount, 1))
	{
		switch(m_iTeamAction)
		{
			// End:0x10E
			case 320:
				actionMember = SelectMemberWithFrag(m_iSubAction, m_TeamLeader.Controller);
				// End:0xED
				if(__NFUN_114__(actionMember, none))
				{
					switch(m_eEntryGrenadeType)
					{
						// End:0x7D
						case 1:
							m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 8);
							// End:0xDD
							break;
						// End:0x9D
						case 2:
							m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 10);
							// End:0xDD
							break;
						// End:0xBD
						case 3:
							m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 11);
							// End:0xDD
							break;
						// End:0xDA
						case 4:
							m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 9);
						// End:0xFFFF
						default:
							break;
					}
					ActionCompleted(false);
					InstructPlayerTeamToHoldPosition(false);
					return;
				}
				PlayOrderTeamOnZulu();
				m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 6);
				// End:0x333
				break;
			// End:0x193
			case 4096:
				m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 32);
				PlayOrderTeamOnZulu();
				ReorganizeTeamToInteractWithDevice(4096, m_actionRequested.aQueryTarget);
				R6RainbowAI(m_Team[1].Controller).m_ActionTarget = m_actionRequested.aQueryTarget;
				m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 6);
				// End:0x333
				break;
			// End:0x218
			case 8192:
				m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 31);
				PlayOrderTeamOnZulu();
				ReorganizeTeamToInteractWithDevice(8192, m_actionRequested.aQueryTarget);
				R6RainbowAI(m_Team[1].Controller).m_ActionTarget = m_actionRequested.aQueryTarget;
				m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 6);
				// End:0x333
				break;
			// End:0x2BF
			case 2048:
				// End:0x25B
				if(__NFUN_119__(R6Hostage(m_actionRequested.aQueryTarget).m_escortedByRainbow, none))
				{
					m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 29);					
				}
				else
				{
					m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 28);
				}
				PlayOrderTeamOnZulu();
				R6RainbowAI(m_Team[1].Controller).m_ActionTarget = m_actionRequested.aQueryTarget;
				m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 6);
				// End:0x333
				break;
			// End:0x330
			case 256:
				m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 1);
				PlayOrderTeamOnZulu();
				// End:0x315
				if(__NFUN_132__(__NFUN_154__(m_iMemberCount, 2), m_bCAWaitingForZuluGoCode))
				{
					m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 6);					
				}
				else
				{
					m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 19);
				}
				// End:0x333
				break;
			// End:0xFFFF
			default:
				break;
		}
		m_iGrenadeThrower = 1;
		rainbowAI = R6RainbowAI(m_Team[m_iGrenadeThrower].Controller);
		// End:0x3AC
		if(__NFUN_154__(m_iTeamAction, 320))
		{
			rainbowAI.m_iStateProgress = 0;
			rainbowAI.m_vLocationOnTarget = vLocation;
			m_vActionLocation = rainbowAI.Pawn.Location;			
		}
		else
		{
			// End:0x3FC
			if(__NFUN_154__(m_iTeamAction, 256))
			{
				m_vActionLocation = __NFUN_215__(vLocation, vect(0.0000000, 0.0000000, 80.0000000));
				m_Team[m_iGrenadeThrower].__NFUN_1800__(m_vActionLocation, vect(38.0000000, 38.0000000, 80.0000000));				
			}
			else
			{
				m_vActionLocation = vLocation;
			}
		}
		// End:0x42A
		if(rainbowAI.__NFUN_281__('TeamMoveTo'))
		{
			rainbowAI.ResetTeamMoveTo();
		}
		rainbowAI.__NFUN_113__('TeamMoveTo');
	}
	// End:0x486
	if(__NFUN_151__(m_iMemberCount, 2))
	{
		i = 2;
		J0x44E:

		// End:0x486 [Loop If]
		if(__NFUN_150__(i, m_iMemberCount))
		{
			m_Team[i].Controller.__NFUN_113__('FollowLeader');
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x44E;
		}
	}
	return;
}

//------------------------------------------------------------------//
// PlayOrderTeamOnZulu()                                            //
// *** Play only if a Zulu go code is send ***                      //
//------------------------------------------------------------------//
function PlayOrderTeamOnZulu()
{
	// End:0x1F
	if(m_bCAWaitingForZuluGoCode)
	{
		m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 37);
	}
	return;
}

//------------------------------------------------------------------//
// rbrek - 5 sept 2001                                              //
// MoveTeamToCompleted()                                            //
//------------------------------------------------------------------//
function MoveTeamToCompleted(bool bStatus)
{
	// End:0x45
	if(__NFUN_151__(m_iMemberCount, 1))
	{
		m_Team[1].Controller.NextState = 'None';
		m_Team[1].Controller.__NFUN_113__('HoldPosition');
	}
	ActionCompleted(bStatus);
	return;
}

//TEAM_InteractDevice
//------------------------------------------------------------------//
// rbrek - 5 sept 2001                                              //
// ReorganizeTeamToInteractWithDevice()                             //
// todo : need to do the same for interacting with an electronics   //
//        device (computer/keypad).									//
//------------------------------------------------------------------//
function ReorganizeTeamToInteractWithDevice(int iTeamAction, Actor actionObject)
{
	local R6Rainbow actionMember;
	local int iMember;
	local float fMemberSkill, fBestSkill;

	iMember = 0;
	J0x07:

	// End:0x111 [Loop If]
	if(__NFUN_150__(iMember, m_iMemberCount))
	{
		// End:0x31
		if(m_Team[iMember].m_bIsPlayer)
		{
			// [Explicit Continue]
			goto J0x107;
		}
		// End:0x60
		if(__NFUN_154__(iTeamAction, 4096))
		{
			fMemberSkill = m_Team[iMember].GetSkill(1);			
		}
		else
		{
			fMemberSkill = m_Team[iMember].GetSkill(2);
		}
		// End:0xDC
		if(__NFUN_132__(__NFUN_130__(__NFUN_154__(iTeamAction, 4096), m_Team[iMember].m_bHasDiffuseKit), __NFUN_130__(__NFUN_154__(iTeamAction, 8192), m_Team[iMember].m_bHasElectronicsKit)))
		{
			__NFUN_184__(fMemberSkill, float(20));
		}
		// End:0x107
		if(__NFUN_177__(fMemberSkill, fBestSkill))
		{
			actionMember = m_Team[iMember];
			fBestSkill = fMemberSkill;
		}
		J0x107:

		__NFUN_165__(iMember);
		// [Loop Continue]
		goto J0x07;
	}
	// End:0x145
	if(m_bLeaderIsAPlayer)
	{
		// End:0x142
		if(__NFUN_155__(actionMember.m_iID, 1))
		{
			ReOrganizeTeam(actionMember.m_iID);
		}		
	}
	else
	{
		// End:0x16D
		if(__NFUN_155__(actionMember.m_iID, 0))
		{
			ReOrganizeTeam(actionMember.m_iID);
		}
		m_iTeamAction = iTeamAction;
		R6RainbowAI(m_Team[0].Controller).m_ActionTarget = actionObject;
		m_vActionLocation = __NFUN_216__(actionObject.Location, __NFUN_213__(float(80), Vector(actionObject.Rotation)));
		m_Team[0].Controller.__NFUN_113__('TeamMoveTo');
	}
	return;
}

//------------------------------------------------------------------//
// ReOrganizeTeamForGrenade											//
//   for AI led team only									        //
//------------------------------------------------------------------//
function ReOrganizeTeamForGrenade(Object.EPlanAction ePAction)
{
	local R6Rainbow actionMember;
	local int i;

	switch(ePAction)
	{
		// End:0x17
		case 1:
			m_eEntryGrenadeType = 1;
			// End:0x52
			break;
		// End:0x27
		case 3:
			m_eEntryGrenadeType = 2;
			// End:0x52
			break;
		// End:0x37
		case 2:
			m_eEntryGrenadeType = 3;
			// End:0x52
			break;
		// End:0x47
		case 4:
			m_eEntryGrenadeType = 4;
			// End:0x52
			break;
		// End:0xFFFF
		default:
			m_eEntryGrenadeType = 0;
			break;
	}
	actionMember = FindRainbowWithGrenadeType(m_eEntryGrenadeType, true);
	// End:0x79
	if(__NFUN_114__(actionMember, none))
	{
		m_bSkipAction = true;
		return;
	}
	// End:0xA1
	if(__NFUN_155__(actionMember.m_iID, 0))
	{
		ReOrganizeTeam(actionMember.m_iID);
	}
	return;
}

//------------------------------------------------------------------//
// SelectMemberWithFrag()											//
//------------------------------------------------------------------//
function R6Pawn SelectMemberWithFrag(int iSubAction, Actor Target)
{
	local R6Pawn actionMember;

	// End:0xA9
	if(Target.__NFUN_303__('R6IORotatingDoor'))
	{
		switch(iSubAction)
		{
			// End:0x3B
			case int(R6IORotatingDoor(Target).9):
				m_eEntryGrenadeType = 1;
				// End:0xA6
				break;
			// End:0x5B
			case int(R6IORotatingDoor(Target).10):
				m_eEntryGrenadeType = 2;
				// End:0xA6
				break;
			// End:0x7B
			case int(R6IORotatingDoor(Target).11):
				m_eEntryGrenadeType = 3;
				// End:0xA6
				break;
			// End:0x9B
			case int(R6IORotatingDoor(Target).12):
				m_eEntryGrenadeType = 4;
				// End:0xA6
				break;
			// End:0xFFFF
			default:
				m_eEntryGrenadeType = 0;
				break;
		}		
	}
	else
	{
		// End:0xBB
		if(__NFUN_114__(R6PlayerController(Target), none))
		{
			return none;
		}
		switch(iSubAction)
		{
			// End:0xE2
			case int(R6PlayerController(Target).4):
				m_eEntryGrenadeType = 1;
				// End:0x14D
				break;
			// End:0x102
			case int(R6PlayerController(Target).5):
				m_eEntryGrenadeType = 2;
				// End:0x14D
				break;
			// End:0x122
			case int(R6PlayerController(Target).6):
				m_eEntryGrenadeType = 3;
				// End:0x14D
				break;
			// End:0x142
			case int(R6PlayerController(Target).7):
				m_eEntryGrenadeType = 4;
				// End:0x14D
				break;
			// End:0xFFFF
			default:
				m_eEntryGrenadeType = 0;
				break;
		}
	}
	// End:0x3BF
	if(__NFUN_155__(int(m_eEntryGrenadeType), int(0)))
	{
		// End:0x3AD
		if(m_TeamLeader.m_bIsPlayer)
		{
			switch(m_eEntryGrenadeType)
			{
				// End:0x203
				case 1:
					switch(m_iTeamAction)
					{
						// End:0x1A3
						case 320:
							m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 5);
							// End:0x200
							break;
						// End:0x1C1
						case 192:
							m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 22);
							// End:0x200
							break;
						// End:0x1DF
						case 80:
							m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 14);
							// End:0x200
							break;
						// End:0x1FD
						case 208:
							m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 18);
							// End:0x200
							break;
						// End:0xFFFF
						default:
							break;
					}
					// End:0x3AD
					break;
				// End:0x290
				case 2:
					switch(m_iTeamAction)
					{
						// End:0x230
						case 320:
							m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 6);
							// End:0x28D
							break;
						// End:0x24E
						case 192:
							m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 23);
							// End:0x28D
							break;
						// End:0x26C
						case 80:
							m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 15);
							// End:0x28D
							break;
						// End:0x28A
						case 208:
							m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 19);
							// End:0x28D
							break;
						// End:0xFFFF
						default:
							break;
					}
					// End:0x3AD
					break;
				// End:0x31D
				case 3:
					switch(m_iTeamAction)
					{
						// End:0x2BD
						case 320:
							m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 8);
							// End:0x31A
							break;
						// End:0x2DB
						case 192:
							m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 25);
							// End:0x31A
							break;
						// End:0x2F9
						case 80:
							m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 17);
							// End:0x31A
							break;
						// End:0x317
						case 208:
							m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 21);
							// End:0x31A
							break;
						// End:0xFFFF
						default:
							break;
					}
					// End:0x3AD
					break;
				// End:0x3AA
				case 4:
					switch(m_iTeamAction)
					{
						// End:0x34A
						case 320:
							m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 7);
							// End:0x3A7
							break;
						// End:0x368
						case 192:
							m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 24);
							// End:0x3A7
							break;
						// End:0x386
						case 80:
							m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 16);
							// End:0x3A7
							break;
						// End:0x3A4
						case 208:
							m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 20);
							// End:0x3A7
							break;
						// End:0xFFFF
						default:
							break;
					}
					// End:0x3AD
					break;
				// End:0xFFFF
				default:
					break;
			}
		}
		else
		{
			actionMember = FindRainbowWithGrenadeType(m_eEntryGrenadeType, true);
		}/* !MISMATCHING REMOVE, tried If got Type:Else Position:0x3AD! */
		// End:0x3DE
		if(__NFUN_119__(actionMember, none))
		{
			ReOrganizeTeam(actionMember.m_iID);
		}
		return actionMember;
		return;
	}/* !MISMATCHING REMOVE, tried Else got Type:If Position:0x14D! */
}

//------------------------------------------------------------------//
// rbrek - 2 sept 2001                                              //
// function AssignAction()                                          //
//    ( target is a R6IORotatingDoor )                              //
//------------------------------------------------------------------//
function AssignAction(Actor Target, int iSubAction)
{
	local R6Pawn actionMember;
	local R6Door closestDoor;
	local float fDistA, fDistB;
	local R6RainbowAI actionMemberController;
	local int i;

	// End:0x25
	if(__NFUN_132__(__NFUN_154__(m_iMemberCount, 1), __NFUN_129__(Target.__NFUN_303__('R6IORotatingDoor'))))
	{
		return;
	}
	TeamIsSeparatedFromLead(true);
	m_iSubAction = iSubAction;
	// End:0x73
	if(__NFUN_155__(iSubAction, -1))
	{
		actionMember = SelectMemberWithFrag(m_iSubAction, Target);
		// End:0x70
		if(__NFUN_114__(actionMember, none))
		{
			ActionCompleted(false);
			return;
		}		
	}
	else
	{
		// End:0x8B
		if(__NFUN_151__(__NFUN_156__(m_iTeamAction, 64), 0))
		{
			ActionCompleted(false);
			return;
		}
	}
	// End:0xA3
	if(__NFUN_114__(actionMember, none))
	{
		actionMember = m_Team[1];
	}
	PlayOrderTeamOnZulu();
	m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 6);
	// End:0x111
	if(__NFUN_119__(R6IORotatingDoor(Target).m_DoorActorA, none))
	{
		fDistA = __NFUN_225__(__NFUN_216__(R6IORotatingDoor(Target).m_DoorActorA.Location, actionMember.Location));		
	}
	else
	{
		fDistA = 99999.0000000;
	}
	// End:0x16C
	if(__NFUN_119__(R6IORotatingDoor(Target).m_DoorActorB, none))
	{
		fDistB = __NFUN_225__(__NFUN_216__(R6IORotatingDoor(Target).m_DoorActorB.Location, actionMember.Location));		
	}
	else
	{
		fDistB = 99999.0000000;
	}
	actionMemberController = R6RainbowAI(actionMember.Controller);
	// End:0x1C4
	if(__NFUN_176__(fDistA, fDistB))
	{
		actionMemberController.m_ActionTarget = R6IORotatingDoor(Target).m_DoorActorA;		
	}
	else
	{
		actionMemberController.m_ActionTarget = R6IORotatingDoor(Target).m_DoorActorB;
	}
	actionMemberController.ResetStateProgress();
	actionMemberController.NextState = 'HoldPosition';
	actionMemberController.__NFUN_113__('PerformAction');
	// End:0x265
	if(__NFUN_151__(m_iMemberCount, 2))
	{
		i = 2;
		J0x22D:

		// End:0x265 [Loop If]
		if(__NFUN_150__(i, m_iMemberCount))
		{
			m_Team[i].Controller.__NFUN_113__('FollowLeader');
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x22D;
		}
	}
	return;
}

//------------------------------------------------------------------//
// FindRainbowWithGrenadeType()			                            //
//	Look for a rainbow (other than the player) with a grenade of a  //
//	given type.														//
//------------------------------------------------------------------//
simulated function R6Rainbow FindRainbowWithGrenadeType(R6EngineWeapon.eWeaponGrenadeType grenadeType, bool bSetGadgetGroup)
{
	local int iMember, iWeaponGroup;
	local R6EngineWeapon grenadeWeapon;
	local bool bHasGrenade;

	iMember = 0;
	J0x07:

	// End:0x20E [Loop If]
	if(__NFUN_150__(iMember, m_iMemberCount))
	{
		// End:0x60
		if(__NFUN_132__(__NFUN_132__(__NFUN_114__(m_Team[iMember], none), m_Team[iMember].m_bIsPlayer), __NFUN_129__(m_Team[iMember].IsAlive())))
		{
			// [Explicit Continue]
			goto J0x204;
		}
		iWeaponGroup = 3;
		J0x68:

		// End:0x204 [Loop If]
		if(__NFUN_152__(iWeaponGroup, 4))
		{
			bHasGrenade = false;
			grenadeWeapon = m_Team[iMember].GetWeaponInGroup(iWeaponGroup);
			// End:0x17C
			if(__NFUN_130__(__NFUN_130__(__NFUN_119__(grenadeWeapon, none), __NFUN_154__(int(grenadeWeapon.m_eWeaponType), int(6))), grenadeWeapon.HasAmmo()))
			{
				switch(grenadeType)
				{
					// End:0x104
					case 1:
						// End:0x101
						if(grenadeWeapon.HasBulletType('R6FragGrenade'))
						{
							bHasGrenade = true;
						}
						// End:0x17C
						break;
					// End:0x12B
					case 2:
						// End:0x128
						if(grenadeWeapon.HasBulletType('R6TearGasGrenade'))
						{
							bHasGrenade = true;
						}
						// End:0x17C
						break;
					// End:0x152
					case 3:
						// End:0x14F
						if(grenadeWeapon.HasBulletType('R6FlashBang'))
						{
							bHasGrenade = true;
						}
						// End:0x17C
						break;
					// End:0x179
					case 4:
						// End:0x176
						if(grenadeWeapon.HasBulletType('R6SmokeGrenade'))
						{
							bHasGrenade = true;
						}
						// End:0x17C
						break;
					// End:0xFFFF
					default:
						break;
				}
			}
			else
			{
				// End:0x1FA
				if(__NFUN_130__(bHasGrenade, __NFUN_129__(m_Team[iMember].m_bIsPlayer)))
				{
					// End:0x1EE
					if(__NFUN_130__(bSetGadgetGroup, __NFUN_119__(m_Team[iMember].Controller, none)))
					{
						R6RainbowAI(m_Team[iMember].Controller).m_iActionUseGadgetGroup = iWeaponGroup;
					}
					return m_Team[iMember];
				}
				__NFUN_165__(iWeaponGroup);
				// [Loop Continue]
				goto J0x68;
			}/* !MISMATCHING REMOVE, tried Loop got Type:Else Position:0x17C! */
			J0x204:

			__NFUN_165__(iMember);
			// [Loop Continue]
			goto J0x07;
		}
		return none;
		return;
	}/* !MISMATCHING REMOVE, tried Else got Type:Loop Position:0x007! */
}

//------------------------------------------------------------------//
// rbrek - 2 sept 2001                                              //
// ActionCompleted()												//
//   this function is called to inform the TeamAI that a requested  //
//   action has been completed (or in not possible to complete      //
//------------------------------------------------------------------//
function ActionCompleted(bool bSuccess)
{
	local int i, iMember;

	// End:0x11
	if(__NFUN_129__(bSuccess))
	{
		ResetZuluGoCode();
	}
	// End:0x84
	if(m_TeamLeader.m_bIsPlayer)
	{
		// End:0x81
		if(__NFUN_151__(m_iMemberCount, 1))
		{
			m_bTeamIsHoldingPosition = true;
			// End:0x69
			if(bSuccess)
			{
				// End:0x66
				if(__NFUN_151__(__NFUN_156__(m_iTeamAction, 128), 0))
				{
					m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 26);
				}				
			}
			else
			{
				m_MemberVoicesMgr.PlayRainbowMemberVoices(m_Team[1], 7);
			}
		}		
	}
	else
	{
		// End:0xCE
		if(__NFUN_151__(m_iMemberCount, 1))
		{
			iMember = 1;
			J0x96:

			// End:0xCE [Loop If]
			if(__NFUN_150__(iMember, m_iMemberCount))
			{
				m_Team[iMember].Controller.__NFUN_113__('FollowLeader');
				__NFUN_165__(iMember);
				// [Loop Continue]
				goto J0x96;
			}
		}
		TeamIsSeparatedFromLead(false);
	}
	m_iTeamAction = 0;
	return;
}

function ReIssueTeamOrders()
{
	// End:0x26
	if(__NFUN_154__(m_actionRequested.iMenuChoice, -1))
	{
		TeamActionRequest(m_actionRequested);		
	}
	else
	{
		// End:0x59
		if(m_bCAWaitingForZuluGoCode)
		{
			TeamActionRequestWaitForZuluGoCode(m_actionRequested, m_actionRequested.iMenuChoice, m_actionRequested.iSubMenuChoice);			
		}
		else
		{
			TeamActionRequestFromRoseDesVents(m_actionRequested, m_actionRequested.iMenuChoice, m_actionRequested.iSubMenuChoice);
		}
	}
	return;
}

//------------------------------------------------------------------//
//  RainbowIsInFrontOfAClosedDoor()									//
//    when this occurs, the team members should enter an			//
//    appropriate formation depending on the room behind the door   //
//    ROOM_None, ROOM_OpensLeft, ROOM_OpensRight, ROOM_OpensCenter  //
// This function is called from R6Pawn when either a teamleader (or //
// the 2nd team member in a team that is separated from its leader) //
// comes into contact with a closed door							//
//------------------------------------------------------------------//
function RainbowIsInFrontOfAClosedDoor(R6Pawn Rainbow, R6Door Door)
{
	local int i, iOpensClockwise, iStart;

	// End:0x2A
	if(__NFUN_130__(Rainbow.m_bIsPlayer, __NFUN_132__(m_bTeamIsSeparatedFromLeader, m_bTeamIsClimbingLadder)))
	{
		return;
	}
	m_Door = Door;
	m_PawnControllingDoor = Rainbow;
	// End:0x5D
	if(m_Door.m_RotatingDoor.m_bTreatDoorAsWindow)
	{
		return;
	}
	m_bRainbowIsInFrontOfDoor = true;
	m_bEntryInProgress = true;
	m_bDoorOpensTowardTeam = Door.m_RotatingDoor.DoorOpenTowardsActor(Rainbow);
	m_bDoorOpensClockWise = Door.m_RotatingDoor.m_bIsOpeningClockWise;
	// End:0xC9
	if(__NFUN_114__(Rainbow, m_TeamLeader))
	{
		iStart = 1;		
	}
	else
	{
		iStart = __NFUN_146__(Rainbow.m_iID, 1);
	}
	// End:0x113
	if(__NFUN_129__(Rainbow.m_bIsPlayer))
	{
		R6RainbowAI(Rainbow.Controller).m_bEnteredRoom = false;
	}
	i = iStart;
	J0x11E:

	// End:0x1B7 [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		R6RainbowAI(m_Team[i].Controller).ResetStateProgress();
		// End:0x18E
		if(m_Team[i].m_bIsClimbingLadder)
		{
			m_Team[i].Controller.NextState = 'RoomEntry';
			// [Explicit Continue]
			goto J0x1AD;
		}
		m_Team[i].Controller.__NFUN_113__('RoomEntry');
		J0x1AD:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x11E;
	}
	return;
}

//------------------------------------------------------------------//
//  EnteredRoom()													//
//   called by each member of the team once they have entered...    //
//   this function should also be called once player/leader has     //
//   entered the room                                               //
//------------------------------------------------------------------//
function EnteredRoom(R6Pawn member)
{
	local int i;

	// End:0x0D
	if(__NFUN_129__(m_bEntryInProgress))
	{
		return;
	}
	// End:0x40
	if(__NFUN_129__(member.m_bIsPlayer))
	{
		R6RainbowAI(member.Controller).m_bEnteredRoom = true;
	}
	// End:0x82
	if(__NFUN_132__(__NFUN_154__(member.m_iID, __NFUN_147__(m_iMemberCount, 1)), __NFUN_130__(m_bTeamIsSeparatedFromLeader, m_PawnControllingDoor.m_bIsPlayer)))
	{
		m_bEntryInProgress = false;
	}
	return;
}

//------------------------------------------------------------------//
//  HasGoneThroughDoor()											//
//------------------------------------------------------------------//
function bool HasGoneThroughDoor()
{
	// End:0x3D
	if(__NFUN_176__(__NFUN_219__(__NFUN_226__(__NFUN_216__(m_PawnControllingDoor.Location, m_Door.Location)), m_Door.m_vLookDir), float(0)))
	{
		return false;		
	}
	else
	{
		return true;
	}
	return;
}

//------------------------------------------------------------------//
// EndRoomEntry()													//
//   Room entry has been cancelled									//
//------------------------------------------------------------------//
function EndRoomEntry()
{
	local int iStart, i;

	m_PawnControllingDoor = none;
	m_bEntryInProgress = false;
	// End:0x1C
	if(__NFUN_154__(m_iMemberCount, 1))
	{
		return;
	}
	// End:0x30
	if(m_bTeamIsSeparatedFromLeader)
	{
		iStart = 2;		
	}
	else
	{
		iStart = 1;
	}
	i = iStart;
	J0x42:

	// End:0x7A [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		m_Team[i].Controller.__NFUN_113__('FollowLeader');
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x42;
	}
	return;
}

//------------------------------------------------------------------//
// RainbowHasLeftDoor()												//
//   this function is called in a few different cases...			//
//   . door opens and m_PawnControllingDoor goes through open door  //
//   . door opens and m_PawnControllingDoor leaves door area		//
//   . door is not opened, m_PawnControllingDoor leaves area		//
//------------------------------------------------------------------//
function RainbowHasLeftDoor(R6Pawn Rainbow)
{
	local int i, iStart;
	local Vector vDist;
	local float fDir;
	local Vector vDir;

	// End:0x23
	if(__NFUN_132__(__NFUN_114__(m_Door, none), __NFUN_114__(m_Door.m_RotatingDoor, none)))
	{
		return;
	}
	// End:0x4E
	if(m_Door.m_RotatingDoor.m_bTreatDoorAsWindow)
	{
		m_Door = none;
		m_PawnControllingDoor = none;
		return;
	}
	// End:0x75
	if(__NFUN_132__(__NFUN_132__(__NFUN_152__(m_iMemberCount, 1), __NFUN_129__(m_bEntryInProgress)), __NFUN_129__(m_bRainbowIsInFrontOfDoor)))
	{
		return;
	}
	// End:0xA1
	if(__NFUN_130__(__NFUN_130__(__NFUN_119__(Rainbow, none), Rainbow.m_bIsPlayer), m_bTeamIsSeparatedFromLeader))
	{
		return;
	}
	m_bRainbowIsInFrontOfDoor = false;
	// End:0x103
	if(__NFUN_130__(__NFUN_132__(__NFUN_129__(m_Door.m_RotatingDoor.m_bIsDoorClosed), m_Door.m_RotatingDoor.m_bInProcessOfOpening), HasGoneThroughDoor()))
	{
		EnteredRoom(m_PawnControllingDoor);
		m_PawnControllingDoor = none;		
	}
	else
	{
		m_Door = none;
		// End:0x123
		if(__NFUN_114__(m_PawnControllingDoor, m_TeamLeader))
		{
			iStart = 1;			
		}
		else
		{
			iStart = 2;
		}
		i = iStart;
		J0x136:

		// End:0x16E [Loop If]
		if(__NFUN_150__(i, m_iMemberCount))
		{
			m_Team[i].Controller.__NFUN_113__('FollowLeader');
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x136;
		}
		EndRoomEntry();
	}
	return;
}

//------------------------------------------------------------------//
//  GetPlayerDirection()											//
//------------------------------------------------------------------//
function GetPlayerDirection()
{
	local float fDirResult;
	local Vector vCrossDir, vPlayerMove;

	// End:0x16
	if(__NFUN_129__(m_TeamLeader.m_bIsPlayer))
	{
		return;
	}
	vPlayerMove = __NFUN_226__(__NFUN_216__(m_TeamLeader.Location, m_Door.Location));
	fDirResult = __NFUN_219__(vPlayerMove, m_Door.m_vLookDir);
	vCrossDir = __NFUN_220__(vPlayerMove, m_Door.m_vLookDir);
	// End:0xDE
	if(__NFUN_154__(int(m_Door.m_eRoomLayout), int(1)))
	{
		// End:0xB9
		if(__NFUN_132__(__NFUN_177__(fDirResult, 0.9000000), __NFUN_177__(vCrossDir.Z, float(0))))
		{
			m_ePlayerRoomEntry = 2;			
		}
		else
		{
			// End:0xD3
			if(__NFUN_177__(fDirResult, 0.4000000))
			{
				m_ePlayerRoomEntry = 0;				
			}
			else
			{
				m_ePlayerRoomEntry = 1;
			}
		}		
	}
	else
	{
		// End:0x14A
		if(__NFUN_154__(int(m_Door.m_eRoomLayout), int(2)))
		{
			// End:0x125
			if(__NFUN_132__(__NFUN_177__(fDirResult, 0.9000000), __NFUN_176__(vCrossDir.Z, float(0))))
			{
				m_ePlayerRoomEntry = 1;				
			}
			else
			{
				// End:0x13F
				if(__NFUN_177__(fDirResult, 0.4000000))
				{
					m_ePlayerRoomEntry = 0;					
				}
				else
				{
					m_ePlayerRoomEntry = 2;
				}
			}			
		}
		else
		{
			// End:0x164
			if(__NFUN_177__(fDirResult, 0.9000000))
			{
				m_ePlayerRoomEntry = 0;				
			}
			else
			{
				// End:0x181
				if(__NFUN_177__(vCrossDir.Z, float(0)))
				{
					m_ePlayerRoomEntry = 1;					
				}
				else
				{
					m_ePlayerRoomEntry = 2;
				}
			}
		}
	}
	return;
}

//------------------------------------------------------------------//
//  UpdatePlayerWeapon()											//
//------------------------------------------------------------------//
function UpdatePlayerWeapon(R6Rainbow Rainbow)
{
	Rainbow.AttachWeapon(Rainbow.EngineWeapon, Rainbow.EngineWeapon.m_AttachPoint);
	// End:0xA7
	if(__NFUN_130__(__NFUN_119__(Rainbow.EngineWeapon, Rainbow.GetWeaponInGroup(1)), __NFUN_119__(Rainbow.GetWeaponInGroup(1), none)))
	{
		Rainbow.AttachWeapon(Rainbow.GetWeaponInGroup(1), Rainbow.GetWeaponInGroup(1).m_HoldAttachPoint);
	}
	// End:0x11E
	if(__NFUN_130__(__NFUN_119__(Rainbow.EngineWeapon, Rainbow.GetWeaponInGroup(2)), __NFUN_119__(Rainbow.GetWeaponInGroup(2), none)))
	{
		Rainbow.AttachWeapon(Rainbow.GetWeaponInGroup(2), Rainbow.GetWeaponInGroup(2).m_HoldAttachPoint);
	}
	// End:0x195
	if(__NFUN_130__(__NFUN_119__(Rainbow.EngineWeapon, Rainbow.GetWeaponInGroup(3)), __NFUN_119__(Rainbow.GetWeaponInGroup(3), none)))
	{
		Rainbow.AttachWeapon(Rainbow.GetWeaponInGroup(3), Rainbow.GetWeaponInGroup(3).m_HoldAttachPoint);
	}
	// End:0x20C
	if(__NFUN_130__(__NFUN_119__(Rainbow.EngineWeapon, Rainbow.GetWeaponInGroup(4)), __NFUN_119__(Rainbow.GetWeaponInGroup(4), none)))
	{
		Rainbow.AttachWeapon(Rainbow.GetWeaponInGroup(4), Rainbow.GetWeaponInGroup(4).m_HoldAttachPoint);
	}
	// End:0x249
	if(__NFUN_242__(Rainbow.m_bWeaponGadgetActivated, true))
	{
		R6AbstractWeapon(Rainbow.EngineWeapon).m_SelectedWeaponGadget.ActivateGadget(true, true);
	}
	// End:0x26D
	if(__NFUN_242__(Rainbow.m_bActivateNightVision, true))
	{
		Rainbow.ToggleNightVision();
	}
	return;
}

//------------------------------------------------------------------//
//  UpdateFirstPersonWeaponMemory()									//
//------------------------------------------------------------------//
function UpdateFirstPersonWeaponMemory(R6Rainbow npc, R6Rainbow teamLeader)
{
	local int i;
	local R6AbstractWeapon LeaderWeapon, NPCWeapon;

	// End:0x1D8
	if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
	{
		i = 1;
		J0x20:

		// End:0xC5 [Loop If]
		if(__NFUN_152__(i, 4))
		{
			// End:0x83
			if(__NFUN_119__(npc.GetWeaponInGroup(i), none))
			{
				npc.GetWeaponInGroup(i).StopFire(true);
				npc.GetWeaponInGroup(i).RemoveFirstPersonWeapon();
			}
			// End:0xBB
			if(__NFUN_119__(teamLeader.GetWeaponInGroup(i), none))
			{
				teamLeader.GetWeaponInGroup(i).LoadFirstPersonWeapon();
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x20;
		}
		// End:0x1BD
		if(__NFUN_242__(teamLeader.m_bChangingWeapon, true))
		{
			R6AbstractWeapon(teamLeader.EngineWeapon).m_FPHands.SetDrawType(0);
			teamLeader.EngineWeapon.__NFUN_113__('DiscardWeapon');
			teamLeader.PendingWeapon.m_bPawnIsWalking = teamLeader.EngineWeapon.m_bPawnIsWalking;
			teamLeader.EngineWeapon = teamLeader.PendingWeapon;
			// End:0x1A1
			if(teamLeader.EngineWeapon.__NFUN_281__('RaiseWeapon'))
			{
				teamLeader.EngineWeapon.BeginState();				
			}
			else
			{
				teamLeader.EngineWeapon.__NFUN_113__('RaiseWeapon');
			}			
		}
		else
		{
			teamLeader.EngineWeapon.StartLoopingAnims();
		}		
	}
	else
	{
		teamLeader.m_bReloadingWeapon = false;
		teamLeader.m_bPawnIsReloading = false;
		teamLeader.m_bWeaponTransition = false;
		npc.m_bReloadingWeapon = false;
		npc.m_bPawnIsReloading = false;
		npc.m_bWeaponTransition = false;
		// End:0x27F
		if(__NFUN_130__(__NFUN_155__(int(Level.NetMode), int(NM_DedicatedServer)), teamLeader.IsLocallyControlled()))
		{
			teamLeader.RemoteRole = ROLE_SimulatedProxy;			
		}
		else
		{
			teamLeader.RemoteRole = ROLE_AutonomousProxy;
		}
		npc.RemoteRole = ROLE_SimulatedProxy;
		i = 1;
		J0x2A8:

		// End:0x36A [Loop If]
		if(__NFUN_152__(i, 4))
		{
			LeaderWeapon = R6AbstractWeapon(teamLeader.GetWeaponInGroup(i));
			NPCWeapon = R6AbstractWeapon(npc.GetWeaponInGroup(i));
			// End:0x360
			if(__NFUN_119__(LeaderWeapon, none))
			{
				// End:0x33E
				if(__NFUN_130__(__NFUN_155__(int(Level.NetMode), int(NM_DedicatedServer)), teamLeader.IsLocallyControlled()))
				{
					LeaderWeapon.RemoteRole = ROLE_SimulatedProxy;					
				}
				else
				{
					LeaderWeapon.RemoteRole = ROLE_AutonomousProxy;
				}
				NPCWeapon.RemoteRole = ROLE_SimulatedProxy;
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x2A8;
		}
		ClientUpdateFirstPersonWpnAndPeeking(npc, teamLeader);
	}
	return;
}

//Transfer the FPhands and FPweapons to an other pawn.  On client  only
simulated function ClientUpdateFirstPersonWpnAndPeeking(R6Rainbow npc, R6Rainbow teamLeader)
{
	local int i;
	local bool bLoadWorked;
	local R6AbstractWeapon LeaderWeapon, NPCWeapon;
	local Texture scopeTexture;
	local R6PlayerController LocalController;

	LocalController = R6PlayerController(npc.Controller);
	// End:0x3D
	if(__NFUN_114__(LocalController, none))
	{
		LocalController = R6PlayerController(teamLeader.Controller);
	}
	// End:0x78
	if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
	{
		teamLeader.Role = ROLE_AutonomousProxy;
		npc.Role = ROLE_SimulatedProxy;
	}
	teamLeader.bRotateToDesired = false;
	i = 1;
	J0x90:

	// End:0x173 [Loop If]
	if(__NFUN_152__(i, 4))
	{
		LeaderWeapon = R6AbstractWeapon(teamLeader.GetWeaponInGroup(i));
		NPCWeapon = R6AbstractWeapon(npc.GetWeaponInGroup(i));
		// End:0x169
		if(__NFUN_119__(LeaderWeapon, none))
		{
			// End:0x120
			if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
			{
				LeaderWeapon.Role = ROLE_AutonomousProxy;
				NPCWeapon.Role = ROLE_SimulatedProxy;
			}
			npc.GetWeaponInGroup(i).RemoveFirstPersonWeapon();
			bLoadWorked = teamLeader.GetWeaponInGroup(i).LoadFirstPersonWeapon(, LocalController);
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x90;
	}
	// End:0x2D5
	if(__NFUN_242__(bLoadWorked, true))
	{
		// End:0x2A9
		if(__NFUN_242__(teamLeader.m_bChangingWeapon, true))
		{
			// End:0x244
			if(__NFUN_119__(teamLeader.EngineWeapon, teamLeader.PendingWeapon))
			{
				R6AbstractWeapon(teamLeader.EngineWeapon).m_FPHands.SetDrawType(0);
				teamLeader.EngineWeapon.__NFUN_113__('None');
				teamLeader.PendingWeapon.m_bPawnIsWalking = teamLeader.EngineWeapon.m_bPawnIsWalking;
				teamLeader.EngineWeapon = teamLeader.PendingWeapon;
			}
			LocalController.m_bLockWeaponActions = true;
			// End:0x28D
			if(teamLeader.EngineWeapon.__NFUN_281__('RaiseWeapon'))
			{
				teamLeader.EngineWeapon.BeginState();				
			}
			else
			{
				teamLeader.EngineWeapon.__NFUN_113__('RaiseWeapon');
			}			
		}
		else
		{
			// End:0x2D5
			if(__NFUN_119__(teamLeader.EngineWeapon, none))
			{
				teamLeader.EngineWeapon.StartLoopingAnims();
			}
		}
	}
	LocalController.SetPeekingInfo(0, npc.1000.0000000);
	return;
}

//------------------------------------------------------------------
// ResetWeaponReloading()							
//------------------------------------------------------------------
function ResetWeaponReloading()
{
	// End:0x5F
	if(__NFUN_242__(m_Team[0].m_bPawnIsReloading, true))
	{
		m_Team[0].ServerSwitchReloadingWeapon(false);
		m_Team[0].m_bPawnIsReloading = false;
		m_Team[0].__NFUN_113__('None');
		m_Team[0].PlayWeaponAnimation();
	}
	return;
}

//------------------------------------------------------------------
// SetPlayerControllerState()													
//------------------------------------------------------------------
function SetPlayerControllerState(R6PlayerController aPlayerController)
{
	// End:0xC9
	if(m_Team[0].m_bIsClimbingLadder)
	{
		aPlayerController.ClientHideReticule(true);
		m_Team[0].EngineWeapon.__NFUN_113__('PutWeaponDown');
		// End:0xA5
		if(__NFUN_154__(int(m_Team[0].Physics), int(12)))
		{
			aPlayerController.m_bSkipBeginState = true;
			// End:0x92
			if(m_Team[0].m_bGettingOnLadder)
			{
				aPlayerController.__NFUN_113__('PlayerBeginClimbingLadder');				
			}
			else
			{
				aPlayerController.__NFUN_113__('PlayerEndClimbingLadder');
			}			
		}
		else
		{
			aPlayerController.m_bSkipBeginState = false;
			aPlayerController.__NFUN_113__('PlayerClimbing');
		}		
	}
	else
	{
		// End:0x166
		if(__NFUN_130__(__NFUN_154__(int(m_Team[0].Physics), int(11)), __NFUN_119__(m_Team[0].OnLadder, none)))
		{
			R6LadderVolume(m_Team[0].OnLadder).RemoveClimber(m_Team[0]);
			MemberFinishedClimbingLadder(m_Team[0]);
			m_Team[0].RainbowEquipWeapon();
			m_Team[0].m_ePlayerIsUsingHands = 0;
			m_Team[0].m_bWeaponTransition = false;
		}
		aPlayerController.ClientHideReticule(false);
		aPlayerController.__NFUN_113__('PlayerWalking');
		m_Team[0].__NFUN_3970__(1);
	}
	// End:0x1DF
	if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
	{
		aPlayerController.ClientGotoState(aPlayerController.__NFUN_284__(), 'None');
		aPlayerController.ClientDisableFirstPersonViewEffects(true);
	}
	return;
}

//------------------------------------------------------------------
// SetAILeadControllerState()													
//------------------------------------------------------------------
function SetAILeadControllerState()
{
	local R6Ladder topLadder, bottomLadder;

	// End:0x14
	if(m_TeamLeader.m_bIsPlayer)
	{
		return;
	}
	// End:0x1D7
	if(m_TeamLeader.m_bIsClimbingLadder)
	{
		topLadder = R6LadderVolume(m_TeamLeader.OnLadder).m_TopLadder;
		bottomLadder = R6LadderVolume(m_TeamLeader.OnLadder).m_BottomLadder;
		m_TeamLeader.Controller.NextState = 'WaitForTeam';
		// End:0x113
		if(__NFUN_154__(int(m_TeamLeader.Physics), int(12)))
		{
			R6RainbowAI(m_TeamLeader.Controller).m_bMoveTargetAlreadySet = true;
			// End:0xF2
			if(m_TeamLeader.m_bGettingOnLadder)
			{
				m_TeamLeader.Controller.__NFUN_113__('BeginClimbingLadder', 'WaitForStartClimbingAnimToEnd');				
			}
			else
			{
				m_TeamLeader.Controller.__NFUN_113__('EndClimbingLadder', 'WaitForEndClimbingAnimToEnd');
			}			
		}
		else
		{
			m_TeamLeader.Controller.__NFUN_113__('BeginClimbingLadder', 'MoveTowardEndOfLadder');
		}
		// End:0x1B7
		if(__NFUN_130__(__NFUN_119__(m_PlanActionPoint, none), __NFUN_176__(__NFUN_186__(__NFUN_175__(m_PlanActionPoint.Location.Z, topLadder.Location.Z)), __NFUN_186__(__NFUN_175__(m_PlanActionPoint.Location.Z, bottomLadder.Location.Z)))))
		{
			m_TeamLeader.Controller.MoveTarget = topLadder;			
		}
		else
		{
			m_TeamLeader.Controller.MoveTarget = bottomLadder;
		}		
	}
	else
	{
		m_TeamLeader.Controller.__NFUN_113__('Patrol');
		m_TeamLeader.__NFUN_3970__(1);
		// End:0x248
		if(__NFUN_155__(int(m_TeamLeader.m_eEquipWeapon), int(3)))
		{
			m_TeamLeader.RainbowEquipWeapon();
			m_TeamLeader.m_ePlayerIsUsingHands = 0;
			m_TeamLeader.m_bWeaponTransition = false;
		}
	}
	return;
}

//------------------------------------------------------------------
// ResetRainbowControllerStates()							
//------------------------------------------------------------------
function ResetRainbowControllerStates(R6PlayerController aPlayerController, int iMember)
{
	local int i;
	local bool bAtLeastOneMemberIsOnLadder;

	SetPlayerControllerState(aPlayerController);
	i = 1;
	J0x12:

	// End:0x339 [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		R6RainbowAI(m_Team[i].Controller).m_TeamLeader = m_TeamLeader;
		// End:0x261
		if(__NFUN_130__(__NFUN_154__(i, iMember), m_Team[i].m_bIsClimbingLadder))
		{
			m_Team[i].Controller.NextState = 'FollowLeader';
			R6LadderVolume(m_Team[i].OnLadder).DisableCollisions(m_Team[i].m_Ladder);
			// End:0x176
			if(__NFUN_154__(int(m_Team[i].Physics), int(12)))
			{
				R6RainbowAI(m_Team[i].Controller).m_bMoveTargetAlreadySet = true;
				// End:0x14F
				if(m_Team[i].m_bGettingOnLadder)
				{
					m_Team[i].Controller.__NFUN_113__('BeginClimbingLadder', 'WaitForStartClimbingAnimToEnd');					
				}
				else
				{
					m_Team[i].Controller.__NFUN_113__('EndClimbingLadder', 'WaitForEndClimbingAnimToEnd');
				}				
			}
			else
			{
				m_Team[i].Controller.__NFUN_113__('BeginClimbingLadder', 'MoveTowardEndOfLadder');
			}
			// End:0x216
			if(__NFUN_177__(m_Team[0].Location.Z, __NFUN_174__(m_Team[i].Location.Z, float(100))))
			{
				m_Team[i].Controller.MoveTarget = R6LadderVolume(m_Team[i].OnLadder).m_TopLadder;				
			}
			else
			{
				m_Team[i].Controller.MoveTarget = R6LadderVolume(m_Team[i].OnLadder).m_BottomLadder;
			}
			bAtLeastOneMemberIsOnLadder = true;
			// [Explicit Continue]
			goto J0x32F;
		}
		// End:0x32F
		if(__NFUN_129__(m_Team[i].m_bIsClimbingLadder))
		{
			m_Team[i].Controller.__NFUN_113__('FollowLeader');
			// End:0x2CD
			if(__NFUN_155__(int(m_Team[i].Physics), int(2)))
			{
				m_Team[i].__NFUN_3970__(1);
			}
			// End:0x32F
			if(__NFUN_155__(int(m_Team[i].m_eEquipWeapon), int(3)))
			{
				m_Team[i].RainbowEquipWeapon();
				m_Team[i].m_ePlayerIsUsingHands = 0;
				m_Team[i].m_bWeaponTransition = false;
			}
		}
		J0x32F:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x12;
	}
	SetTeamIsClimbingLadder(bAtLeastOneMemberIsOnLadder);
	// End:0x354
	if(m_bCAWaitingForZuluGoCode)
	{
		ResetZuluGoCode();
	}
	return;
}

//------------------------------------------------------------------//
// SwitchPlayerControlToPreviousMember()							//
//   TODO : beware of doing this while team is performing an action //
//------------------------------------------------------------------//
function SwitchPlayerControlToPreviousMember()
{
	local R6Rainbow tempPawn;
	local R6RainbowAI tempRainbowAI;
	local R6PlayerController tempPlayerController;
	local int iLastMember, i;

	// End:0x3A
	if(__NFUN_130__(__NFUN_119__(Level.Game, none), __NFUN_129__(R6AbstractGameInfo(Level.Game).CanSwitchTeamMember())))
	{
		return;
	}
	// End:0x58
	if(__NFUN_129__(m_Team[0].IsAlive()))
	{
		SwitchPlayerControlToNextMember();
		return;
	}
	TeamIsSeparatedFromLead(false);
	// End:0x6C
	if(__NFUN_152__(m_iMemberCount, 1))
	{
		return;
	}
	iLastMember = __NFUN_147__(m_iMemberCount, 1);
	tempPawn = m_Team[iLastMember];
	i = __NFUN_147__(m_iMemberCount, 1);
	J0x99:

	// End:0xE2 [Loop If]
	if(__NFUN_151__(i, 0))
	{
		m_Team[i] = m_Team[__NFUN_147__(i, 1)];
		m_Team[i].m_iID = i;
		__NFUN_166__(i);
		// [Loop Continue]
		goto J0x99;
	}
	m_Team[0] = tempPawn;
	m_TeamLeader = m_Team[0];
	m_TeamLeader.m_iID = 0;
	m_Team[1].ClientQuickResetPeeking();
	m_Team[1].m_bIsPlayer = false;
	m_TeamLeader.m_bIsPlayer = true;
	tempPawn = m_Team[1];
	// End:0x171
	if(__NFUN_242__(tempPawn.m_bIsClimbingLadder, false))
	{
		UpdatePlayerWeapon(tempPawn);		
	}
	else
	{
		// End:0x195
		if(__NFUN_242__(tempPawn.m_bActivateNightVision, true))
		{
			tempPawn.MandatoryToggleNightVision();
		}
	}
	ResetWeaponReloading();
	tempRainbowAI = R6RainbowAI(m_Team[0].Controller);
	tempPlayerController = R6PlayerController(m_Team[1].Controller);
	SwitchControllerRepInfo(tempRainbowAI, tempPlayerController);
	tempPlayerController.ToggleHelmetCameraZoom(true);
	tempPlayerController.CancelShake();
	tempPlayerController.ClientForceUnlockWeapon();
	tempPlayerController.m_iPlayerCAProgress = 0;
	m_Team[1].UnPossessed();
	tempRainbowAI.Possess(m_Team[1]);
	AssociatePlayerAndPawn(tempPlayerController, m_Team[0]);
	m_Team[1].__NFUN_2214__(rot(0, 0, 0));
	m_Team[1].ResetBoneRotation();
	m_Team[1].m_bPostureTransition = false;
	m_TeamLeader.ResetBoneRotation();
	m_TeamLeader.ClientQuickResetPeeking();
	m_TeamLeader.m_bPostureTransition = false;
	UpdateFirstPersonWeaponMemory(tempPawn, m_TeamLeader);
	ResetRainbowControllerStates(tempPlayerController, 1);
	m_iIntermLeader = 0;
	tempPlayerController.UpdatePlayerPostureAfterSwitch();
	UpdateEscortList();
	UpdateTeamGrenadeStatus();
	// End:0x326
	if(__NFUN_130__(__NFUN_151__(__NFUN_156__(m_iTeamAction, 16), 0), m_bTeamIsHoldingPosition))
	{
		m_iTeamAction = 0;
	}
	return;
}

//------------------------------------------------------------------//
// SwitchPlayerControlToNextMember()				   			    //
//   TODO : beware of doing this while team is performing an action //
//   TOFIX : sometimes a pawn remains invisible after switching to  //
//          another pawn (in 1st person)                            //
//------------------------------------------------------------------//
function SwitchPlayerControlToNextMember()
{
	local R6Rainbow tempPawn;
	local R6RainbowAI tempRainbowAI;
	local R6PlayerController tempPlayerController;
	local int iLastMember, i;
	local bool bLeaderIsDead, bBackupIsClimbing;

	// End:0x3A
	if(__NFUN_130__(__NFUN_119__(Level.Game, none), __NFUN_129__(R6AbstractGameInfo(Level.Game).CanSwitchTeamMember())))
	{
		return;
	}
	bLeaderIsDead = __NFUN_129__(m_Team[0].IsAlive());
	TeamIsSeparatedFromLead(false);
	// End:0x9D
	if(bLeaderIsDead)
	{
		// End:0x74
		if(__NFUN_154__(m_iMemberCount, 0))
		{
			return;			
		}
		else
		{
			R6PlayerController(m_Team[0].Controller).ClientFadeCommonSound(0.5000000, 100);
		}		
	}
	else
	{
		// End:0xAA
		if(__NFUN_154__(m_iMemberCount, 1))
		{
			return;
		}
	}
	iLastMember = __NFUN_147__(m_iMemberCount, 1);
	tempPlayerController = R6PlayerController(m_Team[0].Controller);
	// End:0x2AD
	if(bLeaderIsDead)
	{
		tempPawn = m_Team[0];
		i = 0;
		J0xF0:

		// End:0x13D [Loop If]
		if(__NFUN_150__(i, m_iMemberCount))
		{
			m_Team[i] = m_Team[__NFUN_146__(i, 1)];
			m_Team[i].m_iID = i;
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0xF0;
		}
		m_TeamLeader = m_Team[0];
		m_Team[__NFUN_146__(iLastMember, 1)] = tempPawn;
		m_Team[__NFUN_146__(iLastMember, 1)].m_iID = __NFUN_146__(iLastMember, 1);
		tempPawn.m_bIsPlayer = false;
		m_TeamLeader.m_bIsPlayer = true;
		tempRainbowAI = R6RainbowAI(m_TeamLeader.Controller);
		tempPlayerController.ToggleHelmetCameraZoom(true);
		tempPlayerController.CancelShake();
		tempPlayerController.ClientForceUnlockWeapon();
		tempPlayerController.m_iPlayerCAProgress = 0;
		SwitchControllerRepInfo(tempRainbowAI, tempPlayerController);
		bBackupIsClimbing = tempRainbowAI.m_pawn.m_bIsClimbingLadder;
		tempRainbowAI.__NFUN_113__('Dead');
		tempRainbowAI.m_pawn.m_bIsClimbingLadder = bBackupIsClimbing;
		m_Team[__NFUN_146__(iLastMember, 1)].UnPossessed();
		tempRainbowAI.Possess(m_Team[__NFUN_146__(iLastMember, 1)]);
		AssociatePlayerAndPawn(tempPlayerController, m_TeamLeader);
		// End:0x2AA
		if(bBackupIsClimbing)
		{
			SetTeamIsClimbingLadder(true);
		}		
	}
	else
	{
		tempPawn = m_TeamLeader;
		i = 0;
		J0x2BF:

		// End:0x30F [Loop If]
		if(__NFUN_150__(i, __NFUN_147__(m_iMemberCount, 1)))
		{
			m_Team[i] = m_Team[__NFUN_146__(i, 1)];
			m_Team[i].m_iID = i;
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x2BF;
		}
		m_TeamLeader = m_Team[0];
		m_Team[iLastMember] = tempPawn;
		m_Team[iLastMember].m_iID = iLastMember;
		tempPawn.ClientQuickResetPeeking();
		tempPawn.m_bIsPlayer = false;
		m_TeamLeader.m_bIsPlayer = true;
		// End:0x39B
		if(__NFUN_242__(tempPawn.m_bIsClimbingLadder, false))
		{
			UpdatePlayerWeapon(tempPawn);			
		}
		else
		{
			// End:0x3BF
			if(__NFUN_242__(tempPawn.m_bActivateNightVision, true))
			{
				tempPawn.MandatoryToggleNightVision();
			}
		}
		ResetWeaponReloading();
		tempRainbowAI = R6RainbowAI(m_TeamLeader.Controller);
		tempPlayerController = R6PlayerController(m_Team[iLastMember].Controller);
		tempPlayerController.ToggleHelmetCameraZoom(true);
		tempPlayerController.CancelShake();
		tempPlayerController.ClientForceUnlockWeapon();
		tempPlayerController.m_iPlayerCAProgress = 0;
		SwitchControllerRepInfo(tempRainbowAI, tempPlayerController);
		m_Team[iLastMember].UnPossessed();
		tempRainbowAI.Possess(m_Team[iLastMember]);
		AssociatePlayerAndPawn(tempPlayerController, m_TeamLeader);
		m_Team[iLastMember].__NFUN_2214__(rot(0, 0, 0));
		m_Team[iLastMember].ResetBoneRotation();
		m_Team[iLastMember].m_bPostureTransition = false;
	}
	m_TeamLeader.ResetBoneRotation();
	m_TeamLeader.ClientQuickResetPeeking();
	m_TeamLeader.m_bPostureTransition = false;
	UpdateFirstPersonWeaponMemory(tempPawn, m_TeamLeader);
	ResetRainbowControllerStates(tempPlayerController, iLastMember);
	m_iIntermLeader = 0;
	tempPlayerController.UpdatePlayerPostureAfterSwitch();
	UpdateEscortList();
	UpdateTeamGrenadeStatus();
	// End:0x568
	if(__NFUN_130__(__NFUN_151__(__NFUN_156__(m_iTeamAction, 16), 0), m_bTeamIsHoldingPosition))
	{
		m_iTeamAction = 0;
	}
	return;
}

function SwitchControllerRepInfo(R6RainbowAI tempRainbowAI, R6PlayerController tempPlayerController)
{
	local R6PawnReplicationInfo aPawnRepInfo;

	aPawnRepInfo = tempRainbowAI.m_PawnRepInfo;
	tempRainbowAI.m_PawnRepInfo = tempPlayerController.m_PawnRepInfo;
	tempRainbowAI.m_PawnRepInfo.m_ControllerOwner = tempRainbowAI;
	tempPlayerController.m_PawnRepInfo = aPawnRepInfo;
	tempPlayerController.m_PawnRepInfo.m_ControllerOwner = tempPlayerController;
	tempPlayerController.m_CurrentAmbianceObject = tempRainbowAI.Pawn.Region.Zone;
	return;
}

//------------------------------------------------------------------
// AssociatePlayerAndPawn()							
//  we don't want to use Possess/Unpossess, because that would reset 
//  the physics (root motion)
//------------------------------------------------------------------
function AssociatePlayerAndPawn(R6PlayerController Player, R6Rainbow Pawn)
{
	Player.PossessInit(Pawn);
	Player.SetViewTarget(Pawn);
	Pawn.PlayerReplicationInfo = Player.PlayerReplicationInfo;
	Player.bBehindView = false;
	switch(Pawn.m_eHealth)
	{
		// End:0x87
		case 0:
			Player.PlayerReplicationInfo.m_iHealth = 0;
			// End:0xD2
			break;
		// End:0xA8
		case 1:
			Player.PlayerReplicationInfo.m_iHealth = 1;
			// End:0xD2
			break;
		// End:0xAD
		case 2:
		// End:0xCF
		case 3:
			Player.PlayerReplicationInfo.m_iHealth = 2;
			// End:0xD2
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

//------------------------------------------------------------------//
// SwapPlayerControlWithTeamMate()							
//------------------------------------------------------------------//
function SwapPlayerControlWithTeamMate(int iMember)
{
	local R6Rainbow tempPawn;
	local R6RainbowAI tempRainbowAI;
	local R6PlayerController tempPlayerController;
	local int i, iPermanentRequestID;

	// End:0x3A
	if(__NFUN_130__(__NFUN_119__(Level.Game, none), __NFUN_129__(R6AbstractGameInfo(Level.Game).CanSwitchTeamMember())))
	{
		return;
	}
	// End:0x63
	if(__NFUN_132__(__NFUN_154__(iMember, 0), __NFUN_129__(m_Team[iMember].IsAlive())))
	{
		return;
	}
	// End:0xD8
	if(__NFUN_129__(m_Team[0].IsAlive()))
	{
		iPermanentRequestID = m_Team[iMember].m_iPermanentID;
		i = 0;
		J0x9A:

		// End:0xD6 [Loop If]
		if(__NFUN_150__(i, m_iMemberCount))
		{
			SwitchPlayerControlToNextMember();
			// End:0xCC
			if(__NFUN_154__(m_Team[0].m_iPermanentID, iPermanentRequestID))
			{
				// [Explicit Break]
				goto J0xD6;
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x9A;
		}
		J0xD6:

		return;
	}
	TeamIsSeparatedFromLead(false);
	tempPawn = m_Team[0];
	m_Team[0] = m_Team[iMember];
	m_Team[0].m_iID = 0;
	m_TeamLeader = m_Team[0];
	m_Team[iMember] = tempPawn;
	m_Team[iMember].m_iID = iMember;
	m_TeamLeader.m_bIsPlayer = true;
	m_Team[iMember].m_bIsPlayer = false;
	m_Team[iMember].ClientQuickResetPeeking();
	tempPawn = m_Team[iMember];
	// End:0x1BA
	if(__NFUN_242__(tempPawn.m_bIsClimbingLadder, false))
	{
		UpdatePlayerWeapon(tempPawn);		
	}
	else
	{
		// End:0x1DE
		if(__NFUN_242__(tempPawn.m_bActivateNightVision, true))
		{
			tempPawn.ToggleNightVision();
		}
	}
	ResetWeaponReloading();
	tempRainbowAI = R6RainbowAI(m_Team[0].Controller);
	tempPlayerController = R6PlayerController(m_Team[iMember].Controller);
	tempPlayerController.ToggleHelmetCameraZoom(true);
	tempPlayerController.CancelShake();
	tempPlayerController.ClientForceUnlockWeapon();
	tempPlayerController.m_iPlayerCAProgress = 0;
	SwitchControllerRepInfo(tempRainbowAI, tempPlayerController);
	m_Team[iMember].UnPossessed();
	tempRainbowAI.Possess(m_Team[iMember]);
	AssociatePlayerAndPawn(tempPlayerController, m_Team[0]);
	m_Team[iMember].__NFUN_2214__(rot(0, 0, 0));
	m_Team[iMember].ResetBoneRotation();
	m_Team[iMember].m_bPostureTransition = false;
	m_TeamLeader.ResetBoneRotation();
	m_TeamLeader.ClientQuickResetPeeking();
	m_TeamLeader.m_bPostureTransition = false;
	UpdateFirstPersonWeaponMemory(tempPawn, m_TeamLeader);
	ResetRainbowControllerStates(tempPlayerController, iMember);
	m_iIntermLeader = 0;
	tempPlayerController.UpdatePlayerPostureAfterSwitch();
	UpdateEscortList();
	UpdateTeamGrenadeStatus();
	return;
}

//------------------------------------------------------------------//
// UpdateTeamStatus()												//
//   called from R6TakeDamage() in R6Pawn.uc whenever a member of   //
//   the team takes damage.											//
//------------------------------------------------------------------//
function UpdateTeamStatus(R6Pawn member)
{
	local R6PlayerController _playerController;

	// End:0x9D
	if(__NFUN_129__(__NFUN_122__(Level.Game.m_szGameTypeFlag, "RGM_FreeBackupAdvMode")))
	{
		// End:0x9D
		if(__NFUN_130__(__NFUN_154__(m_iTeamHealth[member.m_iPermanentID], int(member.2)), __NFUN_154__(int(member.m_eHealth), int(3))))
		{
			m_iTeamHealth[member.m_iPermanentID] = int(member.m_eHealth);
			return;
		}
	}
	// End:0x190
	if(__NFUN_129__(member.IsAlive()))
	{
		_playerController = R6PlayerController(m_TeamLeader.Controller);
		// End:0x10D
		if(__NFUN_129__(__NFUN_122__(Level.Game.m_szGameTypeFlag, "RGM_FreeBackupAdvMode")))
		{
			TeamMemberDead(member);			
		}
		else
		{
			TeamMemberDeadInFreeBackup(member);
		}
		// End:0x158
		if(__NFUN_130__(__NFUN_130__(__NFUN_154__(m_iMemberCount, 0), m_bLeaderIsAPlayer), __NFUN_155__(int(Level.NetMode), int(NM_Standalone))))
		{
			_playerController.ClientTeamIsDead();
		}
		// End:0x190
		if(__NFUN_132__(__NFUN_130__(m_bLeaderIsAPlayer, __NFUN_154__(m_iMemberCount, 1)), __NFUN_130__(__NFUN_129__(m_bLeaderIsAPlayer), __NFUN_154__(m_iMemberCount, 0))))
		{
			SetTeamState(21);
		}
	}
	// End:0x29A
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_129__(member.m_bIsPlayer), __NFUN_155__(m_iTeamAction, 512)), __NFUN_154__(m_iTeamHealth[member.m_iPermanentID], int(member.0))), __NFUN_154__(int(member.m_eHealth), int(1))))
	{
		// End:0x29A
		if(__NFUN_130__(__NFUN_151__(m_iMemberCount, __NFUN_146__(member.m_iID, 1)), __NFUN_154__(int(m_Team[__NFUN_146__(member.m_iID, 1)].m_eHealth), int(0))))
		{
			// End:0x29A
			if(SendMemberToEnd(member.m_iID, true))
			{
				ResetTeamMemberStates();
				// End:0x29A
				if(__NFUN_130__(m_bTeamIsHoldingPosition, __NFUN_129__(m_Team[0].m_bIsPlayer)))
				{
					m_Team[0].Controller.__NFUN_113__('HoldPosition');
				}
			}
		}
	}
	m_iTeamHealth[member.m_iPermanentID] = int(member.m_eHealth);
	return;
}

function bool RainbowAIAreStillClimbingLadder()
{
	local int i;

	i = 1;
	J0x07:

	// End:0x54 [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		// End:0x4A
		if(__NFUN_130__(m_Team[i].IsAlive(), m_Team[i].m_bIsClimbingLadder))
		{
			return true;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

//------------------------------------------------------------------//
// TeamMemberDead()													//
//   called when a member of the team is killed                     //
//  note: this is called even when a member is only incapacitated...//
//------------------------------------------------------------------//
function TeamMemberDead(R6Pawn DeadPawn)
{
	local int i, iMemberId;
	local bool bReIssueTeamOrder, bReassignNextMemberToLeadRoomEntry;
	local int iIdxDeadPawn;

	UpdateEscortList();
	UpdateTeamGrenadeStatus();
	iMemberId = DeadPawn.m_iID;
	DeadPawn.Controller.Enemy = none;
	// End:0x6A
	if(__NFUN_154__(iMemberId, 0))
	{
		m_TeamLeader = m_Team[1];
		// End:0x6A
		if(m_bLeaderIsAPlayer)
		{
			__NFUN_166__(m_iMemberCount);
			__NFUN_165__(m_iMembersLost);
			return;
		}
	}
	// End:0xC6
	if(__NFUN_155__(m_iTeamAction, 0))
	{
		// End:0x9F
		if(__NFUN_154__(iMemberId, 1))
		{
			bReIssueTeamOrder = true;
			// End:0x9F
			if(__NFUN_114__(m_PawnControllingDoor, DeadPawn))
			{
				bReassignNextMemberToLeadRoomEntry = true;
			}
		}
		// End:0xC6
		if(__NFUN_154__(m_iTeamAction, 512))
		{
			// End:0xC6
			if(__NFUN_154__(iMemberId, __NFUN_147__(m_iMemberCount, 1)))
			{
				TeamFinishedClimbingLadder();
			}
		}
	}
	// End:0xD9
	if(__NFUN_129__(RainbowAIAreStillClimbingLadder()))
	{
		m_bTeamIsClimbingLadder = false;
	}
	i = __NFUN_146__(iMemberId, 1);
	J0xE7:

	// End:0x176 [Loop If]
	if(__NFUN_150__(i, __NFUN_146__(m_iMemberCount, m_iMembersLost)))
	{
		// End:0x16C
		if(m_Team[i].IsAlive())
		{
			m_Team[__NFUN_147__(i, 1)] = m_Team[i];
			// End:0x16C
			if(__NFUN_119__(m_Team[i].Controller, none))
			{
				R6RainbowAI(m_Team[i].Controller).Promote();
			}
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xE7;
	}
	// End:0x1BB
	if(__NFUN_130__(__NFUN_130__(m_bLeaderIsAPlayer, m_Team[0].m_bIsPlayer), __NFUN_129__(m_Team[0].IsAlive())))
	{
		iIdxDeadPawn = m_iMemberCount;		
	}
	else
	{
		iIdxDeadPawn = __NFUN_147__(m_iMemberCount, 1);
	}
	m_Team[iIdxDeadPawn] = R6Rainbow(DeadPawn);
	DeadPawn.m_iID = iIdxDeadPawn;
	// End:0x240
	if(__NFUN_130__(__NFUN_130__(__NFUN_129__(m_bLeaderIsAPlayer), __NFUN_119__(m_TeamLeader, none)), __NFUN_119__(m_TeamLeader.Controller, none)))
	{
		R6RainbowAI(m_TeamLeader.Controller).m_bTeamMateHasBeenKilled = true;
	}
	__NFUN_166__(m_iMemberCount);
	__NFUN_165__(m_iMembersLost);
	// End:0x2AB
	if(__NFUN_130__(bReIssueTeamOrder, __NFUN_151__(m_iMemberCount, 1)))
	{
		// End:0x28F
		if(m_bTeamIsClimbingLadder)
		{
			m_Team[1].Controller.NextState = 'TeamClimbEndNoLeader';			
		}
		else
		{
			ReIssueTeamOrders();
		}
		// End:0x2AB
		if(bReassignNextMemberToLeadRoomEntry)
		{
			m_PawnControllingDoor = m_Team[1];
		}
	}
	return;
}

// NEW IN 1.60
function TeamMemberDeadInFreeBackup(R6Pawn DeadPawn)
{
	local int i, iMemberId;

	iMemberId = DeadPawn.m_iID;
	DeadPawn.Controller.Enemy = none;
	// End:0xD5
	if(__NFUN_154__(iMemberId, 0))
	{
		m_TeamLeader = none;
		i = 1;
		J0x46:

		// End:0xCC [Loop If]
		if(__NFUN_150__(i, m_iMemberCount))
		{
			// End:0xC2
			if(__NFUN_119__(m_Team[i], none))
			{
				// End:0xC2
				if(__NFUN_119__(m_Team[i].Controller, none))
				{
					m_Team[i].Controller.Enemy = none;
					R6RainbowAI(m_Team[i].Controller).FreeBackupPromote();
				}
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x46;
		}
		m_iMemberCount = 0;
		return;
	}
	// End:0xE8
	if(__NFUN_129__(RainbowAIAreStillClimbingLadder()))
	{
		m_bTeamIsClimbingLadder = false;
	}
	switch(m_Team[iMemberId].m_iID)
	{
		// End:0x1BE
		case 1:
			// End:0x1BB
			if(__NFUN_119__(m_Team[2], none))
			{
				m_Team[1] = m_Team[2];
				m_Team[1].m_iID = 1;
				R6RainbowAI(m_Team[1].Controller).FreeBackupPromote();
				// End:0x1B1
				if(__NFUN_119__(m_Team[3], none))
				{
					m_Team[2] = m_Team[3];
					m_Team[2].m_iID = 2;
					R6RainbowAI(m_Team[2].Controller).FreeBackupPromote();
					m_Team[3] = none;					
				}
				else
				{
					m_Team[2] = none;
				}
			}
			// End:0x238
			break;
		// End:0x223
		case 2:
			// End:0x220
			if(__NFUN_119__(m_Team[3], none))
			{
				m_Team[2] = m_Team[3];
				m_Team[2].m_iID = 2;
				R6RainbowAI(m_Team[2].Controller).FreeBackupPromote();
				m_Team[3] = none;
			}
			// End:0x238
			break;
		// End:0x235
		case 3:
			m_Team[3] = none;
			// End:0x238
			break;
		// End:0xFFFF
		default:
			break;
	}
	__NFUN_166__(m_iMemberCount);
	ResetNeutralFighterTeam();
	return;
}

// NEW IN 1.60
function ResetNeutralFighterTeam()
{
	// End:0x0D
	if(__NFUN_152__(m_iMemberCount, 1))
	{
		return;
	}
	switch(m_iMemberCount)
	{
		// End:0x51
		case 2:
			// End:0x4E
			if(__NFUN_130__(__NFUN_119__(m_Team[1], none), __NFUN_129__(m_Team[1].IsAlive())))
			{
				m_Team[1] = none;
				m_iMemberCount = 1;
			}
			// End:0x358
			break;
		// End:0x130
		case 3:
			// End:0xF4
			if(__NFUN_130__(__NFUN_119__(m_Team[1], none), __NFUN_129__(m_Team[1].IsAlive())))
			{
				// End:0xD7
				if(__NFUN_130__(__NFUN_119__(m_Team[2], none), m_Team[2].IsAlive()))
				{
					m_Team[1] = m_Team[2];
					m_Team[1].m_iID = 1;
					m_Team[2] = none;
					m_iMemberCount = 2;					
				}
				else
				{
					m_Team[1] = none;
					m_Team[2] = none;
					m_iMemberCount = 1;
				}				
			}
			else
			{
				// End:0x12D
				if(__NFUN_130__(__NFUN_119__(m_Team[2], none), __NFUN_129__(m_Team[2].IsAlive())))
				{
					m_Team[2] = none;
					m_iMemberCount = 2;
				}
			}
			// End:0x358
			break;
		// End:0x355
		case 4:
			// End:0x239
			if(__NFUN_130__(__NFUN_119__(m_Team[1], none), m_Team[1].IsAlive()))
			{
				// End:0x1FD
				if(__NFUN_130__(__NFUN_119__(m_Team[2], none), __NFUN_129__(m_Team[2].IsAlive())))
				{
					// End:0x1DE
					if(__NFUN_130__(__NFUN_119__(m_Team[3], none), m_Team[3].IsAlive()))
					{
						m_Team[2] = m_Team[3];
						m_Team[2].m_iID = 2;
						m_Team[3] = none;
						m_iMemberCount = 3;						
					}
					else
					{
						m_Team[2] = none;
						m_Team[3] = none;
						m_iMemberCount = 2;
					}					
				}
				else
				{
					// End:0x236
					if(__NFUN_130__(__NFUN_119__(m_Team[3], none), __NFUN_129__(m_Team[3].IsAlive())))
					{
						m_Team[3] = none;
						m_iMemberCount = 3;
					}
				}				
			}
			else
			{
				// End:0x2ED
				if(__NFUN_130__(__NFUN_119__(m_Team[2], none), __NFUN_129__(m_Team[2].IsAlive())))
				{
					// End:0x2C6
					if(__NFUN_130__(__NFUN_119__(m_Team[3], none), m_Team[3].IsAlive()))
					{
						m_Team[1] = m_Team[3];
						m_Team[1].m_iID = 1;
						m_Team[2] = none;
						m_Team[3] = none;
						m_iMemberCount = 2;						
					}
					else
					{
						m_Team[1] = none;
						m_Team[2] = none;
						m_Team[3] = none;
						m_iMemberCount = 1;
					}					
				}
				else
				{
					// End:0x352
					if(__NFUN_130__(__NFUN_119__(m_Team[3], none), __NFUN_129__(m_Team[3].IsAlive())))
					{
						m_Team[1] = m_Team[2];
						m_Team[1].m_iID = 1;
						m_Team[2] = none;
						m_Team[3] = none;
						m_iMemberCount = 2;
					}
				}
			}
			// End:0x358
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

//------------------------------------------------------------------//
// AtLeastOneMemberIsWounded()										//
//  used by an AI led team; AI lead should walk if any of the		//
//  members are wounded or if any of the hostages being escorted	//
//  are wounded.													//
//------------------------------------------------------------------//
function bool AtLeastOneMemberIsWounded()
{
	local int i;

	// End:0x0B
	if(m_bWoundedHostage)
	{
		return true;
	}
	i = 0;
	J0x12:

	// End:0x4C [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		// End:0x42
		if(__NFUN_154__(int(m_Team[i].m_eHealth), int(1)))
		{
			return true;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x12;
	}
	return false;
	return;
}

//------------------------------------------------------------------//
// SetFormation()													//
//   TODO : this function may have become unnecessary               //
//------------------------------------------------------------------//
function SetFormation(R6RainbowAI memberAI)
{
	memberAI.m_eFormation = m_eFormation;
	return;
}

//------------------------------------------------------------------//
// UpdateTeamFormation()											//
//   inform all the team members of the change in formation         //
//------------------------------------------------------------------//
event UpdateTeamFormation(R6RainbowAI.eFormation eFormation)
{
	local int i, iStart;

	m_eFormation = eFormation;
	// End:0x1B
	if(m_bLeaderIsAPlayer)
	{
		iStart = 1;
	}
	i = iStart;
	J0x26:

	// End:0x5E [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		SetFormation(R6RainbowAI(m_Team[i].Controller));
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x26;
	}
	return;
}

//------------------------------------------------------------------//
// RequestFormationChange()											//
//   two requests by team members are necessary before the          //
//   current formation will be changed...                           //
//------------------------------------------------------------------//
event RequestFormationChange(R6RainbowAI.eFormation eFormation)
{
	// End:0x21
	if(__NFUN_154__(int(m_eRequestedFormation), int(eFormation)))
	{
		UpdateTeamFormation(eFormation);		
	}
	else
	{
		m_eRequestedFormation = eFormation;
	}
	return;
}

//------------------------------------------------------------------//
// Tick()															//
//   keep this function's content to an absolute minimun since it   //
//   called so frequently...                                        //
//------------------------------------------------------------------//
function Tick(float fDelta)
{
	local int i;

	// End:0x47
	if(__NFUN_130__(__NFUN_129__(m_bTeamIsEngagingEnemy), __NFUN_154__(int(m_eTeamState), int(6))))
	{
		// End:0x47
		if(__NFUN_177__(__NFUN_175__(Level.TimeSeconds, m_fEngagingTimer), 1.0000000))
		{
			m_eTeamState = m_eBackupTeamState;
		}
	}
	// End:0x260
	if(__NFUN_119__(m_TeamLeader, none))
	{
		// End:0x81
		if(__NFUN_177__(__NFUN_225__(m_TeamLeader.Velocity), float(5)))
		{
			m_rTeamDirection = Rotator(m_TeamLeader.Velocity);
		}
		// End:0x255
		if(m_bLeaderIsAPlayer)
		{
			// End:0x1A9
			if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
			{
				// End:0x177
				if(__NFUN_119__(m_PlanActionPoint, none))
				{
					// End:0x131
					if(__NFUN_176__(__NFUN_225__(__NFUN_216__(m_TeamLeader.Location, m_PlanActionPoint.Location)), float(250)))
					{
						m_PlayerLastActionPoint = m_PlanActionPoint;
						ActionPointReached();
						m_ePlayerAPAction = m_ePlanAction;
						// End:0x11C
						if(__NFUN_154__(int(m_eGoCode), int(4)))
						{
							// End:0x119
							if(__NFUN_155__(int(m_ePlanAction), int(0)))
							{
								ActionNodeCompleted();
							}							
						}
						else
						{
							m_ePlayerAPAction = m_TeamPlanning.GetAction();
						}
					}
					// End:0x174
					if(__NFUN_130__(__NFUN_155__(int(m_ePlayerAPAction), int(0)), __NFUN_177__(__NFUN_225__(__NFUN_216__(m_TeamLeader.Location, m_PlayerLastActionPoint.Location)), float(250))))
					{
						m_ePlayerAPAction = 0;
					}					
				}
				else
				{
					// End:0x1A9
					if(__NFUN_154__(int(m_eGoCode), int(4)))
					{
						GetNextActionPoint();
						// End:0x1A9
						if(__NFUN_119__(m_PlanActionPoint, none))
						{
							m_ePlayerAPAction = m_ePlanAction;
							ActionNodeCompleted();
						}
					}
				}
			}
			// End:0x1CF
			if(m_TeamLeader.m_bIsProne)
			{
				m_TeamLeader.m_eMovementPace = 1;				
			}
			else
			{
				// End:0x21B
				if(m_TeamLeader.bIsCrouched)
				{
					// End:0x207
					if(m_TeamLeader.bIsWalking)
					{
						m_TeamLeader.m_eMovementPace = 2;						
					}
					else
					{
						m_TeamLeader.m_eMovementPace = 3;
					}					
				}
				else
				{
					// End:0x241
					if(m_TeamLeader.bIsWalking)
					{
						m_TeamLeader.m_eMovementPace = 4;						
					}
					else
					{
						m_TeamLeader.m_eMovementPace = 5;
					}
				}
			}			
		}
		else
		{
			m_ePlayerAPAction = m_ePlanAction;
		}
	}
	return;
}

//------------------------------------------------------------------//
//  PickMemberClosestTo()											//
//------------------------------------------------------------------//
function int PickMemberClosestTo(Actor aNoiseSource)
{
	local int i, iMemberClosest, fDist, fClosestDist;

	iMemberClosest = -1;
	fClosestDist = 10000;
	// End:0x35
	if(__NFUN_154__(m_iMemberCount, 1))
	{
		// End:0x33
		if(m_bLeaderIsAPlayer)
		{
			return iMemberClosest;			
		}
		else
		{
			return 0;
		}
	}
	i = 1;
	J0x3C:

	// End:0xC3 [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		// End:0x66
		if(m_Team[i].m_bIsPlayer)
		{
			// [Explicit Continue]
			goto J0xB9;
		}
		fDist = int(__NFUN_225__(__NFUN_216__(m_Team[i].Location, aNoiseSource.Location)));
		// End:0xB9
		if(__NFUN_150__(fDist, fClosestDist))
		{
			iMemberClosest = i;
			fClosestDist = fDist;
		}
		J0xB9:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x3C;
	}
	return iMemberClosest;
	return;
}

//------------------------------------------------------------------//
// TeamHearNoise()													//
//------------------------------------------------------------------//
function TeamHearNoise(Actor aNoiseMaker)
{
	local int iMember;

	m_vNoiseSource = aNoiseMaker.Location;
	// End:0x2D
	if(m_bLeaderIsAPlayer)
	{
		// End:0x2A
		if(__NFUN_154__(m_iMemberCount, 1))
		{
			return;
		}		
	}
	else
	{
		// End:0x7D
		if(__NFUN_154__(m_iMemberCount, 1))
		{
			// End:0x7D
			if(m_Team[0].Controller.__NFUN_281__('SnipeUntilGoCode'))
			{
				R6RainbowAI(m_Team[0].Controller).SetNoiseFocus(m_vNoiseSource);
				return;
			}
		}
	}
	iMember = PickMemberClosestTo(aNoiseMaker);
	// End:0x9B
	if(__NFUN_150__(iMember, 0))
	{
		return;
	}
	R6RainbowAI(m_Team[iMember].Controller).SetNoiseFocus(m_vNoiseSource);
	return;
}

//------------------------------------------------------------------//
//  TeamSpottedSurrenderedTerrorist()								//
//------------------------------------------------------------------//
function TeamSpottedSurrenderedTerrorist(R6Pawn terrorist)
{
	// End:0x14
	if(m_TeamLeader.m_bIsPlayer)
	{
		return;
	}
	// End:0x38
	if(__NFUN_129__(R6Terrorist(terrorist).m_bIsUnderArrest))
	{
		m_SurrenderedTerrorist = terrorist;
	}
	return;
}

//------------------------------------------------------------------//
//  RainbowIsEngaging()								
//------------------------------------------------------------------//
function bool RainbowIsEngaging()
{
	local int i;

	i = 1;
	J0x07:

	// End:0x45 [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		// End:0x3B
		if(__NFUN_119__(m_Team[i].Controller.Enemy, none))
		{
			return true;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

//------------------------------------------------------------------//
//  EngageEnemyIfNotAlreadyEngaged()								//
//------------------------------------------------------------------//
function bool EngageEnemyIfNotAlreadyEngaged(R6Pawn Rainbow, R6Pawn Enemy)
{
	local bool bFound;
	local int i;

	// End:0x1A
	if(__NFUN_132__(__NFUN_114__(Enemy, none), __NFUN_154__(m_iMemberCount, 0)))
	{
		return false;
	}
	i = 0;
	J0x21:

	// End:0x9A [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		// End:0x62
		if(__NFUN_132__(m_Team[i].m_bIsPlayer, __NFUN_114__(m_Team[i], Rainbow)))
		{
			// [Explicit Continue]
			goto J0x90;
		}
		// End:0x90
		if(__NFUN_114__(R6RainbowAI(m_Team[i].Controller).Enemy, Enemy))
		{
			return false;
		}
		J0x90:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x21;
	}
	// End:0x151
	if(__NFUN_130__(__NFUN_132__(m_TeamLeader.m_bIsPlayer, m_bPlayerHasFocus), __NFUN_129__(R6Terrorist(Enemy).m_bEnteringView)))
	{
		R6Terrorist(Enemy).m_bEnteringView = true;
		// End:0x13B
		if(__NFUN_130__(__NFUN_114__(m_Team[__NFUN_147__(m_iMemberCount, 1)], Rainbow), R6RainbowAI(Rainbow.Controller).m_bIsMovingBackwards))
		{
			m_MemberVoicesMgr.PlayRainbowMemberVoices(Rainbow, 3);			
		}
		else
		{
			m_MemberVoicesMgr.PlayRainbowMemberVoices(Rainbow, 2);
		}
	}
	return true;
	return;
}

//------------------------------------------------------------------//
//  DisEngaged()													//
//------------------------------------------------------------------//
function DisEngageEnemy(Pawn Rainbow, Pawn Enemy)
{
	CheckTeamEngagingStatus(Rainbow);
	return;
}

function RainbowIsEngagingEnemy()
{
	m_bTeamIsEngagingEnemy = true;
	// End:0x2B
	if(__NFUN_155__(int(m_eTeamState), int(6)))
	{
		m_eBackupTeamState = m_eTeamState;
		SetTeamState(6);
	}
	return;
}

function CheckTeamEngagingStatus(optional Pawn rainbowToIgnore)
{
	local bool bRainbowAreStillEngaging;
	local int i;

	i = 0;
	J0x07:

	// End:0xA6 [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		// End:0x48
		if(__NFUN_132__(m_Team[i].m_bIsPlayer, __NFUN_114__(m_Team[i], rainbowToIgnore)))
		{
			// [Explicit Continue]
			goto J0x9C;
		}
		// End:0x9C
		if(__NFUN_130__(__NFUN_119__(m_Team[i].Controller.Enemy, none), __NFUN_129__(__NFUN_130__(m_Team[i].m_bIsSniping, m_bSniperHold))))
		{
			m_bTeamIsEngagingEnemy = true;
			return;
		}
		J0x9C:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	// End:0xCB
	if(m_bTeamIsEngagingEnemy)
	{
		m_bTeamIsEngagingEnemy = false;
		m_fEngagingTimer = Level.TimeSeconds;
	}
	return;
}

//------------------------------------------------------------------//
//  AITeamHoldPosition()											//
//------------------------------------------------------------------//
function AITeamHoldPosition()
{
	local int iMember;

	// End:0x2A
	if(__NFUN_132__(m_bPlayerHasFocus, m_bPlayerInGhostMode))
	{
		m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 3);
	}
	// End:0x4D
	if(__NFUN_132__(__NFUN_132__(m_bLeaderIsAPlayer, __NFUN_154__(m_iMemberCount, 0)), m_bTeamIsClimbingLadder))
	{
		return;
	}
	// End:0x5C
	if(m_bCAWaitingForZuluGoCode)
	{
		ResetZuluGoCode();
	}
	m_bTeamIsHoldingPosition = true;
	// End:0xB6
	if(__NFUN_132__(__NFUN_132__(m_TeamLeader.m_bIsSniping, m_TeamLeader.Controller.__NFUN_281__('PlaceBreachingCharge')), m_TeamLeader.Controller.__NFUN_281__('DetonateBreachingCharge')))
	{
		return;
	}
	iMember = 0;
	J0xBD:

	// End:0x118 [Loop If]
	if(__NFUN_150__(iMember, m_iMemberCount))
	{
		m_Team[iMember].Controller.NextState = 'None';
		m_Team[iMember].Controller.__NFUN_113__('HoldPosition');
		__NFUN_165__(iMember);
		// [Loop Continue]
		goto J0xBD;
	}
	return;
}

//------------------------------------------------------------------//
//  AITeamFollowPlanning()											//
//------------------------------------------------------------------//
function AITeamFollowPlanning()
{
	local int iMember;

	// End:0x2A
	if(__NFUN_132__(m_bPlayerHasFocus, m_bPlayerInGhostMode))
	{
		m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamLeader, 4);
	}
	// End:0x4D
	if(__NFUN_132__(__NFUN_132__(m_bLeaderIsAPlayer, __NFUN_154__(m_iMemberCount, 0)), m_bTeamIsClimbingLadder))
	{
		return;
	}
	m_bTeamIsHoldingPosition = false;
	// End:0xA7
	if(__NFUN_132__(__NFUN_132__(m_TeamLeader.m_bIsSniping, m_TeamLeader.Controller.__NFUN_281__('PlaceBreachingCharge')), m_TeamLeader.Controller.__NFUN_281__('DetonateBreachingCharge')))
	{
		return;
	}
	m_TeamLeader.Controller.__NFUN_113__('Patrol');
	iMember = 1;
	J0xC7:

	// End:0x122 [Loop If]
	if(__NFUN_150__(iMember, m_iMemberCount))
	{
		m_Team[iMember].Controller.__NFUN_113__('FollowLeader');
		R6RainbowAI(m_Team[iMember].Controller).ResetStateProgress();
		__NFUN_165__(iMember);
		// [Loop Continue]
		goto J0xC7;
	}
	return;
}

//------------------------------------------------------------------//
//  SendMemberToEnd()												//
//------------------------------------------------------------------//
function bool SendMemberToEnd(int iMember, optional bool bReorganizeWounded)
{
	local int i;
	local R6Rainbow Rainbow;
	local R6RainbowAI rainbowAI;

	Rainbow = m_Team[iMember];
	rainbowAI = R6RainbowAI(Rainbow.Controller);
	// End:0xD0
	if(bReorganizeWounded)
	{
		// End:0xBF
		if(__NFUN_130__(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_155__(m_iTeamAction, 0), m_bTeamIsClimbingLadder), Rainbow.m_bIsSniping), Rainbow.m_bInteractingWithDevice), m_bEntryInProgress), __NFUN_154__(int(m_eTeamState), int(6))), __NFUN_154__(int(Rainbow.m_eHealth), int(1))))
		{
			rainbowAI.m_bReorganizationPending = true;
			return false;			
		}
		else
		{
			rainbowAI.m_bReorganizationPending = false;
		}
	}
	i = iMember;
	J0xDB:

	// End:0x12B [Loop If]
	if(__NFUN_150__(i, __NFUN_147__(m_iMemberCount, 1)))
	{
		m_Team[i] = m_Team[__NFUN_146__(i, 1)];
		m_Team[i].m_iID = i;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xDB;
	}
	m_Team[i] = Rainbow;
	m_Team[i].m_iID = i;
	return true;
	return;
}

//------------------------------------------------------------------//
//  AssignNewTeamLeader()			
//------------------------------------------------------------------//
function AssignNewTeamLeader(int iNewLeader)
{
	ReOrganizeTeam(iNewLeader);
	m_iIntermLeader = 0;
	return;
}

//------------------------------------------------------------------//
//  ReOrganizeTeam()												//
//------------------------------------------------------------------//
function ReOrganizeTeam(int iNewLeader)
{
	local int i;

	// End:0x0D
	if(__NFUN_154__(m_iMemberCount, 1))
	{
		return;
	}
	// End:0x4E
	if(m_bLeaderIsAPlayer)
	{
		// End:0x24
		if(__NFUN_154__(m_iMemberCount, 2))
		{
			return;
		}
		i = 1;
		J0x2B:

		// End:0x4B [Loop If]
		if(__NFUN_150__(i, iNewLeader))
		{
			SendMemberToEnd(1);
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x2B;
		}		
	}
	else
	{
		// End:0x5B
		if(__NFUN_154__(m_iMemberCount, 1))
		{
			return;
		}
		i = 0;
		J0x62:

		// End:0x82 [Loop If]
		if(__NFUN_150__(i, iNewLeader))
		{
			SendMemberToEnd(0);
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x62;
		}
		ResetTeamMemberStates();
	}
	m_iIntermLeader = iNewLeader;
	Escort_ManageList();
	return;
}

//------------------------------------------------------------------
//  ResetTeamMemberStates()												
//------------------------------------------------------------------
function ResetTeamMemberStates()
{
	local int i;

	// End:0x0B
	if(m_bLeaderIsAPlayer)
	{
		return;
	}
	m_TeamLeader = m_Team[0];
	// End:0x25
	if(__NFUN_114__(m_TeamLeader, none))
	{
		return;
	}
	i = 0;
	J0x2C:

	// End:0xD9 [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		// End:0x88
		if(__NFUN_154__(i, 0))
		{
			R6RainbowAI(m_Team[0].Controller).m_TeamLeader = none;
			m_Team[i].Controller.__NFUN_113__('Patrol');
			// [Explicit Continue]
			goto J0xCF;
		}
		R6RainbowAI(m_Team[i].Controller).m_TeamLeader = m_TeamLeader;
		m_Team[i].Controller.__NFUN_113__('FollowLeader');
		J0xCF:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x2C;
	}
	return;
}

//------------------------------------------------------------------
//  RestoreTeamOrder()												
//------------------------------------------------------------------
function RestoreTeamOrder()
{
	local int i;

	// End:0x0B
	if(m_bCAWaitingForZuluGoCode)
	{
		return;
	}
	// End:0x18
	if(__NFUN_154__(m_iIntermLeader, 0))
	{
		return;
	}
	// End:0x6D
	if(m_bLeaderIsAPlayer)
	{
		// End:0x3C
		if(__NFUN_132__(__NFUN_154__(m_iMemberCount, 2), __NFUN_154__(m_iIntermLeader, 1)))
		{
			return;
		}
		i = 1;
		J0x43:

		// End:0x6A [Loop If]
		if(__NFUN_152__(i, __NFUN_147__(m_iMemberCount, m_iIntermLeader)))
		{
			SendMemberToEnd(1);
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x43;
		}		
	}
	else
	{
		// End:0x7A
		if(__NFUN_154__(m_iMemberCount, 1))
		{
			return;
		}
		i = 0;
		J0x81:

		// End:0xA8 [Loop If]
		if(__NFUN_150__(i, __NFUN_147__(m_iMemberCount, m_iIntermLeader)))
		{
			SendMemberToEnd(0);
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x81;
		}
		ReOrganizeWoundedMembers();
		ResetTeamMemberStates();
	}
	m_iIntermLeader = 0;
	Escort_ManageList();
	return;
}

function ReOrganizeWoundedMembers()
{
	local int i;
	local bool bReOrganized;

	i = 0;
	J0x07:

	// End:0xD1 [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		// End:0x31
		if(m_Team[i].m_bIsPlayer)
		{
			// [Explicit Continue]
			goto J0xC7;
		}
		// End:0xA2
		if(__NFUN_130__(__NFUN_130__(__NFUN_150__(i, __NFUN_147__(m_iMemberCount, 1)), __NFUN_154__(int(m_Team[i].m_eHealth), int(1))), __NFUN_154__(int(m_Team[__NFUN_146__(i, 1)].m_eHealth), int(0))))
		{
			// End:0x9F
			if(SendMemberToEnd(i, true))
			{
				bReOrganized = true;
			}
			// [Explicit Continue]
			goto J0xC7;
		}
		R6RainbowAI(m_Team[i].Controller).m_bReorganizationPending = false;
		J0xC7:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	// End:0xE0
	if(bReOrganized)
	{
		ResetTeamMemberStates();
	}
	return;
}

//------------------------------------------------------------------//
// FindRainbowWithBreachingCharge()									//
//------------------------------------------------------------------//
function R6Rainbow FindRainbowWithBreachingCharge()
{
	local int iMember, iWeaponGroup;
	local R6AbstractWeapon demolitionsWeapon;

	iMember = 0;
	J0x07:

	// End:0x5B [Loop If]
	if(__NFUN_150__(iMember, m_iMemberCount))
	{
		// End:0x31
		if(m_Team[iMember].m_bIsPlayer)
		{
			// [Explicit Continue]
			goto J0x51;
		}
		// End:0x51
		if(HasBreachingCharge(m_Team[iMember]))
		{
			return m_Team[iMember];
		}
		J0x51:

		__NFUN_165__(iMember);
		// [Loop Continue]
		goto J0x07;
	}
	return none;
	return;
}

//------------------------------------------------------------------//
//  HasBreachingCharge												//
//------------------------------------------------------------------//
function bool HasBreachingCharge(R6Rainbow Rainbow)
{
	local int iWeaponGroup;
	local R6EngineWeapon demolitionsWeapon;

	iWeaponGroup = 3;
	J0x08:

	// End:0x91 [Loop If]
	if(__NFUN_152__(iWeaponGroup, 4))
	{
		demolitionsWeapon = Rainbow.GetWeaponInGroup(iWeaponGroup);
		// End:0x87
		if(__NFUN_130__(__NFUN_130__(__NFUN_119__(demolitionsWeapon, none), demolitionsWeapon.__NFUN_303__('R6BreachingChargeGadget')), demolitionsWeapon.HasAmmo()))
		{
			R6RainbowAI(Rainbow.Controller).m_iActionUseGadgetGroup = iWeaponGroup;
			return true;
		}
		__NFUN_165__(iWeaponGroup);
		// [Loop Continue]
		goto J0x08;
	}
	return false;
	return;
}

//------------------------------------------------------------------//
//  ReOrganizeTeamForBreachDoor										//
//   for AI led team only									        //
//------------------------------------------------------------------//
function ReOrganizeTeamForBreachDoor()
{
	local R6Rainbow actionMember;
	local int i;

	m_BreachingDoor = R6IORotatingDoor(m_TeamPlanning.GetNextDoorToBreach(m_PlanActionPoint));
	// End:0x47
	if(__NFUN_132__(HasBreachingCharge(m_Team[0]), __NFUN_129__(m_BreachingDoor.ShouldBeBreached())))
	{
		return;
	}
	actionMember = FindRainbowWithBreachingCharge();
	// End:0x60
	if(__NFUN_114__(actionMember, none))
	{
		return;
	}
	ReOrganizeTeam(actionMember.m_iID);
	return;
}

//------------------------------------------------------------------//
//  PlaceBreachCharge()												//
//------------------------------------------------------------------//
function PlaceBreachCharge()
{
	// End:0x0B
	if(m_bLeaderIsAPlayer)
	{
		return;
	}
	// End:0x1E
	if(__NFUN_114__(m_BreachingDoor, none))
	{
		ActionNodeCompleted();
		return;
	}
	// End:0x4A
	if(__NFUN_130__(m_BreachingDoor.ShouldBeBreached(), __NFUN_129__(HasBreachingCharge(m_Team[0]))))
	{
		ReOrganizeTeamForBreachDoor();
	}
	// End:0x9D
	if(__NFUN_132__(__NFUN_129__(HasBreachingCharge(m_Team[0])), __NFUN_129__(m_BreachingDoor.ShouldBeBreached())))
	{
		// End:0x8B
		if(__NFUN_154__(int(m_eGoCode), int(4)))
		{
			ActionNodeCompleted();			
		}
		else
		{
			m_bSkipAction = true;
		}
		m_BreachingDoor = none;		
	}
	else
	{
		R6RainbowAI(m_Team[0].Controller).ResetStateProgress();
		m_Team[0].Controller.__NFUN_113__('PlaceBreachingCharge');
	}
	return;
}

//------------------------------------------------------------------//
//  BreachDoor														//	
//------------------------------------------------------------------//
function BreachDoor()
{
	// End:0x12
	if(m_bLeaderIsAPlayer)
	{
		ResetTeamGoCode();		
	}
	else
	{
		// End:0x24
		if(m_bSkipAction)
		{
			ActionNodeCompleted();			
		}
		else
		{
			R6RainbowAI(m_Team[0].Controller).DetonateBreach();
		}
	}
	return;
}

//------------------------------------------------------------------
//  SetTeamGoCode()
//    set Alpha, Bravo, or Charlie gocodes
//------------------------------------------------------------------
function SetTeamGoCode(Object.EGoCode eCode)
{
	// End:0x17
	if(m_bCAWaitingForZuluGoCode)
	{
		m_eBackupGoCode = eCode;		
	}
	else
	{
		m_eBackupGoCode = 4;
		m_eGoCode = eCode;
	}
	return;
}

//------------------------------------------------------------------
//  ResetTeamGoCode()
//    called when Alpha, Bravo, or Charlie gocodes are received
//------------------------------------------------------------------
function ResetTeamGoCode()
{
	// End:0x0B
	if(m_bCAWaitingForZuluGoCode)
	{
		return;
	}
	m_eGoCode = 4;
	m_eBackupGoCode = 4;
	return;
}

//------------------------------------------------------------------
//  ResetZuluGoCode()
//------------------------------------------------------------------
function ResetZuluGoCode()
{
	// End:0x0D
	if(__NFUN_129__(m_bCAWaitingForZuluGoCode))
	{
		return;
	}
	m_bCAWaitingForZuluGoCode = false;
	m_eGoCode = m_eBackupGoCode;
	m_eBackupGoCode = 4;
	return;
}

//------------------------------------------------------------------//
//  ReOrganizeTeamForSniping										//
//    for AI led team only									        //
//------------------------------------------------------------------//
function ReOrganizeTeamForSniping()
{
	local R6Rainbow actionMember;
	local int i, iBestSniper;
	local float fBestRange, fCurrentRange;

	// End:0x0B
	if(m_bSniperReady)
	{
		return;
	}
	iBestSniper = -1;
	i = 0;
	J0x1D:

	// End:0xBB [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		// End:0xB1
		if(__NFUN_154__(int(m_Team[i].m_WeaponsCarried[0].m_eWeaponType), int(4)))
		{
			// End:0x73
			if(__NFUN_154__(iBestSniper, -1))
			{
				iBestSniper = i;
				// [Explicit Continue]
				goto J0xB1;
			}
			// End:0xB1
			if(__NFUN_177__(m_Team[i].GetSkill(3), m_Team[iBestSniper].GetSkill(3)))
			{
				iBestSniper = i;
			}
		}
		J0xB1:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x1D;
	}
	// End:0x15E
	if(__NFUN_154__(iBestSniper, -1))
	{
		iBestSniper = 0;
		fBestRange = m_Team[0].m_WeaponsCarried[0].GetWeaponRange();
		i = 0;
		J0xFA:

		// End:0x15E [Loop If]
		if(__NFUN_150__(i, m_iMemberCount))
		{
			fCurrentRange = m_Team[i].m_WeaponsCarried[0].GetWeaponRange();
			// End:0x154
			if(__NFUN_177__(fCurrentRange, fBestRange))
			{
				iBestSniper = i;
				fBestRange = fCurrentRange;
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0xFA;
		}
	}
	// End:0x174
	if(__NFUN_155__(iBestSniper, 0))
	{
		ReOrganizeTeam(iBestSniper);
	}
	m_bSniperReady = true;
	return;
}

//------------------------------------------------------------------//
//  SnipeUntilGoCode()												//
//   AI led team only; this function should be called when AI lead  //
//   is close enough to the sniping location; it may be necessary 	//
//   to temporarily reorganise the order of the team members.		//
//------------------------------------------------------------------//
function SnipeUntilGoCode()
{
	local int i;
	local Vector vLocation;
	local Rotator rRotation;

	// End:0x0B
	if(m_bLeaderIsAPlayer)
	{
		return;
	}
	// End:0x1E
	if(m_bTeamIsClimbingLadder)
	{
		m_bPendingSnipeUntilGoCode = true;
		return;
	}
	m_bPendingSnipeUntilGoCode = false;
	m_TeamPlanning.GetSnipingCoordinates(vLocation, rRotation);
	SetTeamState(7);
	R6RainbowAI(m_Team[0].Controller).m_ActionTarget = m_LastActionPoint;
	m_rSnipingDir = rRotation;
	m_Team[0].Controller.__NFUN_113__('SnipeUntilGoCode');
	// End:0xA5
	if(m_bCAWaitingForZuluGoCode)
	{
		SetTeamState(1);		
	}
	else
	{
		i = 1;
		J0xAC:

		// End:0xE4 [Loop If]
		if(__NFUN_150__(i, m_iMemberCount))
		{
			m_Team[i].Controller.__NFUN_113__('FollowLeader');
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0xAC;
		}
	}
	return;
}

//------------------------------------------------------------------//
//  TeamSnipingOver()												//
//    can be called from team manager when go code is received		//
//------------------------------------------------------------------//
function TeamSnipingOver()
{
	local int i;

	// End:0x11
	if(m_bLeaderIsAPlayer)
	{
		ResetTeamGoCode();
		return;
	}
	RestoreTeamOrder();
	// End:0x3E
	if(m_bTeamIsHoldingPosition)
	{
		m_Team[0].Controller.__NFUN_113__('HoldPosition');		
	}
	else
	{
		m_Team[0].Controller.__NFUN_113__('Patrol');
	}
	i = 1;
	J0x60:

	// End:0x98 [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		m_Team[i].Controller.__NFUN_113__('FollowLeader');
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x60;
	}
	ActionNodeCompleted();
	return;
}

//------------------------------------------------------------------//
//  NotifyActionPoint()												//
//------------------------------------------------------------------//
function TeamNotifyActionPoint(Object.ENodeNotify eMsg, Object.EGoCode eCode)
{
	switch(eMsg)
	{
		// End:0x6E
		case 0:
			m_ePlanAction = m_TeamPlanning.GetAction();
			m_vPlanActionLocation = m_TeamPlanning.GetActionLocation();
			ResetTeamGoCode();
			// End:0x6C
			if(__NFUN_154__(int(m_ePlanAction), int(6)))
			{
				m_BreachingDoor = R6IORotatingDoor(m_TeamPlanning.GetDoorToBreach());
				PlaceBreachCharge();
			}
			return;
		// End:0x8A
		case 1:
			m_eMovementMode = m_TeamPlanning.GetMovementMode();
			return;
		// End:0xA6
		case 2:
			m_eMovementSpeed = m_TeamPlanning.GetMovementSpeed();
			return;
		// End:0xB9
		case 3:
			ResetTeamGoCode();
			GetNextActionPoint();
			return;
		// End:0xD6
		case 6:
			SetTeamGoCode(eCode);
			PlayWaitingGoCode(m_eGoCode);
			return;
		// End:0xF6
		case 9:
			SetTeamGoCode(eCode);
			m_ePlanAction = 5;
			SnipeUntilGoCode();
			return;
		// End:0x130
		case 10:
			SetTeamGoCode(eCode);
			m_ePlanAction = 6;
			m_BreachingDoor = R6IORotatingDoor(m_TeamPlanning.GetDoorToBreach());
			PlaceBreachCharge();
			return;
		// End:0x13D
		case 4:
			GetNextActionPoint();
			return;
		// End:0x144
		case 5:
			return;
		// End:0xFFFF
		default:
			return;
			break;
	}
}

function PlayWaitingGoCode(Object.EGoCode eCode, optional bool bSnipeUntilGoCode)
{
	// End:0x0D
	if(__NFUN_114__(m_OtherTeamVoicesMgr, none))
	{
		return;
	}
	// End:0x100
	if(__NFUN_129__(m_bLeaderIsAPlayer))
	{
		switch(eCode)
		{
			// End:0x5F
			case 0:
				// End:0x46
				if(bSnipeUntilGoCode)
				{
					m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, 31);					
				}
				else
				{
					m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, 15);
				}
				// End:0x100
				break;
			// End:0x9F
			case 1:
				// End:0x86
				if(bSnipeUntilGoCode)
				{
					m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, 32);					
				}
				else
				{
					m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, 16);
				}
				// End:0x100
				break;
			// End:0xDF
			case 2:
				// End:0xC6
				if(bSnipeUntilGoCode)
				{
					m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, 33);					
				}
				else
				{
					m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, 17);
				}
				// End:0x100
				break;
			// End:0xFD
			case 3:
				m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamLeader, 18);
				// End:0x100
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		return;
	}
}

//------------------------------------------------------------------//
//  GetFirstActionPoint()											//
//------------------------------------------------------------------//
function GetFirstActionPoint()
{
	m_PlanActionPoint = m_TeamPlanning.GetFirstActionPoint();
	m_LastActionPoint = m_PlanActionPoint;
	TeamNotifyActionPoint(2, 4);
	TeamNotifyActionPoint(1, 4);
	return;
}

//------------------------------------------------------------------//
//  GetNextActionPoint()											//
//------------------------------------------------------------------//
function GetNextActionPoint()
{
	m_PlanActionPoint = m_TeamPlanning.GetNextActionPoint();
	// End:0x64
	if(__NFUN_119__(m_PlanActionPoint, none))
	{
		m_eNextAPAction = m_TeamPlanning.NextActionPointHasAction(m_PlanActionPoint);
		// End:0x64
		if(__NFUN_114__(m_BreachingDoor, none))
		{
			m_BreachingDoor = R6IORotatingDoor(m_TeamPlanning.GetNextDoorToBreach(m_PlanActionPoint));
		}
	}
	m_LastActionPoint = m_PlanActionPoint;
	return;
}

//------------------------------------------------------------------//
//  PreviewNextActionPoint()										//
//------------------------------------------------------------------//
function Actor PreviewNextActionPoint()
{
	return m_TeamPlanning.PreviewNextActionPoint();
	return;
}

//------------------------------------------------------------------//
//  ActionPointReached()											//
//------------------------------------------------------------------//
function ActionPointReached()
{
	m_PlanActionPoint = none;
	m_TeamPlanning.NotifyActionPoint(7, 4);
	return;
}

//------------------------------------------------------------------//
//  ActionNodeCompleted()								            //
//------------------------------------------------------------------//
function ActionNodeCompleted()
{
	m_ePlanAction = 0;
	m_bSkipAction = false;
	m_TeamPlanning.NotifyActionPoint(5, 4);
	m_bSniperReady = false;
	return;
}

//------------------------------------------------------------------//
//  PlayerHasAbandonedTeam()										//
//------------------------------------------------------------------//
function PlayerHasAbandonedTeam()
{
	local R6Rainbow tempPawn;
	local int iLastMember, i;

	m_TeamPlanning.NotifyActionPoint(8, 4);
	// End:0x141
	if(__NFUN_130__(m_Team[0].m_bIsPlayer, __NFUN_129__(m_Team[0].IsAlive())))
	{
		m_Team[0].UnPossessed();
		iLastMember = __NFUN_147__(m_iMemberCount, 1);
		tempPawn = m_Team[0];
		i = 0;
		J0x72:

		// End:0xD6 [Loop If]
		if(__NFUN_150__(i, m_iMemberCount))
		{
			m_Team[i] = m_Team[__NFUN_146__(i, 1)];
			m_Team[i].m_iID = i;
			m_Team[i].m_bIsPlayer = false;
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x72;
		}
		m_TeamLeader = m_Team[0];
		m_Team[__NFUN_146__(iLastMember, 1)] = tempPawn;
		tempPawn.m_bIsPlayer = false;
		m_Team[__NFUN_146__(iLastMember, 1)].m_iID = __NFUN_146__(iLastMember, 1);
		m_TeamLeader.Controller.__NFUN_113__('Patrol');
	}
	// End:0x192
	if(__NFUN_154__(m_iTeamAction, 0))
	{
		i = 1;
		J0x153:

		// End:0x18B [Loop If]
		if(__NFUN_150__(i, m_iMemberCount))
		{
			m_Team[i].Controller.__NFUN_113__('FollowLeader');
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x153;
		}
		TeamIsSeparatedFromLead(false);
	}
	return;
}

//------------------------------------------------------------------
// Escort_GetLastRainbow: return the last rainbow that
//  will be at the end of the list of escorted hostage
//------------------------------------------------------------------
function R6Rainbow Escort_GetLastRainbow()
{
	local int i;

	// End:0x65
	if(__NFUN_151__(m_iMemberCount, 0))
	{
		i = __NFUN_147__(m_iMemberCount, 1);
		J0x19:

		// End:0x65 [Loop If]
		if(__NFUN_130__(__NFUN_153__(i, 0), __NFUN_119__(m_Team[i], none)))
		{
			// End:0x5B
			if(m_Team[i].IsAlive())
			{
				return m_Team[i];
			}
			__NFUN_164__(i);
			// [Loop Continue]
			goto J0x19;
		}
	}
	return none;
	return;
}

//------------------------------------------------------------------
// Escort_UpdateTeamSpeed: check if a escorted hostage is wounded
//	
//------------------------------------------------------------------
function Escort_UpdateTeamSpeed()
{
	local int i, iRainbow;
	local R6Rainbow R;

	m_bWoundedHostage = false;
	iRainbow = 0;
	J0x0F:

	// End:0xAB [Loop If]
	if(__NFUN_150__(iRainbow, m_iMemberCount))
	{
		R = m_Team[iRainbow];
		J0x2F:

		// End:0xA1 [Loop If]
		if(__NFUN_130__(__NFUN_130__(__NFUN_119__(R, none), __NFUN_150__(i, 4)), __NFUN_119__(R.m_aEscortedHostage[i], none)))
		{
			// End:0x97
			if(__NFUN_154__(int(R.m_aEscortedHostage[i].m_eHealth), int(1)))
			{
				m_bWoundedHostage = true;
				// [Explicit Break]
				goto J0xA1;
			}
			__NFUN_163__(i);
			// [Loop Continue]
			goto J0x2F;
		}
		J0xA1:

		__NFUN_165__(iRainbow);
		// [Loop Continue]
		goto J0x0F;
	}
	return;
}

//------------------------------------------------------------------
// UpdateEscortList: update directly who's following who and set team
//  formation info
//------------------------------------------------------------------
function UpdateEscortList()
{
	local int i;

	// End:0x0F
	if(__NFUN_114__(m_Team[0], none))
	{
		return;
	}
	i = 0;
	J0x16:

	// End:0x44 [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		m_Team[i].Escort_UpdateList();
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x16;
	}
	return;
}

// A SERVER SIDE FUNCTION
function SetTeamColor(int iTeamNum)
{
	// End:0x20
	if(__NFUN_132__(__NFUN_150__(iTeamNum, 0), __NFUN_151__(iTeamNum, 2)))
	{
		iTeamNum = 0;
	}
	m_TeamColour = Colors.TeamHUDColor[iTeamNum];
	return;
}

simulated function Color GetTeamColor()
{
	// End:0x24
	if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
	{
		SetTeamColor(m_iRainbowTeamName);
	}
	return m_TeamColour;
	return;
}

//------------------------------------------------------------------
// SetMemberTeamID: set the team ID used for the friendship system.
//	in single player, by default it's c_iTeamNumAlpha.
//------------------------------------------------------------------
function SetMemberTeamID(int iTeamId)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x9F [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		m_Team[i].m_iTeam = iTeamId;
		// End:0x6D
		if(__NFUN_119__(m_Team[i].PlayerReplicationInfo, none))
		{
			m_Team[i].PlayerReplicationInfo.TeamID = iTeamId;
		}
		R6AbstractGameInfo(Level.Game).SetPawnTeamFriendlies(m_Team[i]);
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

simulated function ResetTeam()
{
	local int i;

	i = 0;
	J0x07:

	// End:0x2A [Loop If]
	if(__NFUN_150__(i, 4))
	{
		m_Team[i] = none;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	m_TeamLeader = none;
	return;
}

simulated function FirstPassReset()
{
	ResetTeam();
	return;
}

//------------------------------------------------------------------
// Escort_ManageList
//	
//------------------------------------------------------------------
function Escort_ManageList()
{
	local int i, iHostage;
	local R6Rainbow lastRainbow;
	local R6Hostage hostage;

	// End:0x0B
	if(m_bTeamIsSeparatedFromLeader)
	{
		return;
	}
	lastRainbow = Escort_GetLastRainbow();
	// End:0x24
	if(__NFUN_114__(lastRainbow, none))
	{
		return;
	}
	i = 0;
	J0x2B:

	// End:0x11E [Loop If]
	if(__NFUN_150__(i, m_iMemberCount))
	{
		// End:0x52
		if(__NFUN_114__(lastRainbow, m_Team[i]))
		{
			// [Explicit Continue]
			goto J0x114;
		}
		// End:0x114
		if(__NFUN_119__(m_Team[i].m_aEscortedHostage[0], none))
		{
			iHostage = 0;
			J0x75:

			// End:0x114 [Loop If]
			if(__NFUN_130__(__NFUN_150__(iHostage, 4), __NFUN_119__(m_Team[i].m_aEscortedHostage[iHostage], none)))
			{
				hostage = m_Team[i].m_aEscortedHostage[iHostage];
				// End:0xF5
				if(__NFUN_119__(hostage.m_escortedByRainbow, none))
				{
					hostage.m_escortedByRainbow.Escort_RemoveHostage(hostage, true);
				}
				lastRainbow.Escort_AddHostage(hostage, true);
				__NFUN_165__(iHostage);
				// [Loop Continue]
				goto J0x75;
			}
		}
		J0x114:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x2B;
	}
	return;
}

//------------------------------------------------------------------
// Escort_GetPawnToFollow: 
//	return the rainbow who will lead the escorted hostages
//  the rainbow needs to be in the team (not separated) otherwise
//  the rainbow who ordered to follow will be the lead.
//------------------------------------------------------------------
function R6Rainbow Escort_GetPawnToFollow(R6Rainbow Rainbow, bool bRunningTowardMe)
{
	local R6Rainbow lastRainbow;

	// End:0x57
	if(__NFUN_132__(__NFUN_129__(m_bTeamIsSeparatedFromLeader), __NFUN_129__(Rainbow.IsAlive())))
	{
		lastRainbow = Escort_GetLastRainbow();
		// End:0x57
		if(__NFUN_130__(__NFUN_119__(lastRainbow, none), lastRainbow.IsAlive()))
		{
			Rainbow = lastRainbow;
		}
	}
	return Rainbow;
	return;
}

// Reset the gas grenade variable
event Timer()
{
	m_bFirstTimeInGas = false;
	return;
}

defaultproperties
{
	m_eFormation=1
	m_eMovementSpeed=1
	m_eGoCode=4
	m_eBackupGoCode=4
	m_iFormationDistance=100
	m_iDiagonalDistance=80
	m_iSpawnDistance=81
	m_iSpawnDiagDist=115
	m_iSpawnDiagOther=180
	m_bSniperHold=true
	m_bFirstTimeInGas=true
	RemoteRole=2
	bHidden=true
	m_bDeleteOnReset=true
	NetUpdateFrequency=4.0000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_Teamc_iMaxTeam
// REMOVED IN 1.60: var m_iTeamHealthc_iMaxTeam
// REMOVED IN 1.60: var ePlayerRoomEntry
// REMOVED IN 1.60: var eTeamState
