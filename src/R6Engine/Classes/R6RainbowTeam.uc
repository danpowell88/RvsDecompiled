//=============================================================================
//  R6RainbowTeam.uc : The R6RainbowTeam class is where the AI for the Rainbow
//					   team will be implemented.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//=============================================================================
class R6RainbowTeam extends Actor
    native;

// --- Constants ---
const c_iMaxTeam =  4;

// --- Enums ---
enum eTeamState
{
    // enum values not recoverable from binary — see 1.56 source
};
enum ePlayerRoomEntry
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var /* replicated */ R6Rainbow m_Team[4];
var R6Rainbow m_TeamLeader;
var /* replicated */ int m_iMemberCount;
// reference to a door actor involved in a room entry
var R6Door m_Door;
var int m_iTeamAction;
var R6RainbowPlayerVoices m_PlayerVoicesMgr;
var Actor m_PlanActionPoint;
var R6GameColors Colors;
// status flags
// the leader of this team is not an NPC (is a player)
var bool m_bLeaderIsAPlayer;
var R6RainbowMemberVoices m_MemberVoicesMgr;
var R6RainbowOtherTeamVoices m_OtherTeamVoicesMgr;
var R6CircumstantialActionQuery m_actionRequested;
var bool m_bCAWaitingForZuluGoCode;
// team was either told to hold position or to perform an action (e.g. climb ladder)
var bool m_bTeamIsSeparatedFromLeader;
var R6IORotatingDoor m_BreachingDoor;
// team is in the process of climbing a ladder
var /* replicated */ bool m_bTeamIsClimbingLadder;
var R6AbstractPlanningInfo m_TeamPlanning;
// GOCODE_Alpha, GOCODE_Bravo, GOCODE_Charlie, GOCODE_Delta, GOCODE_None
var /* replicated */ EGoCode m_eGoCode;
// When the player is in observer mode on the current team
var bool m_bPlayerHasFocus;
var eWeaponGrenadeType m_eEntryGrenadeType;
var EPlanAction m_ePlanAction;
var bool m_bTeamIsHoldingPosition;
// Rules Of Engagement determines speed and hostility of unit
// Rules Of Engagement
var EMovementMode m_eMovementMode;
// ladder climbing
var R6Ladder m_TeamLadder;
// doors & room entry
// a room entry is in progress
var bool m_bEntryInProgress;
var R6Pawn m_PawnControllingDoor;
// used for temporary reorganisation of team; to keep track of who original lead was
var int m_iIntermLeader;
var R6MultiCoopVoices m_MultiCoopMemberVoicesMgr;
var /* replicated */ eTeamState m_eTeamState;  // Current operational state of the Rainbow team (replicated)
// ^ NEW IN 1.60
var ePlayerRoomEntry m_ePlayerRoomEntry; // Room-entry mode the player has ordered the team to use
// ^ NEW IN 1.60
// each bit is used by the client for the RoseDesVents.
// and is examined to see if we have a team member with
// a specific grenade type, this is more effecient than
// replicate all the info for all weapons
var /* replicated */ byte m_bHasGrenade;
var EMovementSpeed m_eMovementSpeed;
var EPlanAction m_eNextAPAction;
var bool m_bSniperHold;
// information for HUD... (information stays even if a member is dead)
var int m_iTeamHealth[4];
// frag grenade
var bool m_bGrenadeInProximity;
var Vector m_vActionLocation;
var Rotator m_rSnipingDir;
var Vector m_vPlanActionLocation;
var EPlanAction m_ePlayerAPAction;
var EGoCode m_eBackupGoCode;
var R6MultiCoopVoices m_MultiCoopPlayerVoicesMgr;
var R6MultiCommonVoices m_MultiCommonVoicesMgr;
var bool m_bSkipAction;
var R6Pawn m_HostageToRescue;
var bool m_bTeamIsRegrouping;
var bool m_bPlayerRequestedTeamReform;
var bool m_bPlayerInGhostMode;
var bool m_bTeamIsEngagingEnemy;
var R6Pawn m_SurrenderedTerrorist;
var array<array> m_InteractiveObjectList;
// door control, room entry
//var         INT                     m_iAction;                          // contains the desired action to take... (door: OPEN/CLOSE)
// contains the desired sub action to take...
var int m_iSubAction;
var bool m_bRainbowIsInFrontOfDoor;
var R6PreRecordedMsgVoices m_PreRecMsgVoicesMgr;
var Vector m_vPreviousPosition;
// tear gas grenade
var bool m_bGasGrenadeInProximity;
// true if an escorted hostage is wounded
var bool m_bWoundedHostage;
var int m_iIDVoicesMgr;
// team formation
var eFormation m_eFormation;
var /* replicated */ int m_iMembersLost;
// index of the last member who throwed a grenade
var int m_iGrenadeThrower;
var Actor m_LastActionPoint;
var bool m_bSniperReady;
var bool m_bPendingSnipeUntilGoCode;
var eTeamState m_eBackupTeamState;  // Saved team state used to restore after a temporary state override
// ^ NEW IN 1.60
var Vector m_vNoiseSource;
var bool m_bFirstTimeInGas;
var /* replicated */ Color m_TeamColour;
var eFormation m_eRequestedFormation;
// standard distance between members when in a movement formation
var int m_iFormationDistance;
// distance used to spawn characters next to the start point
var int m_iSpawnDistance;
// distance used to spawn characters diagonaly to the start point
var int m_iSpawnDiagDist;
var bool m_bWasSeparatedFromLeader;
var Actor m_PlayerLastActionPoint;
var float m_fEngagingTimer;
var bool m_bDoorOpensTowardTeam;
var bool m_bDoorOpensClockWise;
// team info to maintain for members
// rotator that maintains the direction of movement of the team leader
var Rotator m_rTeamDirection;
// distance used to spawn characters around the start point(not diagonaly or next to)
var int m_iSpawnDiagOther;
var int m_iRainbowTeamName;
var bool m_bAllTeamsHold;
//#ifdefDEBUG
var bool bShowLog;
var int m_iDiagonalDistance;
// Prevent using team for training
var bool m_bPreventUsingTeam;
var bool bPlanningLog;

// --- Functions ---
//------------------------------------------------------------------//
//  AssignNewTeamLeader()
//------------------------------------------------------------------//
function AssignNewTeamLeader(int iNewLeader) {}
//------------------------------------------------------------------//
//  DisEngaged()													//
//------------------------------------------------------------------//
function DisEngageEnemy(Pawn Rainbow, Pawn Enemy) {}
//------------------------------------------------------------------//
// SetFormation()													//
//   TODO : this function may have become unnecessary               //
//------------------------------------------------------------------//
function SetFormation(R6RainbowAI memberAI) {}
//------------------------------------------------------------------//
// rbrek - 5 sept 2001                                              //
// MoveTeamToCompleted()                                            //
//------------------------------------------------------------------//
function MoveTeamToCompleted(bool bStatus) {}
//------------------------------------------------------------------//
// GasGrenadeInProximity()											//
//------------------------------------------------------------------//
function GasGrenadeInProximity(R6Rainbow spotter) {}
//------------------------------------------------------------------//
// rbrek - 8 feb 2002                                               //
// MembersAreOnSameEndOfLadder()									//
//------------------------------------------------------------------//
function bool MembersAreOnSameEndOfLadder(R6Pawn p1, R6Pawn p2) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// SetTeamIsClimbingLadder: set the bool and inform the escorted team
//	to climb the ladder.
//------------------------------------------------------------------
function SetTeamIsClimbingLadder(bool bClimbing) {}
//------------------------------------------------------------------//
// PlayGoCode()	               									    //
//------------------------------------------------------------------//
function PlayGoCode(EGoCode eGo) {}
//------------------------------------------------------------------//
// HaveRainbowWithGrenadeType()										//
//------------------------------------------------------------------//
simulated function bool HaveRainbowWithGrenadeType(eWeaponGrenadeType grenadeType) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
//  SetTeamGoCode()
//    set Alpha, Bravo, or Charlie gocodes
//------------------------------------------------------------------
function SetTeamGoCode(EGoCode eCode) {}
function TeamIsSeparatedFromLead(bool bSeparated) {}
//------------------------------------------------------------------//
//  TeamSpottedSurrenderedTerrorist()								//
//------------------------------------------------------------------//
function TeamSpottedSurrenderedTerrorist(R6Pawn terrorist) {}
function SetTeamState(eTeamState eNewState) {}
event PostBeginPlay() {}
//------------------------------------------------------------------
// ChooseOpenSound()
//	Choose the right sound to be played. If it's a volet say open it
//------------------------------------------------------------------
function ChooseOpenSound(R6CircumstantialActionQuery actionRequested) {}
//------------------------------------------------------------------
// TeamActionRequestWaitForZuluGoCode()
//	Action will be executed at Zulu GoCode
//------------------------------------------------------------------
function TeamActionRequestWaitForZuluGoCode(R6CircumstantialActionQuery actionRequested, int iMenuChoice, int iSubMenuChoice) {}
//------------------------------------------------------------------//
//  EnteredRoom()													//
//   called by each member of the team once they have entered...    //
//   this function should also be called once player/leader has     //
//   entered the room                                               //
//------------------------------------------------------------------//
function EnteredRoom(R6Pawn member) {}
//------------------------------------------------------------------
// SetAILeadControllerState()
//------------------------------------------------------------------
function SetAILeadControllerState() {}
//------------------------------------------------------------------//
// RequestFormationChange()											//
//   two requests by team members are necessary before the          //
//   current formation will be changed...                           //
//------------------------------------------------------------------//
event RequestFormationChange(eFormation eFormation) {}
//------------------------------------------------------------------//
// TeamHearNoise()													//
//------------------------------------------------------------------//
function TeamHearNoise(Actor aNoiseMaker) {}
//------------------------------------------------------------------//
//  ReOrganizeTeamForBreachDoor										//
//   for AI led team only									        //
//------------------------------------------------------------------//
function ReOrganizeTeamForBreachDoor() {}
//------------------------------------------------------------------//
//  NotifyActionPoint()												//
//------------------------------------------------------------------//
function TeamNotifyActionPoint(EGoCode eCode, ENodeNotify eMsg) {}
function PlayWaitingGoCode(optional bool bSnipeUntilGoCode, EGoCode eCode) {}
//------------------------------------------------------------------
// Escort_GetPawnToFollow:
//	return the rainbow who will lead the escorted hostages
//  the rainbow needs to be in the team (not separated) otherwise
//  the rainbow who ordered to follow will be the lead.
//------------------------------------------------------------------
function R6Rainbow Escort_GetPawnToFollow(R6Rainbow Rainbow, bool bRunningTowardMe) {}
// ^ NEW IN 1.60
simulated function ResetTeam() {}
// A SERVER SIDE FUNCTION
function SetTeamColor(int iTeamNum) {}
//------------------------------------------------------------------
// UpdateEscortList: update directly who's following who and set team
//  formation info
//------------------------------------------------------------------
function UpdateEscortList() {}
//------------------------------------------------------------------
// Escort_UpdateTeamSpeed: check if a escorted hostage is wounded
//
//------------------------------------------------------------------
function Escort_UpdateTeamSpeed() {}
//------------------------------------------------------------------//
//  TeamSnipingOver()												//
//    can be called from team manager when go code is received		//
//------------------------------------------------------------------//
function TeamSnipingOver() {}
//------------------------------------------------------------------//
//  SnipeUntilGoCode()												//
//   AI led team only; this function should be called when AI lead  //
//   is close enough to the sniping location; it may be necessary 	//
//   to temporarily reorganise the order of the team members.		//
//------------------------------------------------------------------//
function SnipeUntilGoCode() {}
//------------------------------------------------------------------//
//  RainbowIsEngaging()
//------------------------------------------------------------------//
function bool RainbowIsEngaging() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------//
// UpdateTeamFormation()											//
//   inform all the team members of the change in formation         //
//------------------------------------------------------------------//
event UpdateTeamFormation(eFormation eFormation) {}
//------------------------------------------------------------------//
// AtLeastOneMemberIsWounded()										//
//  used by an AI led team; AI lead should walk if any of the		//
//  members are wounded or if any of the hostages being escorted	//
//  are wounded.													//
//------------------------------------------------------------------//
function bool AtLeastOneMemberIsWounded() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------//
// RainbowHasLeftDoor()												//
//   this function is called in a few different cases...			//
//   . door opens and m_PawnControllingDoor goes through open door  //
//   . door opens and m_PawnControllingDoor leaves door area		//
//   . door is not opened, m_PawnControllingDoor leaves area		//
//------------------------------------------------------------------//
function RainbowHasLeftDoor(R6Pawn Rainbow) {}
//------------------------------------------------------------------//
// EndRoomEntry()													//
//   Room entry has been cancelled									//
//------------------------------------------------------------------//
function EndRoomEntry() {}
//------------------------------------------------------------------//
// rbrek - 2 sept 2001                                              //
// ActionCompleted()												//
//   this function is called to inform the TeamAI that a requested  //
//   action has been completed (or in not possible to complete      //
//------------------------------------------------------------------//
function ActionCompleted(bool bSuccess) {}
//------------------------------------------------------------------//
// ReOrganizeTeamForGrenade											//
//   for AI led team only									        //
//------------------------------------------------------------------//
function ReOrganizeTeamForGrenade(EPlanAction ePAction) {}
//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// InstructTeamToArrestTerrorist()									//
//------------------------------------------------------------------//
function InstructTeamToArrestTerrorist(R6Terrorist terrorist) {}
//------------------------------------------------------------------//
// FriendlyFlashBang()												//
//------------------------------------------------------------------//
function bool FriendlyFlashBang(Actor aGrenade) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// MemberFinishedClimbingLadder()									//
//   called when any member of the team finished climbing the       //
//   ladder.  (NPC and player)                                      //
//------------------------------------------------------------------//
function MemberFinishedClimbingLadder(R6Pawn member) {}
//------------------------------------------------------------------
// rbrek
// 17 sept 2002
//------------------------------------------------------------------
function bool AllMembersAreOnTheSameSideOfTheLadder(R6LadderVolume Ladder) {}
// ^ NEW IN 1.60
function UpdateLocalActionRequest(R6CircumstantialActionQuery actionRequested) {}
//------------------------------------------------------------------//
// rbrek - 11 may 2002												//
// ResetRainbowTeam()												//
//	 resets all variables and rainbow states						//
//------------------------------------------------------------------//
function ResetRainbowTeam() {}
//------------------------------------------------------------------
// CreateMPPlayerTeam
//  used in multiplayer
//	create the team member base on the player controller
//------------------------------------------------------------------
function CreateMPPlayerTeam(R6RainbowStartInfo Info, PlayerController MyPlayer, int iMemberCount, PlayerStart Start) {}
//------------------------------------------------------------------//
//  HasBreachingCharge												//
//------------------------------------------------------------------//
function bool HasBreachingCharge(R6Rainbow Rainbow) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------//
//  AITeamFollowPlanning()											//
//------------------------------------------------------------------//
function AITeamFollowPlanning() {}
//------------------------------------------------------------------//
//  AITeamHoldPosition()											//
//------------------------------------------------------------------//
function AITeamHoldPosition() {}
function bool RainbowAIAreStillClimbingLadder() {}
// ^ NEW IN 1.60
function SwitchControllerRepInfo(R6RainbowAI tempRainbowAI, R6PlayerController tempPlayerController) {}
//------------------------------------------------------------------//
// GrenadeInProximity()												//
// todo : modify this to handle more than one grenade at a time??	//
//------------------------------------------------------------------//
function GrenadeInProximity(R6Rainbow spotter, Vector vGrenadeLocation, float fTimeLeft, float fGrenadeDangerRadius) {}
//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// InstructPlayerTeamToFollowLead()									//
//   if team is holding position, calling this function will bring  //
//   them out of hold and will resume following leader              //
//------------------------------------------------------------------//
function InstructPlayerTeamToFollowLead(optional bool bOtherTeam) {}
//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// InstructPlayerTeamToHoldPosition()								//
//   team holds position, and waits for leader's instruction        //
//------------------------------------------------------------------//
function InstructPlayerTeamToHoldPosition(optional bool bOtherTeam) {}
function TeamIsRegroupingOnLead(bool bIsRegrouping) {}
function SetMultiVoicesMgr(R6AbstractGameInfo aGameInfo, int iMemberCount, int iTeamNumber) {}
//------------------------------------------------------------------//
// CreateAITeam()													//
//------------------------------------------------------------------//
function CreateAITeam(R6TeamStartInfo TeamInfo, NavigationPoint StartingPoint) {}
//------------------------------------------------------------------//
// CreatePlayerTeam()												//
//------------------------------------------------------------------//
function CreatePlayerTeam(R6TeamStartInfo TeamInfo, NavigationPoint StartingPoint, PlayerController aRainbowPC) {}
//------------------------------------------------------------------//
// GasGrenadeCleared()												//
//------------------------------------------------------------------//
function GasGrenadeCleared(R6Pawn aPawn) {}
//------------------------------------------------------------------
// Escort_GetLastRainbow: return the last rainbow that
//  will be at the end of the list of escorted hostage
//------------------------------------------------------------------
function R6Rainbow Escort_GetLastRainbow() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------//
//  GetPlayerDirection()											//
//------------------------------------------------------------------//
function GetPlayerDirection() {}
//------------------------------------------------------------------//
// FindRainbowWithBreachingCharge()									//
//------------------------------------------------------------------//
function R6Rainbow FindRainbowWithBreachingCharge() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
//  RestoreTeamOrder()
//------------------------------------------------------------------
function RestoreTeamOrder() {}
//------------------------------------------------------------------//
//  ReOrganizeTeam()												//
//------------------------------------------------------------------//
function ReOrganizeTeam(int iNewLeader) {}
//------------------------------------------------------------------//
//  EngageEnemyIfNotAlreadyEngaged()								//
//------------------------------------------------------------------//
function bool EngageEnemyIfNotAlreadyEngaged(R6Pawn Rainbow, R6Pawn Enemy) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------//
//  PickMemberClosestTo()											//
//------------------------------------------------------------------//
function int PickMemberClosestTo(Actor aNoiseSource) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// AssociatePlayerAndPawn()
//  we don't want to use Possess/Unpossess, because that would reset
//  the physics (root motion)
//------------------------------------------------------------------
function AssociatePlayerAndPawn(R6PlayerController Player, R6Rainbow Pawn) {}
function TeamMemberDeadInFreeBackup(R6Pawn DeadPawn) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------//
// SetVoicesMgr()												    //
//------------------------------------------------------------------//
function SetVoicesMgr(R6AbstractGameInfo aGameInfo, bool bPlayerTeamStart, optional int iIDVoicesMgr, bool bPlayerInTeam, optional bool bInGhostMode) {}
function CheckTeamEngagingStatus(optional Pawn rainbowToIgnore) {}
//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// TeamLeaderIsClimbingLadder()										//
//   this should be called from the playercontroller as well as the //
//   AIcontroller for the team lead                                 //
//------------------------------------------------------------------//
function TeamLeaderIsClimbingLadder() {}
//------------------------------------------------------------------
//  ResetTeamMemberStates()
//------------------------------------------------------------------
function ResetTeamMemberStates() {}
//------------------------------------------------------------------//
//  RainbowIsInFrontOfAClosedDoor()									//
//    when this occurs, the team members should enter an			//
//    appropriate formation depending on the room behind the door   //
//    ROOM_None, ROOM_OpensLeft, ROOM_OpensRight, ROOM_OpensCenter  //
// This function is called from R6Pawn when either a teamleader (or //
// the 2nd team member in a team that is separated from its leader) //
// comes into contact with a closed door							//
//------------------------------------------------------------------//
function RainbowIsInFrontOfAClosedDoor(R6Pawn Rainbow, R6Door Door) {}
//------------------------------------------------------------------
// SetMemberTeamID: set the team ID used for the friendship system.
//	in single player, by default it's c_iTeamNumAlpha.
//------------------------------------------------------------------
function SetMemberTeamID(int iTeamId) {}
//------------------------------------------------------------------
// Escort_ManageList
//
//------------------------------------------------------------------
function Escort_ManageList() {}
//------------------------------------------------------------------//
// rbrek - 5 sept 2001                                              //
// MoveTeamTo()														//
// TODO: add action to the MoveTeamTo...                            //
// TODO: if team does not see the target, do nothing...             //
//------------------------------------------------------------------//
function MoveTeamTo(Vector vLocation, optional int iSubAction) {}
//------------------------------------------------------------------//
// rbrek - 2 sept 2001                                              //
// function AssignAction()                                          //
//    ( target is a R6IORotatingDoor )                              //
//------------------------------------------------------------------//
function AssignAction(Actor Target, int iSubAction) {}
//------------------------------------------------------------------//
// TeamMemberDead()													//
//   called when a member of the team is killed                     //
//  note: this is called even when a member is only incapacitated...//
//------------------------------------------------------------------//
function TeamMemberDead(R6Pawn DeadPawn) {}
function ReOrganizeWoundedMembers() {}
//TEAM_InteractDevice
//------------------------------------------------------------------//
// rbrek - 5 sept 2001                                              //
// ReorganizeTeamToInteractWithDevice()                             //
// todo : need to do the same for interacting with an electronics   //
//        device (computer/keypad).									//
//------------------------------------------------------------------//
function ReorganizeTeamToInteractWithDevice(int iTeamAction, Actor actionObject) {}
//------------------------------------------------------------------//
// SwitchPlayerControlToPreviousMember()							//
//   TODO : beware of doing this while team is performing an action //
//------------------------------------------------------------------//
function SwitchPlayerControlToPreviousMember() {}
//------------------------------------------------------------------//
// SelectMemberWithFrag()											//
//------------------------------------------------------------------//
function R6Pawn SelectMemberWithFrag(Actor Target, int iSubAction) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------//
//  SendMemberToEnd()												//
//------------------------------------------------------------------//
function bool SendMemberToEnd(int iMember, optional bool bReorganizeWounded) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------//
// FindRainbowWithGrenadeType()			                            //
//	Look for a rainbow (other than the player) with a grenade of a  //
//	given type.														//
//------------------------------------------------------------------//
simulated function R6Rainbow FindRainbowWithGrenadeType(eWeaponGrenadeType grenadeType, bool bSetGadgetGroup) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// SetPlayerControllerState()
//------------------------------------------------------------------
function SetPlayerControllerState(R6PlayerController aPlayerController) {}
//------------------------------------------------------------------//
//  PlayerHasAbandonedTeam()										//
//------------------------------------------------------------------//
function PlayerHasAbandonedTeam() {}
//------------------------------------------------------------------//
//  ReOrganizeTeamForSniping										//
//    for AI led team only									        //
//------------------------------------------------------------------//
function ReOrganizeTeamForSniping() {}
//------------------------------------------------------------------//
// SwitchPlayerControlToNextMember()				   			    //
//   TODO : beware of doing this while team is performing an action //
//   TOFIX : sometimes a pawn remains invisible after switching to  //
//          another pawn (in 1st person)                            //
//------------------------------------------------------------------//
function SwitchPlayerControlToNextMember() {}
//------------------------------------------------------------------//
// GrenadeThreatIsOver()											//
//------------------------------------------------------------------//
function GrenadeThreatIsOver() {}
//------------------------------------------------------------------//
// UpdateTeamStatus()												//
//   called from R6TakeDamage() in R6Pawn.uc whenever a member of   //
//   the team takes damage.											//
//------------------------------------------------------------------//
function UpdateTeamStatus(R6Pawn member) {}
//------------------------------------------------------------------//
// SwapPlayerControlWithTeamMate()
//------------------------------------------------------------------//
function SwapPlayerControlWithTeamMate(int iMember) {}
//------------------------------------------------------------------//
// rbrek - 4 sept 2001                                              //
// TeamActionRequested()											//
//   this is the function that dispatches an action request to a    //
//   player's team.                                                 //
//------------------------------------------------------------------//
function TeamActionRequest(R6CircumstantialActionQuery actionRequested) {}
//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// InstructTeamToClimbLadder()										//
//   instructs team to climb the ladder without the leader, will    //
//   move to the closest ladder actor, climb to the other end, find //
//   a spot and wait for the leader to call a team regroup          //
//------------------------------------------------------------------//
function InstructTeamToClimbLadder(R6LadderVolume LadderVolume, optional bool bPathFinding, optional int iMemberId) {}
//Transfer the FPhands and FPweapons to an other pawn.  On client  only
delegate ClientUpdateFirstPersonWpnAndPeeking(R6Rainbow teamLeader, R6Rainbow npc) {}
//------------------------------------------------------------------//
//  UpdateFirstPersonWeaponMemory()									//
//------------------------------------------------------------------//
function UpdateFirstPersonWeaponMemory(R6Rainbow teamLeader, R6Rainbow npc) {}
//------------------------------------------------------------------
// ResetRainbowControllerStates()
//------------------------------------------------------------------
function ResetRainbowControllerStates(R6PlayerController aPlayerController, int iMember) {}
//------------------------------------------------------------------//
//  UpdatePlayerWeapon()											//
//------------------------------------------------------------------//
function UpdatePlayerWeapon(R6Rainbow Rainbow) {}
//------------------------------------------------------------------//
// rbrek - 5 sept 2001                                              //
// TeamActionRequestFromRoseDesVents()								//
//   this is the function that dispatches a action request to a     //
//   rainbow team that comes from the rose des vents                //
//------------------------------------------------------------------//
function TeamActionRequestFromRoseDesVents(R6CircumstantialActionQuery actionRequested, int iMenuChoice, int iSubMenuChoice, optional bool bOrderOnZulu) {}
//------------------------------------------------------------------//
// CreateTeamMember()												//
//------------------------------------------------------------------//
function CreateTeamMember(R6RainbowStartInfo RainbowToCreate, optional R6PlayerController RainbowPC, NavigationPoint StartingPoint, optional bool bPlayer) {}
simulated event Destroyed() {}
//------------------------------------------------------------------
// PostNetBeginPlay
//	create Colors on the server and on the Client
//------------------------------------------------------------------
simulated event PostNetBeginPlay() {}
//------------------------------------------------------------------//
// LastMemberIsStationary()											//
//------------------------------------------------------------------//
function bool LastMemberIsStationary() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------//
// ResetGrenadeAction()
//------------------------------------------------------------------//
function ResetGrenadeAction() {}
//------------------------------------------------------------------//
// UpdateTeamGrenadeStatus()										//
//------------------------------------------------------------------//
function UpdateTeamGrenadeStatus() {}
//------------------------------------------------------------------//
// ReceivedZuluGoCode()												//
//------------------------------------------------------------------//
function ReceivedZuluGoCode() {}
//------------------------------------------------------------------//
// PlaySniperOrder()                                                //
//------------------------------------------------------------------//
function PlaySniperOrder() {}
//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// TeamFinishedClimbingLadder()										//
//   called when all team members have finished climbing the ladder //
//------------------------------------------------------------------//
function TeamFinishedClimbingLadder() {}
//------------------------------------------------------------------//
// rbrek - 30 aug 2001                                              //
// TeamHasFinishedClimbingLadder()									//
//   this function returns a boolean that indicates whether the     //
//   entire team has finished climbing the ladder                   //
//------------------------------------------------------------------//
function bool TeamHasFinishedClimbingLadder() {}
// ^ NEW IN 1.60
function PlaySoundTeamStatusReport() {}
//------------------------------------------------------------------//
// PlayOrderTeamOnZulu()                                            //
// *** Play only if a Zulu go code is send ***                      //
//------------------------------------------------------------------//
function PlayOrderTeamOnZulu() {}
function ReIssueTeamOrders() {}
//------------------------------------------------------------------//
//  HasGoneThroughDoor()											//
//------------------------------------------------------------------//
function bool HasGoneThroughDoor() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ResetWeaponReloading()
//------------------------------------------------------------------
function ResetWeaponReloading() {}
function ResetNeutralFighterTeam() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------//
// Tick()															//
//   keep this function's content to an absolute minimun since it   //
//   called so frequently...                                        //
//------------------------------------------------------------------//
function Tick(float fDelta) {}
function RainbowIsEngagingEnemy() {}
//------------------------------------------------------------------//
//  PlaceBreachCharge()												//
//------------------------------------------------------------------//
function PlaceBreachCharge() {}
//------------------------------------------------------------------//
//  BreachDoor														//
//------------------------------------------------------------------//
function BreachDoor() {}
//------------------------------------------------------------------
//  ResetTeamGoCode()
//    called when Alpha, Bravo, or Charlie gocodes are received
//------------------------------------------------------------------
function ResetTeamGoCode() {}
//------------------------------------------------------------------
//  ResetZuluGoCode()
//------------------------------------------------------------------
function ResetZuluGoCode() {}
//------------------------------------------------------------------//
//  GetFirstActionPoint()											//
//------------------------------------------------------------------//
function GetFirstActionPoint() {}
//------------------------------------------------------------------//
//  GetNextActionPoint()											//
//------------------------------------------------------------------//
function GetNextActionPoint() {}
//------------------------------------------------------------------//
//  PreviewNextActionPoint()										//
//------------------------------------------------------------------//
function Actor PreviewNextActionPoint() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------//
//  ActionPointReached()											//
//------------------------------------------------------------------//
function ActionPointReached() {}
//------------------------------------------------------------------//
//  ActionNodeCompleted()								            //
//------------------------------------------------------------------//
function ActionNodeCompleted() {}
simulated function Color GetTeamColor() {}
// ^ NEW IN 1.60
simulated function FirstPassReset() {}
// Reset the gas grenade variable
event Timer() {}

defaultproperties
{
}
