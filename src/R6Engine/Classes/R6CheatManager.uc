//=============================================================================
// R6CheatManager - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6CheatManager.uc : Cheat manager for R6
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/24 * Created by Guillaume Borgia
//=============================================================================
class R6CheatManager extends CheatManager within PlayerController;

const c_iNavPointIndex = 10;

struct CommandInfo
{
	var name m_functionName;  // name used for quick string comparison
	var string m_szDescription;
};

var int m_iHostageTestAnimIndex;
var int m_iGameInfoLevel;
var int m_iCounterLog;
var int m_iCounterLogMax;
var int m_iCurNavPoint;
var int m_iCommandInfoIndex;
var bool m_bRenderGunDirection;
var bool m_bRenderViewDirection;
var bool m_bRenderBoneCorpse;
var bool m_bRenderFOV;
var bool m_bRenderRoute;
var bool m_bRenderNavPoint;
var bool m_bToggleHostageLog;
var bool m_bToggleHostageThreat;
var bool m_bHostageTestAnim;
var bool m_bToggleTerroLog;
var bool m_bRendSpot;
var bool m_bRendPawnState;
var bool m_bRendFocus;
var bool m_bToggleRainbowLog;
var bool m_bPlayerInvisble;
var bool m_bHideAll;
var bool m_bTogglePeek;
var bool m_bTogglePGDebug;
var bool m_bToggleThreatInfo;
var bool m_bToggleGameInfo;
var bool m_bToggleMissionLog;
var bool m_bFirstPersonPlayerView;
var bool m_bTeamGodMode;
var bool m_bSkipTick;
var bool m_bNumberLog;
// navigation debug system
var bool m_bEnableNavDebug;
var float m_fNavPointDistance;
var R6Pawn m_curPawn;
var R6Hostage m_Hostage;
var array<Vector> m_aNavPointLocation;
var CommandInfo m_aCommandInfo[128];

//------------------------------------------------------------------
// help: list all registered function
//------------------------------------------------------------------
exec function help()
{
	local int i;
	local string sz;
	local int iSize;
	local string szDot;

	// End:0x1534
	if((m_iCommandInfoIndex == 0))
	{
		AddCommandInfo(' ', "-- on/off function ------");
		AddCommandInfo('BoneCorpse', "diplay bone of Ragdoll");
		AddCommandInfo('GunDirection', "diplay GunDirection of all pawn");
		AddCommandInfo('HideAll', "hide all interface (HUD, weapon, reticule)");
		AddCommandInfo('Route', "diplay RouteCache of all controller");
		AddCommandInfo('NavPoint', "diplay NavPoint");
		AddCommandInfo('RouteAll', "diplay all path nodes (float max distance to player)");
		AddCommandInfo('toggleNav', "toggle the Navigation Point Debug System");
		AddCommandInfo('ToggleRadius', "diplay collision cylinder");
		AddCommandInfo('ShowFOV', "diplay field of view of all pawn");
		AddCommandInfo('dbgPeek', "debug peek system");
		AddCommandInfo('RendPawnState', "display current sate of pawn");
		AddCommandInfo('RendFocus', "toggle display of focus and focal point");
		AddCommandInfo('God', "make you invincible");
		AddCommandInfo('GodAll', "it call godTeam and GodHostage");
		AddCommandInfo('GodTeam', "make you and your team invisible");
		AddCommandInfo('GodHostage', "make all hostage invisible");
		AddCommandInfo('GodTerro', "make all terro invisible");
		AddCommandInfo('ToggleUnlimitedPractice', "mission objectives are updated but the game never ends");
		AddCommandInfo(' ', "----server-------------------");
		AddCommandInfo('SetRoundTime', "set the current time left for this round in X sec");
		AddCommandInfo('SetBetTime', "set the bet time in X sec");
		AddCommandInfo(' ', "-------------------------");
		AddCommandInfo('dbgActor', "all actor debug dump");
		AddCommandInfo('dbgRainbow', "all rainbow debug dump");
		AddCommandInfo('dgbWeapon', "current weapon debug info");
		AddCommandInfo('dbgThis', "debug ouput this actor (pointed by the gun) (false = TraceActor,  true = TraceWorld)");
		AddCommandInfo('dbgEdit', "edit this actor (pointed by the gun)");
		AddCommandInfo('SetPawn', "set the current pawn");
		AddCommandInfo('SetPawnPace', ("" $ SetPawnPace(0, true)));
		AddCommandInfo('UsePath', "current pawn will walk/run away from the player (int 1=run)");
		AddCommandInfo('SetPState', "set the selected pawn's state");
		AddCommandInfo('SetCState', "set the selected controller's state");
		AddCommandInfo('SeeCurPawn', "check if it can see the current pawn");
		AddCommandInfo('CanWalk', "curPawn: test CanWalkTo to player");
		AddCommandInfo('TestFindPathToMe', "curPawn: test findPathTo and findPathToward");
		AddCommandInfo('KillThemAll', "Kill all non-player pawn");
		AddCommandInfo('KillTerro', "Kill all terrorist");
		AddCommandInfo('KillHostage', "Kill all hostage");
		AddCommandInfo('KillRainbow', "Kill all rainbow");
		AddCommandInfo('Suicide', "Commit a gentle suicide");
		AddCommandInfo('ToggleCollision', "toggle pawn collision");
		AddCommandInfo('TestGetFrame', "test if the skeletal of all pawn have been updated");
		AddCommandInfo('CheckFrienship', "check isEnemy, isFriend and isNeutral");
		AddCommandInfo('LogFriendship', "list all frienship relation with all pawns (option: bCheckIfAlive)");
		AddCommandInfo('LogFriendlyFire', "list all friendly fire bool");
		AddCommandInfo('ShowGameInfo', "Show game mode info (0=debug, 1=Menu 2=Menu with failures msg)");
		AddCommandInfo('LogPawn', "LogPawn on the client and on the server");
		AddCommandInfo('LogThis', "Log pointed actor on the client and on the server");
		AddCommandInfo('ListEscort', "List escorted hostage");
		AddCommandInfo('GetNbTerro', "number of terro");
		AddCommandInfo('GetNbRainbow', "number of rainbow");
		AddCommandInfo('GetNbHostage', "number of hostage");
		AddCommandInfo(' ', "-- hostage --------------");
		AddCommandInfo('hHelp', "display AI Hostage / Civilian debugger");
		AddCommandInfo('DbgHostage', "debug hostage");
		AddCommandInfo('ToggleHostageLog', "toggle hostage log of AI and PAWN");
		AddCommandInfo('ToggleHostageThreat', "toggle hostage threat detection");
		AddCommandInfo('MoveEscort', "order the escort to move there");
		AddCommandInfo('SetHPos', "set the hostage position: 0=Stand, 1=Kneel, 2=Prone, 3=Foetus, 4=Crouch, 5=Random");
		AddCommandInfo('SetHRoll', "set the hostage reaction roll (0 to disable)");
		AddCommandInfo('resetThreat', "reset threat");
		AddCommandInfo('toggleThreatInfo', "show Threat info");
		AddCommandInfo('regroupHostages', "tell hostages to regroup on me");
		AddCommandInfo(' ', "-- hostage anim player --");
		AddCommandInfo('HLA', "Hostage LIST anim");
		AddCommandInfo('HSA', "Hostage SET anim Index (int index) ");
		AddCommandInfo('HP', "Hostage PLAY anim (0: no loop, 1: loop)");
		AddCommandInfo('HNA', "Hostage NEXT anim ");
		AddCommandInfo('HPA', "Hostage PREVIOUS anim ");
		AddCommandInfo(' ', "-- terrorist-------------");
		AddCommandInfo('CallTerro', "Call terro of a group to the location of the player");
		AddCommandInfo('dbgTerro', "all terro debug dump");
		AddCommandInfo('PlayerInvisible', "toggle Player detection by terrorists");
		AddCommandInfo('tNoThreat', "set all terrorist back to no threat state");
		AddCommandInfo('tSurrender', "toggle display of action spot");
		AddCommandInfo('tRunAway', "toggle display of action spot");
		AddCommandInfo('tSprayFire', "toggle display of action spot");
		AddCommandInfo('tAimedFire', "toggle display of action spot");
		AddCommandInfo('ToggleTerroLog', "toggle terroriste log of AI and PAWN");
		AddCommandInfo('RendSpot', "toggle display of action spot");
		AddCommandInfo(' ', "-- Weapon offset---------");
		AddCommandInfo('WOX', "Add the parameter to the X weapon Offset (move weapon +forward or -backward)");
		AddCommandInfo('WOY', "Add the parameter to the Y weapon Offset (move weapon -right or +left");
		AddCommandInfo('WOZ', "Add the parameter to the X weapon Offset (Move weapon +up or -Down");
		AddCommandInfo('ShowWO', "Display the current weapon offset in the log");
		AddCommandInfo(' ', "-- misc -----------------");
		AddCommandInfo('SetShake', "Activate the camera shake when shooting 1 is true and 0 is false");
		AddCommandInfo('DesignJF', "Weapon jump factor 0 is no jump, 0.5 is half 2 is twice");
		AddCommandInfo('DesignSF', "Weapon return speed factor 0 is no return speed, 0.5 is half 2 is twice");
		AddCommandInfo('ForceKillResult', "Force kill to 1=none 2=wounded 3=incapacited 4=kill and 0 is normal");
		AddCommandInfo('ForceStunResult', "Force stun to 1=none 2=stuned 3=Dazed 4=Knocked out and 0 is normal");
		AddCommandInfo('BulletSpeed', "Set the bullet speed for current weapon (cm/s), < 5000 is really slow and > 50000 is to fast");
		AddCommandInfo('HandDown', "Put left hand down");
		AddCommandInfo('HandUp', "Put left hand up");
		AddCommandInfo('HideWeapon', "Hide the weapon in First Person View");
		AddCommandInfo('ShowWeapon', "Show the weapon in First Person View");
		AddCommandInfo('ToggleHitLog', "turn on/off Show all bullet Hit Logs");
		AddCommandInfo('logActReset', "Log Actors reset");
		AddCommandInfo('logAct', "Log Actors(nb to log)");
		AddCommandInfo('SetBombTimer', "Set bomb timer: X sec");
		AddCommandInfo('SetBombInfo', "info: fExpRadius, fKillRadius, iEnergy");
		AddCommandInfo('GetBombInfo', "get info");
		AddCommandInfo('testBomb', "test bomb: god, objective off.. arm bomb and set time to 5 sec");
		AddCommandInfo(' ', "-- mission objective -----------------");
		AddCommandInfo('ToggleMissionLog', "Toggle Mission Objective Mgr log");
		AddCommandInfo('NeutralizeTerro', "Neutralize all terrorist in the level");
		AddCommandInfo('DisarmBombs', "Disarms all the bombs on the level");
		AddCommandInfo('DeactivateIODevice', "Deactivate IODevice like phone, laptop (ie: plant a bug)");
		AddCommandInfo('RescueHostage', "Rescue all hostages");
		AddCommandInfo('DisableMorality', "Disable morality rules");
		AddCommandInfo('ToggleObjectiveMgr', "Toggle mission objective mgr (the mission will not fail or complete)");
		AddCommandInfo('CompleteMission', "Complete the mission");
		AddCommandInfo('AbortMission', "Abort the mission");
		AddCommandInfo('None', "");
	}
	Log("  -- List all registered function ---------------");
	i = 0;
	J0x1570:

	// End:0x15E7 [Loop If]
	if(((m_aCommandInfo[i].m_functionName != 'None') || (m_aCommandInfo[i].m_szDescription != "")))
	{
		sz = ("" $ string(m_aCommandInfo[i].m_functionName));
		// End:0x15DD
		if((Len(sz) > iSize))
		{
			iSize = Len(sz);
		}
		(i++);
		// [Loop Continue]
		goto J0x1570;
	}
	i = 0;
	szDot = ".................................";
	J0x1617:

	// End:0x16DF [Loop If]
	if(((m_aCommandInfo[i].m_functionName != 'None') || (m_aCommandInfo[i].m_szDescription != "")))
	{
		sz = ("" $ string(m_aCommandInfo[i].m_functionName));
		// End:0x1695
		if((m_aCommandInfo[i].m_functionName == ' '))
		{
			Log(m_aCommandInfo[i].m_szDescription);
			// [Explicit Continue]
			goto J0x16D5;
		}
		Log(((((("" $ sz) $ "") $ Left(szDot, (iSize - Len(sz)))) $ "..: ") $ m_aCommandInfo[i].m_szDescription));
		J0x16D5:

		(i++);
		// [Loop Continue]
		goto J0x1617;
	}
	return;
}

//------------------------------------------------------------------
// AddCommandInfo
//	
//------------------------------------------------------------------
function AddCommandInfo(name functionName, string szDescription)
{
	local int i;

	assert((m_iCommandInfoIndex < 128));
	m_aCommandInfo[m_iCommandInfoIndex].m_szDescription = szDescription;
	m_aCommandInfo[m_iCommandInfoIndex].m_functionName = functionName;
	(m_iCommandInfoIndex++);
	return;
}

//============================================================================
// On off function begin --
exec function PhyStat()
{
	// End:0x0D
	if((!CanExec()))
	{
		return;
	}
	Outer.ConsoleCommand("R6STATS TIMERS PHYSICS");
	return;
}

exec function ToggleRadius()
{
	// End:0x0D
	if((!CanExec()))
	{
		return;
	}
	Outer.ConsoleCommand("ToggleRadius");
	return;
}

exec function BoneCorpse()
{
	// End:0x0D
	if((!CanExec()))
	{
		return;
	}
	m_bRenderBoneCorpse = (!m_bRenderBoneCorpse);
	Outer.Player.Console.Message(("BoneCorpse = " $ string(m_bRenderBoneCorpse)), 6.0000000);
	return;
}

exec function GunDirection()
{
	// End:0x0D
	if((!CanExec()))
	{
		return;
	}
	m_bRenderGunDirection = (!m_bRenderGunDirection);
	Outer.Player.Console.Message(("GunDirection = " $ string(m_bRenderGunDirection)), 6.0000000);
	return;
}

exec function ViewDirection()
{
	// End:0x0D
	if((!CanExec()))
	{
		return;
	}
	m_bRenderViewDirection = (!m_bRenderViewDirection);
	Outer.Player.Console.Message(("GunDirection = " $ string(m_bRenderViewDirection)), 6.0000000);
	return;
}

exec function Route()
{
	// End:0x0D
	if((!CanExec()))
	{
		return;
	}
	m_bRenderRoute = (!m_bRenderRoute);
	Outer.Player.Console.Message(("Draw route = " $ string(m_bRenderRoute)), 6.0000000);
	return;
}

exec function NavPoint()
{
	// End:0x0D
	if((!CanExec()))
	{
		return;
	}
	m_bRenderNavPoint = (!m_bRenderNavPoint);
	Outer.Player.Console.Message(("Draw nav point = " $ string(m_bRenderNavPoint)), 6.0000000);
	return;
}

exec function RouteAll(optional float fDistance)
{
	// End:0x0D
	if((!CanExec()))
	{
		return;
	}
	// End:0x37
	if((fDistance != float(0)))
	{
		Outer.Level.m_fDbgNavPointDistance = fDistance;
	}
	Outer.ConsoleCommand("rend paths");
	Outer.Player.Console.Message((("RouteAll: " $ string(Outer.Level.m_fDbgNavPointDistance)) $ " units"), 6.0000000);
	return;
}

exec function ShowFOV()
{
	local R6Pawn P;

	// End:0x0D
	if((!CanExec()))
	{
		return;
	}
	// End:0xA0
	if(m_bRenderFOV)
	{
		// End:0x9C
		foreach Outer.AllActors(Class'R6Engine.R6Pawn', P)
		{
			// End:0x9B
			if(((!P.m_bIsPlayer) && (P.m_FOV != none)))
			{
				P.DetachFromBone(P.m_FOV);
				P.m_FOV.Destroy();
				P.m_FOV = none;
			}			
		}				
	}
	else
	{
		// End:0x12D
		foreach Outer.AllActors(Class'R6Engine.R6Pawn', P)
		{
			// End:0x12C
			if(((!P.m_bIsPlayer) && P.IsAlive()))
			{
				P.m_FOV = Outer.Spawn(P.m_FOVClass);
				P.AttachToBone(P.m_FOV, 'R6 PonyTail2');
			}			
		}		
	}
	m_bRenderFOV = (!m_bRenderFOV);
	Outer.Player.Console.Message(("ShowFOV = " $ string(m_bRenderFOV)), 6.0000000);
	return;
}

//------------------------------------------------------------------
// ToggleUnlimitedPractice
//	
//------------------------------------------------------------------
exec function ToggleUnlimitedPractice()
{
	local R6AbstractGameInfo GameInfo;

	// End:0x0D
	if((!CanExec()))
	{
		return;
	}
	GameInfo = R6AbstractGameInfo(Outer.Level.Game);
	GameInfo.SetUnlimitedPractice((!GameInfo.IsUnlimitedPractice()), true);
	return;
}

exec function God()
{
	// End:0x0D
	if((!CanExec()))
	{
		return;
	}
	// End:0x28
	if((R6Pawn(Outer.Pawn) == none))
	{
		return;
	}
	Outer.bGodMode = (!Outer.bGodMode);
	R6Pawn(Outer.Pawn).ServerGod(Outer.bGodMode, false, false, Outer.PlayerReplicationInfo.PlayerName, false);
	Outer.Player.Console.Message(__NFUN_112__("God ", string(Outer.bGodMode)), 6.0000000);
	return;
}

exec function GodTeam()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0xE4
	if(Outer.bOnlySpectator)
	{
		// End:0xE1
		if(Outer.ViewTarget.__NFUN_303__('R6Pawn'))
		{
			m_bTeamGodMode = __NFUN_129__(m_bTeamGodMode);
			Outer.bGodMode = m_bTeamGodMode;
			R6Pawn(Outer.ViewTarget).ServerGod(m_bTeamGodMode, true, false, Outer.PlayerReplicationInfo.PlayerName, false);
			Outer.Player.Console.Message(__NFUN_112__("GodTeam ", string(Outer.bGodMode)), 6.0000000);
		}		
	}
	else
	{
		// End:0xFF
		if(__NFUN_114__(R6Pawn(Outer.Pawn), none))
		{
			return;
		}
		m_bTeamGodMode = __NFUN_129__(m_bTeamGodMode);
		R6Pawn(Outer.Pawn).ServerGod(m_bTeamGodMode, true, false, Outer.PlayerReplicationInfo.PlayerName, false);
		Outer.Player.Console.Message(__NFUN_112__("GodTeam ", string(Outer.bGodMode)), 6.0000000);
	}
	return;
}

exec function GodTerro()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x28
	if(__NFUN_114__(R6Pawn(Outer.Pawn), none))
	{
		return;
	}
	R6Pawn(Outer.Pawn).ServerGod(false, false, false, Outer.PlayerReplicationInfo.PlayerName, true);
	Outer.Player.Console.Message("GodTerro", 6.0000000);
	return;
}

exec function GodHostage()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x28
	if(__NFUN_114__(R6Pawn(Outer.Pawn), none))
	{
		return;
	}
	R6Pawn(Outer.Pawn).ServerGod(false, false, true, Outer.PlayerReplicationInfo.PlayerName, false);
	Outer.Player.Console.Message("GodHostage", 6.0000000);
	return;
}

exec function GodAll()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	GodTeam();
	GodHostage();
	return;
}

exec function PerfectAim()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Outer.Pawn.EngineWeapon.PerfectAim();
	return;
}

// kills only all the terrorists and none of your team members
exec function NeutralizeTerro()
{
	local R6Terrorist t;
	local int i;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x72
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Terrorist', t)
	{
		t.ServerForceKillResult(4);
		t.R6TakeDamage(1000, 1000, t, t.Location, vect(0.0000000, 0.0000000, 0.0000000), 0);		
	}	
	Outer.Player.Console.Message(__NFUN_112__("Neutralized terro = ", string(i)), 6.0000000);
	return;
}

// disarms all the bombs on the level
exec function DisarmBombs()
{
	local R6IOBomb bomb;
	local int i;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x50
	foreach Outer.__NFUN_304__(Class'R6Engine.R6IOBomb', bomb)
	{
		bomb.DisarmBomb(R6Pawn(Outer.Pawn));
		__NFUN_165__(i);		
	}	
	Outer.Player.Console.Message(__NFUN_112__("Bomb disarmed = ", string(i)), 6.0000000);
	return;
}

// plant a bug
exec function DeactivateIODevice()
{
	local R6IODevice device;
	local int i;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x50
	foreach Outer.__NFUN_304__(Class'R6Engine.R6IODevice', device)
	{
		device.ToggleDevice(R6Pawn(Outer.Pawn));
		__NFUN_165__(i);		
	}	
	Outer.Player.Console.Message(__NFUN_112__("Deactivated IODevice = ", string(i)), 6.0000000);
	return;
}

exec function ToggleObjectiveMgr()
{
	local R6MissionObjectiveMgr moMgr;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	moMgr = R6AbstractGameInfo(Outer.Level.Game).m_missionMgr;
	moMgr.m_bDontUpdateMgr = __NFUN_129__(moMgr.m_bDontUpdateMgr);
	Outer.Player.Console.Message(__NFUN_112__("Dont update mission objective manager = ", string(moMgr.m_bDontUpdateMgr)), 6.0000000);
	// End:0x11B
	if(__NFUN_129__(moMgr.m_bDontUpdateMgr))
	{
		// End:0x11B
		if(Outer.Level.Game.CheckEndGame(none, ""))
		{
			Outer.Level.Game.EndGame(none, "");
		}
	}
	return;
}

exec function RescueHostage()
{
	local R6Hostage H;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x7E
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Hostage', H)
	{
		// End:0x7D
		if(__NFUN_119__(H.m_controller, none))
		{
			H.m_controller.SetStateExtracted();
			R6AbstractGameInfo(Outer.Level.Game).EnteredExtractionZone(H);
		}		
	}	
	__NFUN_231__("All hostages has been rescued");
	return;
}

exec function DisableMorality()
{
	local R6MissionObjectiveMgr moMgr;
	local int i;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	moMgr = R6AbstractGameInfo(Outer.Level.Game).m_missionMgr;
	J0x38:

	// End:0x94 [Loop If]
	if(__NFUN_150__(i, moMgr.m_aMissionObjectives.Length))
	{
		// End:0x8A
		if(moMgr.m_aMissionObjectives[i].m_bMoralityObjective)
		{
			moMgr.m_aMissionObjectives.Remove(i, 1);			
		}
		else
		{
			__NFUN_163__(i);
		}
		// [Loop Continue]
		goto J0x38;
	}
	Outer.Player.Console.Message("Morality rules removed", 6.0000000);
	return;
}

function DoCompleteMission()
{
	local R6MissionObjectiveMgr moMgr;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6AbstractGameInfo(Outer.Level.Game).CompleteMission();
	Outer.Player.Console.Message("CompleteMission", 6.0000000);
	return;
}

function DoAbortMission()
{
	local R6MissionObjectiveMgr moMgr;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6AbstractGameInfo(Outer.Level.Game).AbortMission();
	Outer.Player.Console.Message("AbortMission", 6.0000000);
	return;
}

exec function KillTerro()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	KillAllPawns(Class'R6Engine.R6Terrorist');
	return;
}

exec function KillHostage()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	KillAllPawns(Class'R6Engine.R6Hostage');
	return;
}

exec function KillRagdoll()
{
	local R6Pawn P;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x75
	foreach Outer.__NFUN_313__(Class'R6Engine.R6Pawn', P)
	{
		// End:0x74
		if(__NFUN_154__(int(P.Physics), int(14)))
		{
			// End:0x68
			if(__NFUN_119__(P.Controller, none))
			{
				P.Controller.__NFUN_279__();
			}
			P.__NFUN_279__();
		}		
	}	
	return;
}

function KillRainbowTeam()
{
	local R6RainbowTeam Team;
	local int i;
	local bool bHuman;

	// End:0xE2
	foreach Outer.__NFUN_304__(Class'R6Engine.R6RainbowTeam', Team)
	{
		bHuman = false;
		i = 0;
		J0x28:

		// End:0xC6 [Loop If]
		if(__NFUN_150__(i, Team.m_iMemberCount))
		{
			// End:0xA6
			if(__NFUN_129__(Team.m_Team[i].m_bIsPlayer))
			{
				Team.m_Team[0] = Team.m_Team[i];
				Team.m_iMemberCount = 1;
				bHuman = true;
				// [Explicit Break]
				goto J0xC6;
				// [Explicit Continue]
				goto J0xBC;
			}
			Team.m_Team[i] = none;
			J0xBC:

			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x28;
		}
		J0xC6:

		// End:0xE1
		if(__NFUN_129__(bHuman))
		{
			Team.m_iMemberCount = 0;
		}		
	}	
	return;
}

exec function KillRainbow()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	KillRainbowTeam();
	KillAllPawns(Class'R6Engine.R6Rainbow');
	return;
}

exec function KillPawns()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	KillRainbowTeam();
	KillAllPawns(Class'Engine.Pawn');
	return;
}

exec function PlayerInvisible()
{
	m_bPlayerInvisble = __NFUN_129__(m_bPlayerInvisble);
	R6PlayerController(Outer.Pawn.Controller).ServerPlayerInvisible(m_bPlayerInvisble);
	return;
}

function DoPlayerInvisible(bool bInvisible)
{
	local R6Terrorist t;

	// End:0x46
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Terrorist', t)
	{
		t.m_bDontHearPlayer = bInvisible;
		t.m_bDontSeePlayer = bInvisible;		
	}	
	Outer.Player.Console.Message(__NFUN_112__("PlayerInvisible = ", string(bInvisible)), 6.0000000);
	return;
}

exec function GiveMag(int iNbOfExtraClips)
{
	local int iWeaponIndex;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x31
	if(__NFUN_155__(int(Outer.Level.NetMode), int(NM_Standalone)))
	{
		return;
	}
	iWeaponIndex = 0;
	J0x38:

	// End:0x7A [Loop If]
	if(__NFUN_150__(iWeaponIndex, 4))
	{
		Outer.Pawn.m_WeaponsCarried[iWeaponIndex].AddClips(iNbOfExtraClips);
		__NFUN_165__(iWeaponIndex);
		// [Loop Continue]
		goto J0x38;
	}
	return;
}

exec function HideAll()
{
	// End:0x49
	if(m_bHideAll)
	{
		m_bHideAll = false;
		R6AbstractHUD(PlayerController(Outer.Pawn.Controller).myHUD).m_iCycleHUDLayer = 0;		
	}
	else
	{
		m_bHideAll = true;
		R6AbstractHUD(PlayerController(Outer.Pawn.Controller).myHUD).m_iCycleHUDLayer = 3;
	}
	R6PlayerController(Outer.Pawn.Controller).m_bUseFirstPersonWeapon = __NFUN_129__(m_bHideAll);
	R6AbstractHUD(PlayerController(Outer.Pawn.Controller).myHUD).m_bToggleHelmet = __NFUN_129__(m_bHideAll);
	R6PlayerController(Outer.Pawn.Controller).m_bHideReticule = m_bHideAll;
	return;
}

exec function ToggleReticule()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6PlayerController(Outer.Pawn.Controller).m_bHideReticule = __NFUN_129__(R6PlayerController(Outer.Pawn.Controller).m_bHideReticule);
	return;
}

//============================================================================
// function tNoThreat - 
//============================================================================
exec function tNoThreat()
{
	local R6TerroristAI t;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x36
	foreach Outer.__NFUN_304__(Class'R6Engine.R6TerroristAI', t)
	{
		t.GotoStateNoThreat();		
	}	
	Outer.Player.Console.Message("Terrorist going back to no threat state", 6.0000000);
	return;
}

//============================================================================
// function tSurrender - 
//============================================================================
exec function tSurrender()
{
	local R6TerroristAI t;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x38
	foreach Outer.__NFUN_304__(Class'R6Engine.R6TerroristAI', t)
	{
		t.m_eEngageReaction = 4;		
	}	
	Outer.Player.Console.Message("All terrorists will surrender", 6.0000000);
	return;
}

//============================================================================
// function tRunAway - 
//============================================================================
exec function tRunAway()
{
	local R6TerroristAI t;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x38
	foreach Outer.__NFUN_304__(Class'R6Engine.R6TerroristAI', t)
	{
		t.m_eEngageReaction = 3;		
	}	
	Outer.Player.Console.Message("All terrorists will run away", 6.0000000);
	return;
}

//============================================================================
// function tSpeed
//============================================================================
exec function tSpeed(float fSpeed)
{
	local R6Terrorist t;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x3B
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Terrorist', t)
	{
		t.m_fWalkingSpeed = fSpeed;		
	}	
	Outer.Player.Console.Message(__NFUN_112__("All terrorists walk at ", string(fSpeed)), 6.0000000);
	return;
}

//============================================================================
// function tSprayFire - 
//============================================================================
exec function tSprayFire()
{
	local R6TerroristAI t;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x38
	foreach Outer.__NFUN_304__(Class'R6Engine.R6TerroristAI', t)
	{
		t.m_eEngageReaction = 2;		
	}	
	Outer.Player.Console.Message("All terrorists will spray fire", 6.0000000);
	return;
}

//============================================================================
// function tAimedFire - 
//============================================================================
exec function tAimedFire()
{
	local R6TerroristAI t;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x38
	foreach Outer.__NFUN_304__(Class'R6Engine.R6TerroristAI', t)
	{
		t.m_eEngageReaction = 1;		
	}	
	Outer.Player.Console.Message("All terrorists will aim fire", 6.0000000);
	return;
}

//============================================================================
// function tTick - 
//============================================================================
exec function tTick(int iTickFrequency)
{
	local R6Terrorist t;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x60
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Terrorist', t)
	{
		t.m_wTickFrequency = byte(iTickFrequency);
		t.m_wNbTickSkipped = byte(RandRange(0.0000000, float(iTickFrequency)));		
	}	
	Outer.Player.Console.Message(__NFUN_112__("Terrorists tick frequency ", string(iTickFrequency)), 6.0000000);
	return;
}

//============================================================================
// function ActorTick - 
//============================================================================
exec function ActorTick(int iTickFrequency)
{
	local Actor A;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_bSkipTick = __NFUN_129__(m_bSkipTick);
	// End:0xA4
	foreach Outer.__NFUN_304__(Class'Engine.Actor', A)
	{
		// End:0x65
		if(__NFUN_129__(m_bSkipTick))
		{
			A.m_bSkipTick = false;
			A.m_bTickOnlyWhenVisible = false;
			// End:0xA3
			continue;
		}
		A.m_bSkipTick = A.default.m_bSkipTick;
		A.m_bTickOnlyWhenVisible = A.default.m_bTickOnlyWhenVisible;		
	}	
	Outer.Player.Console.Message(__NFUN_112__("Actor m_bSkipTick: ", string(m_bSkipTick)), 6.0000000);
	return;
}

//============================================================================
// function ToggleHitLog - 
//============================================================================
exec function ToggleHitLog()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6PlayerController(Outer.Pawn.Controller).m_bShowHitLogs = __NFUN_129__(R6PlayerController(Outer.Pawn.Controller).m_bShowHitLogs);
	return;
}

//============================================================================
// function CallTerro - 
//============================================================================
exec function CallTerro(optional int iGroup)
{
	local R6TerroristAI AI;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0xBC
	foreach Outer.__NFUN_304__(Class'R6Engine.R6TerroristAI', AI)
	{
		// End:0xBB
		if(__NFUN_154__(AI.m_pawn.m_iGroupID, iGroup))
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Calling terrorist ", string(AI.m_pawn)), " to "), string(Outer.Pawn.Location)));
			AI.GotoPointAndSearch(Outer.Pawn.Location, 5, false);
		}		
	}	
	return;
}

//============================================================================
// function UseKarma - 
//============================================================================
exec function UseKarma()
{
	local R6Pawn P;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x48
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Pawn', P)
	{
		P.m_bUseKarmaRagdoll = __NFUN_129__(P.m_bUseKarmaRagdoll);		
	}	
	Outer.Player.Console.Message("Toggled karma use", 6.0000000);
	return;
}

//============================================================================
// function AutoSelect - select a team by default in the gameoptions
//============================================================================
exec function AutoSelect(string _szSelection)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Class'Engine.Actor'.static.__NFUN_1009__().MPAutoSelection = _szSelection;
	return;
}

exec function ToggleWalk()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x42
	if(__NFUN_132__(__NFUN_114__(Outer.Pawn, none), __NFUN_114__(Outer.Pawn.Controller, none)))
	{
		return;
	}
	// End:0x4F
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Walk();
	// End:0x85
	if(m_bFirstPersonPlayerView)
	{
		R6PlayerController(Outer.Pawn.Controller).BehindView(true);
	}
	m_bFirstPersonPlayerView = __NFUN_129__(m_bFirstPersonPlayerView);
	return;
}

//============================================================================
// PostRender - 
//============================================================================
event PostRender(Canvas Canvas)
{
	local R6Pawn P;
	local R6AbstractCorpse corpse;
	local R6AIController C;
	local NavigationPoint np;
	local R6ActionSpot as;
	local Vector vTemp;
	local Controller aController;

	// End:0x129
	if(m_bRendSpot)
	{
		// End:0x128
		foreach Outer.__NFUN_304__(Class'Engine.R6ActionSpot', as)
		{
			vTemp = as.Location;
			Outer.__NFUN_2609__(vTemp, __NFUN_112__("ActionSpot ", string(as.Name)));
			// End:0xA6
			if(as.m_bInvestigate)
			{
				__NFUN_185__(vTemp.Z, float(10));
				Outer.__NFUN_2609__(vTemp, "Investigate");
			}
			// End:0xE7
			if(__NFUN_155__(int(as.m_eCover), int(0)))
			{
				__NFUN_185__(vTemp.Z, float(10));
				Outer.__NFUN_2609__(vTemp, "Cover");
			}
			// End:0x127
			if(__NFUN_155__(int(as.m_eFire), int(0)))
			{
				__NFUN_185__(vTemp.Z, float(10));
				Outer.__NFUN_2609__(vTemp, "Fire");
			}			
		}		
	}
	// End:0x44C
	if(__NFUN_132__(__NFUN_132__(__NFUN_132__(m_bRenderViewDirection, m_bRenderGunDirection), m_bRendPawnState), m_bRendFocus))
	{
		// End:0x44B
		foreach Outer.__NFUN_304__(Class'R6Engine.R6Pawn', P)
		{
			// End:0x44A
			if(__NFUN_130__(__NFUN_180__(P.LastRenderTime, Outer.Level.TimeSeconds), P.IsAlive()))
			{
				// End:0x1C7
				if(m_bRenderViewDirection)
				{
					P.DrawViewRotation(Canvas);
				}
				// End:0x1E4
				if(m_bRenderGunDirection)
				{
					P.RenderGunDirection(Canvas);
				}
				// End:0x369
				if(m_bRendPawnState)
				{
					vTemp = P.Location;
					__NFUN_184__(vTemp.Z, float(90));
					Outer.__NFUN_2609__(vTemp, string(P.Name));
					// End:0x289
					if(__NFUN_255__(P.__NFUN_284__(), P.Class.Name))
					{
						__NFUN_185__(vTemp.Z, float(15));
						Outer.__NFUN_2609__(vTemp, string(P.__NFUN_284__()));
					}
					// End:0x369
					if(__NFUN_119__(P.Controller, none))
					{
						__NFUN_185__(vTemp.Z, float(15));
						Outer.__NFUN_2609__(vTemp, string(P.Controller.__NFUN_284__()));
						// End:0x369
						if(__NFUN_130__(__NFUN_154__(int(P.m_ePawnType), int(2)), __NFUN_132__(P.Controller.__NFUN_281__('MovingTo'), P.Controller.__NFUN_281__('Attack'))))
						{
							__NFUN_185__(vTemp.Z, float(15));
							Outer.__NFUN_2609__(vTemp, R6TerroristAI(P.Controller).m_sDebugString);
						}
					}
				}
				// End:0x44A
				if(m_bRendFocus)
				{
					// End:0x3F1
					if(__NFUN_119__(P.Controller.Focus, none))
					{
						Canvas.__NFUN_2403__(P.Controller.Focus.Location, __NFUN_215__(P.Location, P.EyePosition()), Class'Engine.Canvas'.static.MakeColor(byte(255), 0, 0));
					}
					Canvas.__NFUN_2403__(P.Controller.FocalPoint, __NFUN_215__(P.Location, P.EyePosition()), Class'Engine.Canvas'.static.MakeColor(byte(255), 150, 150));
				}
			}			
		}		
	}
	// End:0x484
	if(m_bRenderBoneCorpse)
	{
		// End:0x483
		foreach Outer.__NFUN_304__(Class'R6Abstract.R6AbstractCorpse', corpse)
		{
			corpse.RenderCorpseBones(Canvas);			
		}		
	}
	// End:0x517
	if(m_bRenderRoute)
	{
		aController = Outer.Level.ControllerList;
		J0x4AA:

		// End:0x517 [Loop If]
		if(__NFUN_119__(aController, none))
		{
			// End:0x500
			if(__NFUN_130__(aController.__NFUN_303__('R6AIController'), R6AIController(aController).m_r6pawn.IsAlive()))
			{
				DrawRoute(R6AIController(aController), Canvas);
			}
			aController = aController.nextController;
			// [Loop Continue]
			goto J0x4AA;
		}
	}
	// End:0x581
	if(m_bRenderNavPoint)
	{
		// End:0x580
		foreach Outer.__NFUN_310__(Class'Engine.NavigationPoint', np, 1000.0000000, Outer.ViewTarget.Location)
		{
			Outer.__NFUN_2609__(np.Location, string(np.Name));			
		}		
	}
	// End:0x595
	if(m_bEnableNavDebug)
	{
		processNavDebug(Canvas);
	}
	// End:0x5A9
	if(m_bTogglePeek)
	{
		processDebugPeek(Canvas);
	}
	// End:0x5BD
	if(m_bTogglePGDebug)
	{
		processDebugPG(Canvas);
	}
	// End:0x5D1
	if(m_bToggleThreatInfo)
	{
		processThreatInfo(Canvas);
	}
	// End:0x5E5
	if(m_bToggleGameInfo)
	{
		displayGameInfo(Canvas);
	}
	return;
}

//------------------------------------------------------------------
// ToggleHostageThreat
//	
//------------------------------------------------------------------
exec function ToggleHostageThreat()
{
	local R6Hostage H;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_bToggleHostageThreat = __NFUN_129__(m_bToggleHostageThreat);
	// End:0x5A
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Hostage', H)
	{
		R6HostageAI(H.Controller).m_bDbgIgnoreThreat = m_bToggleHostageThreat;		
	}	
	return;
}

//------------------------------------------------------------------
// ToggleHostageLog
//	
//------------------------------------------------------------------
exec function ToggleHostageLog()
{
	local R6Hostage H;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_bToggleHostageLog = __NFUN_129__(m_bToggleHostageLog);
	// End:0x9D
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Hostage', H)
	{
		H.bShowLog = m_bToggleHostageLog;
		R6HostageAI(H.Controller).bShowLog = m_bToggleHostageLog;
		R6HostageAI(H.Controller).m_mgr.bShowLog = m_bToggleHostageLog;		
	}	
	return;
}

//------------------------------------------------------------------
// ToggleTerroLog
//	
//------------------------------------------------------------------
exec function ToggleTerroLog()
{
	local R6Terrorist t;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_bToggleTerroLog = __NFUN_129__(m_bToggleTerroLog);
	// End:0x70
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Terrorist', t)
	{
		t.bShowLog = m_bToggleTerroLog;
		R6TerroristAI(t.Controller).bShowLog = m_bToggleTerroLog;		
	}	
	return;
}

//============================================================================
// function RendSpot - 
//============================================================================
exec function RendSpot()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_bRendSpot = __NFUN_129__(m_bRendSpot);
	Outer.Player.Console.Message(__NFUN_112__("RendSpot ", string(m_bRendSpot)), 6.0000000);
	return;
}

exec function TerroInfo()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Outer.ConsoleCommand("RendPawnState");
	Outer.ConsoleCommand("RendFocus");
	Outer.ConsoleCommand("FullAmmo");
	return;
}

//------------------------------------------------------------------
// ToggleRainbowLog
//	
//------------------------------------------------------------------
exec function ToggleRainbowLog()
{
	local R6Rainbow Rainbow;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_bToggleRainbowLog = __NFUN_129__(m_bToggleRainbowLog);
	// End:0x9B
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Rainbow', Rainbow)
	{
		// End:0x9A
		if(__NFUN_129__(Rainbow.m_bIsPlayer))
		{
			R6RainbowAI(Rainbow.Controller).bShowLog = m_bToggleRainbowLog;
			R6RainbowAI(Rainbow.Controller).m_TeamManager.bShowLog = m_bToggleRainbowLog;
		}		
	}	
	return;
}

function name GetNameOfActor(Actor aActor)
{
	// End:0x14
	if(__NFUN_114__(aActor, none))
	{
		return 'None';		
	}
	else
	{
		return aActor.Name;
	}
	return;
}

function Actor GetPointedActor(bool bVerboseLog, bool bTraceActor, optional out Vector vReturnHit, optional bool bForceTrace)
{
	local Actor anActor;
	local string szOutput, szController;
	local Vector vViewDir, vTraceStart, vTraceEnd, vHit, vHitNormal;

	// End:0x38
	if(__NFUN_119__(Outer.ViewTarget, Outer.Pawn))
	{
		anActor = Outer.ViewTarget;		
	}
	else
	{
		vViewDir = Vector(R6Pawn(Outer.Pawn).GetFiringRotation());
		vTraceStart = R6Pawn(Outer.Pawn).GetFiringStartPoint();
		__NFUN_223__(vTraceStart, __NFUN_212__(vViewDir, float(40)));
		vTraceEnd = __NFUN_215__(vTraceStart, __NFUN_213__(float(10000), vViewDir));
		anActor = Outer.__NFUN_277__(vHit, vHitNormal, vTraceEnd, vTraceStart, bTraceActor);
	}
	// End:0x165
	if(__NFUN_130__(__NFUN_130__(__NFUN_119__(anActor, none), __NFUN_119__(Pawn(anActor), none)), __NFUN_119__(Pawn(anActor).Controller, none)))
	{
		szController = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("", string(Pawn(anActor).Controller.Name)), " ("), string(Pawn(anActor).Controller.__NFUN_284__())), ")");		
	}
	else
	{
		szController = "none";
	}
	szOutput = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Actor: ", string(anActor.Name)), "  Controller: "), szController), " class: "), string(anActor.Class));
	__NFUN_231__(szOutput);
	// End:0x2B1
	if(bVerboseLog)
	{
		Outer.Player.Console.Message(__NFUN_112__("Controller: ", szController), 6.0000000);
		Outer.Player.Console.Message(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Actor: ", string(anActor.Name)), " ("), string(anActor.__NFUN_284__())), ")"), 6.0000000);
		Outer.Player.Console.Message(__NFUN_112__("Class: ", string(anActor.Class)), 6.0000000);
	}
	vReturnHit = vHit;
	return anActor;
	return;
}

//------------------------------------------------------------------
// logThis
//	do a dbgLogActor on the client and on the server side
//------------------------------------------------------------------
exec event LogThis(optional bool bDontTraceActor, optional Actor anActor)
{
	// End:0x26
	if(__NFUN_132__(__NFUN_129__(bDontTraceActor), __NFUN_114__(anActor, none)))
	{
		anActor = GetPointedActor(true, true);
	}
	R6PlayerController(Outer.Pawn.Controller).DoDbgLogActor(anActor);
	return;
}

//------------------------------------------------------------------
// dbg the pointed actor
//	
//------------------------------------------------------------------
exec function dbgThis(optional bool bTraceWorld)
{
	local Actor anActor;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	anActor = GetPointedActor(true, __NFUN_129__(bTraceWorld));
	// End:0x45
	if(__NFUN_119__(R6Hostage(anActor), none))
	{
		LogHostage(R6Hostage(anActor));		
	}
	else
	{
		// End:0x68
		if(__NFUN_119__(R6Terrorist(anActor), none))
		{
			LogTerro(R6Terrorist(anActor));			
		}
		else
		{
			// End:0x8B
			if(__NFUN_119__(R6Rainbow(anActor), none))
			{
				LogRainbow(R6Rainbow(anActor));				
			}
			else
			{
				// End:0xAB
				if(__NFUN_119__(R6IOBomb(anActor), none))
				{
					LogIOBomb(R6IOBomb(anActor));
				}
			}
		}
	}
	return;
}

exec function dbgEdit(optional bool bTraceWorld)
{
	local string szCmd;
	local Actor anActor;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	anActor = GetPointedActor(true, __NFUN_129__(bTraceWorld));
	szCmd = __NFUN_112__("editactor Actor=", string(anActor.Name));
	Outer.ConsoleCommand(szCmd);
	return;
}

function LogR6Pawn(R6Pawn P)
{
	local Controller AI;
	local R6AIController r6ai;
	local R6PlayerController PController;
	local name aiName;
	local string szTemp;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	AI = P.Controller;
	// End:0x40
	if(__NFUN_119__(AI, none))
	{
		aiName = AI.Name;
	}
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("== ", string(P.Name)), " ai: "), string(aiName)), " ==============="));
	__NFUN_231__(__NFUN_112__("   Location.............: ", string(P.Location)));
	__NFUN_231__(__NFUN_112__("   Pawn state...........: ", string(P.__NFUN_284__())));
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   Coll. Height, Radius.: ", string(P.CollisionHeight)), ", "), string(P.CollisionRadius)));
	switch(P.Physics)
	{
		// End:0x149
		case 0:
			szTemp = "None";
			// End:0x1BA
			break;
		// End:0x160
		case 1:
			szTemp = "Walking";
			// End:0x1BA
			break;
		// End:0x177
		case 2:
			szTemp = "Falling";
			// End:0x1BA
			break;
		// End:0x18F
		case 5:
			szTemp = "Rotating";
			// End:0x1BA
			break;
		// End:0x1A5
		case 11:
			szTemp = "Ladder";
			// End:0x1BA
			break;
		// End:0xFFFF
		default:
			szTemp = "Unknown";
			// End:0x1BA
			break;
			break;
	}
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   Physics..............: ", szTemp), " ("), string(P.Physics)), ")"));
	switch(P.m_eMovementPace)
	{
		// End:0x220
		case 0:
			szTemp = "None";
			// End:0x2A4
			break;
		// End:0x235
		case 1:
			szTemp = "Prone";
			// End:0x2A4
			break;
		// End:0x24F
		case 2:
			szTemp = "CrouchWalk";
			// End:0x2A4
			break;
		// End:0x268
		case 3:
			szTemp = "CrouchRun";
			// End:0x2A4
			break;
		// End:0x27C
		case 4:
			szTemp = "Walk";
			// End:0x2A4
			break;
		// End:0x28F
		case 5:
			szTemp = "Run";
			// End:0x2A4
			break;
		// End:0xFFFF
		default:
			szTemp = "Unknown";
			// End:0x2A4
			break;
			break;
	}
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   m_eMovementPace......: ", szTemp), " ("), string(P.m_eMovementPace)), ")"));
	switch(P.m_eHealth)
	{
		// End:0x30A
		case 3:
			szTemp = "Dead";
			// End:0x36A
			break;
		// End:0x327
		case 2:
			szTemp = "Incapacitated";
			// End:0x36A
			break;
		// End:0x33E
		case 1:
			szTemp = "Wounded";
			// End:0x36A
			break;
		// End:0x355
		case 0:
			szTemp = "Healthy";
			// End:0x36A
			break;
		// End:0xFFFF
		default:
			szTemp = "Unknown";
			// End:0x36A
			break;
			break;
	}
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   Health...............: ", szTemp), " ("), string(P.m_eHealth)), ")"));
	__NFUN_231__(__NFUN_112__("   m_bPostureTransition.: ", string(P.m_bPostureTransition)));
	__NFUN_231__(__NFUN_112__("   bIsWalking...........: ", __NFUN_128__(string(P.bIsWalking), 4)));
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   IsPeeking............: ", string(P.IsPeeking())), " left: "), string(P.IsPeekingLeft())), " rate()= "), string(P.GetPeekingRate())));
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   bIsCrouched..........: ", __NFUN_128__(string(P.bIsCrouched), 4)), ",   bWantsToCrouch.......: "), __NFUN_128__(string(P.bWantsToCrouch), 4)));
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   m_bIsProne...........: ", __NFUN_128__(string(P.m_bIsProne), 4)), ",   m_bWantsToProne......: "), __NFUN_128__(string(P.m_bWantsToProne), 4)));
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   m_bIsClimbingStairs..: ", __NFUN_128__(string(P.m_bIsClimbingStairs), 4)), ",   m_bIsMovingUpStairs..: "), __NFUN_128__(string(P.m_bIsMovingUpStairs), 4)));
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   m_bAutoClimbLadders..: ", __NFUN_128__(string(P.m_bAutoClimbLadders), 4)), ",   m_bIsClimbingLadder..: "), __NFUN_128__(string(P.m_bIsClimbingLadder), 4)));
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   m_bAvoidFacingWalls..: ", __NFUN_128__(string(P.m_bAvoidFacingWalls), 4)), ",   m_bCanClimbObject....: "), __NFUN_128__(string(P.m_bCanClimbObject), 4)));
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   m_bUseRagdoll........: ", string(P.m_bUseRagdoll)), " ("), string(P.m_ragdoll)), ")"));
	__NFUN_231__(__NFUN_112__("   bCanWalkOffLedges....: ", string(P.bCanWalkOffLedges)));
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   m_bCanDisarmBomb.....: ", __NFUN_128__(string(P.m_bCanDisarmBomb), 4)), ",   m_bCanArmBomb........: "), __NFUN_128__(string(P.m_bCanArmBomb), 4)));
	__NFUN_231__(__NFUN_112__("   m_iTeam..............: ", string(P.m_iTeam)));
	__NFUN_231__(__NFUN_112__("   m_ladder.............: ", string(P.m_Ladder)));
	// End:0xB1A
	if(__NFUN_119__(AI, none))
	{
		__NFUN_231__(__NFUN_112__("   ** ai state..........: ", string(AI.__NFUN_284__())));
		switch(AI.m_eMoveToResult)
		{
			// End:0x83F
			case 0:
				szTemp = "None";
				// End:0x881
				break;
			// End:0x856
			case 1:
				szTemp = "Success";
				// End:0x881
				break;
			// End:0x86C
			case 2:
				szTemp = "Failed";
				// End:0x881
				break;
			// End:0xFFFF
			default:
				szTemp = "Unknown";
				// End:0x881
				break;
				break;
		}
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   m_eMoveToResult......: ", szTemp), " ("), string(AI.m_eMoveToResult)), ")"));
		__NFUN_231__(__NFUN_112__("   MoveTarget...........: ", string(GetNameOfActor(AI.MoveTarget))));
		__NFUN_231__(__NFUN_112__("   Enemy................: ", string(GetNameOfActor(AI.Enemy))));
		__NFUN_231__(__NFUN_112__("   bRotateToDesired.....: ", string(P.bRotateToDesired)));
		__NFUN_231__(__NFUN_112__("   Focus................: ", string(GetNameOfActor(AI.Focus))));
		__NFUN_231__(__NFUN_112__("   FocalPoint...........: ", string(AI.FocalPoint)));
		__NFUN_231__(__NFUN_112__("   m_bCrawl.............: ", string(AI.m_bCrawl)));
		__NFUN_231__(__NFUN_112__("   Can reach a navpoint.: ", string(AI.__NFUN_525__(true))));
		r6ai = R6AIController(P.Controller);
		// End:0xB17
		if(__NFUN_119__(r6ai, none))
		{
			__NFUN_231__(__NFUN_112__("   m_BumpedBy...........: ", string(GetNameOfActor(r6ai.m_BumpedBy))));
			__NFUN_231__(__NFUN_112__("   m_bIgnoreBackupBump..: ", string(r6ai.m_bIgnoreBackupBump)));
			__NFUN_231__(__NFUN_112__("   m_climbingObject.....: ", string(GetNameOfActor(r6ai.m_climbingObject))));
			__NFUN_231__(__NFUN_112__("   m_ActorTarget........: ", string(r6ai.m_ActorTarget)));
		}		
	}
	else
	{
		__NFUN_231__("    no controller");
	}
	PController = R6PlayerController(P.Controller);
	// End:0xD30
	if(__NFUN_119__(PController, none))
	{
		__NFUN_231__(__NFUN_112__("   ** PlayerController......: ", string(PController.__NFUN_284__())));
		// End:0xBC4
		if(__NFUN_154__(int(P.m_ePeekingMode), int(1)))
		{
			__NFUN_231__("   Peeking..............: Full ");			
		}
		else
		{
			// End:0xC03
			if(__NFUN_154__(int(P.m_ePeekingMode), int(2)))
			{
				__NFUN_231__("   Peeking..............: Fluid");				
			}
			else
			{
				__NFUN_231__("   Peeking..............: none");
			}
		}
		__NFUN_231__(__NFUN_112__("   m_bPeekingLeft ......: ", string(P.m_bPeekingLeft)));
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   m_fPeeking...........: ", string(P.m_fPeeking)), " / "), string(P.1000.0000000)));
		__NFUN_231__(__NFUN_112__("   m_fLastValidPeeking..: ", string(P.m_fLastValidPeeking)));
		__NFUN_231__(__NFUN_112__("   m_bPeekingToCenter...: ", string(P.m_bPeekingReturnToCenter)));
		__NFUN_231__(__NFUN_112__("   m_fCrouchBlendRate...: ", string(P.m_fCrouchBlendRate)));
	}
	return;
}

function LogHostage(R6Hostage H)
{
	local R6HostageAI AI;
	local int i;
	local name aiName, lastSeenPawnName, escortName, terroristName;
	local Vector vPlayerLoc;
	local bool bFastTrace;
	local name animSeq;
	local float AnimRate, AnimFrame;

	AI = R6HostageAI(H.Controller);
	// End:0x117
	if(__NFUN_119__(AI, none))
	{
		aiName = AI.Name;
		// End:0x69
		if(__NFUN_119__(AI.m_terrorist, none))
		{
			terroristName = AI.m_terrorist.Name;
		}
		// End:0xB5
		if(__NFUN_119__(AI.m_pawnToFollow, none))
		{
			bFastTrace = Outer.__NFUN_548__(AI.m_pawnToFollow.Location, H.Location);
		}
		// End:0xE6
		if(__NFUN_119__(AI.m_lastSeenPawn, none))
		{
			lastSeenPawnName = AI.m_lastSeenPawn.Name;
		}
		// End:0x117
		if(__NFUN_119__(AI.m_escort, none))
		{
			escortName = AI.m_escort.Name;
		}
	}
	// End:0x170
	if(__NFUN_130__(__NFUN_119__(Outer.Pawn, none), Outer.Pawn.Controller.__NFUN_303__('R6PlayerController')))
	{
		vPlayerLoc = Outer.Pawn.Location;
	}
	LogR6Pawn(H);
	// End:0x6D2
	if(__NFUN_119__(AI, none))
	{
		__NFUN_231__(__NFUN_168__("   UsedTemplate.........: ", H.m_szUsedTemplate));
		__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_168__(__NFUN_168__("   Rainbow (following)..: ", string(GetNameOfActor(H.m_escortedByRainbow))), " ("), string(GetNameOfActor(AI.m_pawnToFollow))), ")"));
		__NFUN_231__(__NFUN_168__("   ForceToStayHere......: ", string(AI.m_bForceToStayHere)));
		__NFUN_231__(__NFUN_168__("   Distance from human..: ", string(__NFUN_225__(__NFUN_216__(vPlayerLoc, H.Location)))));
		__NFUN_231__(__NFUN_168__("   FastTrace............: ", string(bFastTrace)));
		__NFUN_231__(__NFUN_168__("   RunningToward........: ", string(AI.m_bRunningToward)));
		__NFUN_231__(__NFUN_168__("   RunToRainbowSuccess..: ", string(AI.m_bRunToRainbowSuccess)));
		__NFUN_231__(__NFUN_168__("   bNeedToRunToCatchUp..: ", string(AI.m_bNeedToRunToCatchUp)));
		__NFUN_231__(__NFUN_168__("   bStopDoTransition....: ", string(AI.m_bStopDoTransition)));
		__NFUN_231__(__NFUN_168__("   Freed................: ", string(H.m_bFreed)));
		__NFUN_231__(__NFUN_168__("   Personality..........: ", string(H.m_ePersonality)));
		__NFUN_231__(__NFUN_168__("   Position.............: ", string(H.m_ePosition)));
		__NFUN_231__(__NFUN_168__("   Start as civilian....: ", string(H.m_bStartAsCivilian)));
		__NFUN_231__(__NFUN_168__("   Hands Up.............: ", string(H.m_eHandsUpType)));
		__NFUN_231__(__NFUN_168__("   ThreatInfo...........: ", AI.m_mgr.GetThreatInfoLog(AI.m_threatInfo)));
		__NFUN_231__(__NFUN_168__("   LastSeenPawn.........: ", string(lastSeenPawnName)));
		__NFUN_231__(__NFUN_168__("   Escorted.............: ", string(H.m_bEscorted)));
		__NFUN_231__(__NFUN_168__("   Escorted by..........: ", string(escortName)));
		__NFUN_231__(__NFUN_168__("   Escorted by terro....: ", string(terroristName)));
		__NFUN_231__(__NFUN_168__("   dbgIgnoreThreat......: ", string(AI.m_bDbgIgnoreThreat)));
		__NFUN_231__(__NFUN_168__("   m_bSlowedPace........: ", string(AI.m_bSlowedPace)));
		__NFUN_231__(__NFUN_168__("   m_bFollowIncreaseDist: ", string(AI.m_bFollowIncreaseDistance)));
		__NFUN_231__(__NFUN_168__("   m_bExtracted.........: ", string(H.m_bExtracted)));
		__NFUN_231__(__NFUN_168__("   m_bEscorted..........: ", string(H.m_bEscorted)));
		__NFUN_231__(__NFUN_168__("   Number of orders.....: ", string(AI.m_iNbOrder)));
		i = 0;
		J0x66D:

		// End:0x6D2 [Loop If]
		if(__NFUN_150__(i, AI.m_iNbOrder))
		{
			__NFUN_231__(__NFUN_168__("                          ", AI.Order_GetLog(AI.m_aOrderInfo[i])));
			__NFUN_163__(i);
			// [Loop Continue]
			goto J0x66D;
		}
	}
	return;
}

exec function DbgHostage()
{
	local int Num;
	local R6Hostage H;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	__NFUN_231__("-- ALL HOSTAGE DUMP --");
	// End:0x53
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Hostage', H)
	{
		LogHostage(H);
		__NFUN_163__(Num);		
	}	
	__NFUN_231__(__NFUN_168__(__NFUN_168__("   ", string(Num)), " hostage(s)"));
	return;
}

function InitTestHostageAnim()
{
	local R6Hostage H;

	// End:0x4C
	if(__NFUN_129__(m_bHostageTestAnim))
	{
		// End:0x43
		foreach Outer.__NFUN_304__(Class'R6Engine.R6Hostage', H)
		{
			R6HostageAI(H.Controller).__NFUN_113__('DbgHostage');			
		}		
		m_bHostageTestAnim = true;
	}
	return;
}

function HostageSetAnimIndex(int increment)
{
	local R6Hostage H;
	local R6HostageAI AI;
	local R6HostageMgr mgr;
	local int i;

	mgr = R6HostageMgr(Outer.Level.GetHostageMgr());
	__NFUN_161__(m_iHostageTestAnimIndex, increment);
	// End:0x6D
	if(__NFUN_154__(m_iHostageTestAnimIndex, mgr.GetAnimInfoSize()))
	{
		__NFUN_231__("TestHostageAnim: index = 0");
		m_iHostageTestAnimIndex = 0;
	}
	HP();
	return;
}

//------------------------------------------------------------------
// Hostage list anim
//	
//------------------------------------------------------------------
exec function HLA()
{
	local AnimInfo AnimInfo;
	local R6HostageMgr mgr;
	local int i;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	mgr = R6HostageMgr(Outer.Level.GetHostageMgr());
	i = 0;
	J0x37:

	// End:0xCC [Loop If]
	if(__NFUN_150__(i, mgr.GetAnimInfoSize()))
	{
		AnimInfo = mgr.GetAnimInfo(i);
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("", string(i)), ": "), string(AnimInfo.m_name)), " rate: "), string(AnimInfo.m_fRate)), " play type: "), string(AnimInfo.m_ePlayType)));
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x37;
	}
	__NFUN_231__(__NFUN_112__("  total hostage anim: ", string(mgr.GetAnimInfoSize())));
	return;
}

//------------------------------------------------------------------
// hostage Play Anim
//	
//------------------------------------------------------------------
exec function HP(optional bool bLoop)
{
	local R6Hostage H;
	local R6HostageAI AI;
	local AnimInfo AnimInfo;
	local bool bFound;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	bFound = false;
	InitTestHostageAnim();
	// End:0x178
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Hostage', H)
	{
		AI = R6HostageAI(H.Controller);
		// End:0x10C
		if(__NFUN_129__(bFound))
		{
			AnimInfo = AI.m_mgr.GetAnimInfo(m_iHostageTestAnimIndex);
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("play anim: ", string(AnimInfo.m_name)), " rate: "), string(AnimInfo.m_fRate)), " play type: "), string(AnimInfo.m_ePlayType)), " ("), string(m_iHostageTestAnimIndex)), "/"), string(AI.m_mgr.GetAnimInfoSize())), ")"));
			bFound = true;
		}
		H.R6LoopAnim('None', 1.0000000);
		// End:0x154
		if(bLoop)
		{
			H.R6LoopAnim(AnimInfo.m_name, AnimInfo.m_fRate);
			// End:0x177
			continue;
		}
		H.R6PlayAnim(AnimInfo.m_name, AnimInfo.m_fRate);		
	}	
	return;
}

//------------------------------------------------------------------
// hostage Next Anim
//	
//------------------------------------------------------------------
exec function HNA()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	HostageSetAnimIndex(1);
	return;
}

//------------------------------------------------------------------
// hostage Previous Anim
//	
//------------------------------------------------------------------
exec function HPA()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	HostageSetAnimIndex(-1);
	return;
}

//------------------------------------------------------------------
// hostage Set Anim ( index )
//	
//------------------------------------------------------------------
exec function HSA(int Index)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_iHostageTestAnimIndex = Index;
	HostageSetAnimIndex(0);
	return;
}

//============================================================================
// function dbgActor - 
//============================================================================
exec function dbgActor()
{
	local Actor A;
	local int Num;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	__NFUN_231__("-- ALL ACTOR DUMP --");
	// End:0x1A6
	foreach Outer.__NFUN_304__(Class'Engine.Actor', A)
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(string(A.Name), " current state :  "), string(A.__NFUN_284__())));
		__NFUN_231__(__NFUN_112__("   position....................: ", string(A.Location)));
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   bCollideActor, bCollideWorld: ", string(A.bCollideActors)), ", "), string(A.bCollideWorld)));
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   bBlockActors, bProjTarget...: ", string(A.bBlockActors)), ", "), string(A.bProjTarget)));
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   collision radius, height....: ", string(A.CollisionRadius)), ", "), string(A.CollisionHeight)));
		__NFUN_165__(Num);		
	}	
	__NFUN_231__(__NFUN_112__(__NFUN_112__("   ", string(Num)), " actors"));
	return;
}

//============================================================================
// LogRainbow - 
//============================================================================
function LogRainbow(R6Rainbow rb)
{
	LogR6Pawn(rb);
	__NFUN_231__(__NFUN_112__("   m_bSlideEnd..........: ", string(rb.m_bSlideEnd)));
	__NFUN_231__(__NFUN_112__("   m_bMovingDiagonally..: ", __NFUN_128__(string(rb.m_bMovingDiagonally), 5)));
	__NFUN_231__(__NFUN_112__("   m_rRotationOffset....: ", string(rb.m_rRotationOffset)));
	__NFUN_231__(__NFUN_112__("   R6 Bone Rotation.....: ", string(rb.GetBoneRotation('R6'))));
	__NFUN_231__(__NFUN_112__("   Pelvis  Rotation.....: ", string(rb.GetBoneRotation('R6 Pelvis'))));
	return;
}

function LogIOBomb(R6IOBomb bomb)
{
	__NFUN_231__(__NFUN_112__("IOBomb: ", string(bomb)));
	__NFUN_231__(__NFUN_112__("  m_bIsActivated..: ", string(bomb.m_bIsActivated)));
	__NFUN_231__(__NFUN_112__("  CanToggle().....: ", string(bomb.CanToggle())));
	__NFUN_231__(__NFUN_112__("  m_bExploded.....: ", string(bomb.m_bExploded)));
	__NFUN_231__(__NFUN_112__("  m_fTimeLeft.....: ", string(bomb.m_fTimeLeft)));
	__NFUN_231__(__NFUN_112__("  m_fRepTimeLeft..: ", string(bomb.m_fRepTimeLeft)));
	__NFUN_231__(__NFUN_112__("  GetTimeLeft()...: ", string(bomb.GetTimeLeft())));
	return;
}

//============================================================================
// LogTerro - 
//============================================================================
function LogTerro(R6Terrorist t)
{
	local R6TerroristAI AI;
	local string szTemp;

	AI = R6TerroristAI(t.Controller);
	LogR6Pawn(t);
	__NFUN_231__(" -- Terrorist info --");
	__NFUN_231__(__NFUN_112__("   Used Template........: ", t.m_szUsedTemplate));
	__NFUN_231__(__NFUN_112__("   m_DZone..............: ", string(t.m_DZone.Name)));
	// End:0xFD
	if(__NFUN_119__(t.m_HeadAttachment, none))
	{
		__NFUN_231__(__NFUN_112__("   Attachment mesh......: ", string(t.m_HeadAttachment.StaticMesh.Name)));		
	}
	else
	{
		__NFUN_231__("   Attachment mesh......: None");
	}
	switch(t.m_ePersonality)
	{
		// End:0x14B
		case 0:
			szTemp = "PERSO_Coward";
			// End:0x1F9
			break;
		// End:0x16B
		case 1:
			szTemp = "PERSO_DeskJockey";
			// End:0x1F9
			break;
		// End:0x187
		case 2:
			szTemp = "PERSO_Normal";
			// End:0x1F9
			break;
		// End:0x1A5
		case 3:
			szTemp = "PERSO_Hardened";
			// End:0x1F9
			break;
		// End:0x1C8
		case 4:
			szTemp = "PERSO_SuicideBomber";
			// End:0x1F9
			break;
		// End:0x1E4
		case 5:
			szTemp = "PERSO_Sniper";
			// End:0x1F9
			break;
		// End:0xFFFF
		default:
			szTemp = "Unknown";
			// End:0x1F9
			break;
			break;
	}
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   Personality..........: ", szTemp), " ("), string(t.m_ePersonality)), ")"));
	__NFUN_231__(__NFUN_112__("   FiringStartPoint.....: ", string(t.GetFiringStartPoint())));
	__NFUN_231__(__NFUN_112__("   FiringDirection......: ", string(t.GetFiringRotation())));
	__NFUN_231__(__NFUN_112__("   Group ID.............: ", string(t.m_iGroupID)));
	__NFUN_231__(__NFUN_112__("   Current attack team..: ", string(AI.m_iCurrentGroupID)));
	switch(t.m_ePlayerIsUsingHands)
	{
		// End:0x321
		case 0:
			szTemp = "None";
			// End:0x373
			break;
		// End:0x336
		case 1:
			szTemp = "Right";
			// End:0x373
			break;
		// End:0x34A
		case 2:
			szTemp = "Left";
			// End:0x373
			break;
		// End:0x35E
		case 3:
			szTemp = "Both";
			// End:0x373
			break;
		// End:0xFFFF
		default:
			szTemp = "Unknown";
			// End:0x373
			break;
			break;
	}
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   PlayerIsUsingHands...: ", szTemp), " ("), string(t.m_ePlayerIsUsingHands)), ")"));
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("    Assault.............: ", string(int(__NFUN_171__(t.m_fSkillAssault, float(100))))), ",    Demolitions.........: "), string(int(__NFUN_171__(t.m_fSkillDemolitions, float(100))))));
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("    Electronics.........: ", string(int(__NFUN_171__(t.m_fSkillElectronics, float(100))))), ",    SSniper.............: "), string(int(__NFUN_171__(t.m_fSkillSniper, float(100))))));
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("    Stealth.............: ", string(int(__NFUN_171__(t.m_fSkillStealth, float(100))))), ",    SelfControl.........: "), string(int(__NFUN_171__(t.m_fSkillSelfControl, float(100))))));
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("    Leadership..........: ", string(int(__NFUN_171__(t.m_fSkillLeadership, float(100))))), ",    Observation.........: "), string(int(__NFUN_171__(t.m_fSkillObservation, float(100))))));
	__NFUN_231__(__NFUN_112__("     Skills modifier.....: ", string(t.SkillModifier())));
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   m_bAllowLeave........: ", __NFUN_128__(string(t.m_bAllowLeave), 4)), ",   m_bHaveAGrenade......: "), __NFUN_128__(string(t.m_bHaveAGrenade), 4)));
	// End:0x92B
	if(__NFUN_119__(AI, none))
	{
		__NFUN_231__("  -See and Hear variable:-");
		switch(AI.m_eReactionStatus)
		{
			// End:0x66C
			case 0:
				szTemp = "HearAndSeeAll";
				// End:0x707
				break;
			// End:0x686
			case 1:
				szTemp = "SeeHostage";
				// End:0x707
				break;
			// End:0x6A0
			case 2:
				szTemp = "HearBullet";
				// End:0x707
				break;
			// End:0x6BA
			case 3:
				szTemp = "SeeRainbow";
				// End:0x707
				break;
			// End:0x6D1
			case 4:
				szTemp = "Grenade";
				// End:0x707
				break;
			// End:0x6F2
			case 5:
				szTemp = "HearAndSeeNothing";
				// End:0x707
				break;
			// End:0xFFFF
			default:
				szTemp = "Unknown";
				// End:0x707
				break;
				break;
		}
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   ReactionState........: ", szTemp), " ("), string(AI.m_eReactionStatus)), ")"));
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   SeePlayer............: ", __NFUN_128__(string(__NFUN_129__(t.m_bDontSeePlayer)), 4)), ",   HearPlayer...........: "), __NFUN_128__(string(__NFUN_129__(t.m_bDontHearPlayer)), 4)));
		__NFUN_231__(__NFUN_112__("   m_eStateForEvent.....: ", __NFUN_128__(string(AI.m_eStateForEvent), 4)));
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   m_bHearInvestigate...: ", __NFUN_128__(string(AI.m_bHearInvestigate), 4)), ",   m_bSeeHostage........: "), __NFUN_128__(string(AI.m_bSeeHostage), 4)));
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   m_bHearThreat........: ", __NFUN_128__(string(AI.m_bHearThreat), 4)), ",   m_bSeeRainbow........: "), __NFUN_128__(string(AI.m_bSeeRainbow), 4)));
		__NFUN_231__(__NFUN_112__("   m_bHearGrenade.......: ", __NFUN_128__(string(AI.m_bHearGrenade), 4)));
		__NFUN_231__(__NFUN_112__("   m_eStrategy..........: ", __NFUN_128__(string(t.m_eStrategy), 4)));
	}
	return;
}

//============================================================================
// function dbgRainbow - 
//============================================================================
exec function dbgRainbow()
{
	local R6Rainbow rb;
	local int Num;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	__NFUN_231__("-- ALL RAINBOW DUMP --");
	// End:0x53
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Rainbow', rb)
	{
		LogRainbow(rb);
		__NFUN_165__(Num);		
	}	
	__NFUN_231__(__NFUN_112__(__NFUN_112__("   ", string(Num)), " rainbow"));
	return;
}

//============================================================================
// function dbgTerro - 
//============================================================================
exec function dbgTerro()
{
	local R6Terrorist t;
	local int Num;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	__NFUN_231__("-- ALL TERRO DUMP --");
	// End:0x51
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Terrorist', t)
	{
		LogTerro(t);
		__NFUN_165__(Num);		
	}	
	__NFUN_231__(__NFUN_112__(__NFUN_112__("   ", string(Num)), " terrorists"));
	return;
}

//------------------------------------------------------------------
// SetPawn : set the current pawn
//------------------------------------------------------------------
exec function SetPawn()
{
	local Actor anActor;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	anActor = GetPointedActor(false, true);
	// End:0x8B
	if(__NFUN_119__(R6Pawn(anActor), none))
	{
		m_curPawn = R6Pawn(anActor);
		Outer.Player.Console.Message(__NFUN_112__("ESCORTED: ", string(m_curPawn.Controller.Name)), 6.0000000);		
	}
	else
	{
		m_curPawn = none;
	}
	return;
}

exec function string SetPawnPace(int i, optional bool bHelp)
{
	local string Text;

	// End:0x0E
	if(__NFUN_129__(CanExec()))
	{
		return "";
	}
	// End:0x62
	if(bHelp)
	{
		return "Set m_eMovementPace 0=none 1=prone 2=crouchwalk 3=crouchrun 4=walk 5=run";
	}
	// End:0x9C
	if(__NFUN_114__(m_curPawn, none))
	{
		Outer.Player.Console.Message("no pawn", 6.0000000);
	}
	switch(i)
	{
		// End:0xD0
		case 0:
			m_curPawn.m_eMovementPace = m_curPawn.0;
			Text = "none";
			// End:0x1C3
			break;
		// End:0xFE
		case 1:
			m_curPawn.m_eMovementPace = m_curPawn.1;
			Text = "prone";
			// End:0x1C3
			break;
		// End:0x132
		case 2:
			m_curPawn.m_eMovementPace = m_curPawn.2;
			Text = "crouchwalk";
			// End:0x1C3
			break;
		// End:0x165
		case 3:
			m_curPawn.m_eMovementPace = m_curPawn.3;
			Text = "crouchrun";
			// End:0x1C3
			break;
		// End:0x193
		case 4:
			m_curPawn.m_eMovementPace = m_curPawn.4;
			Text = "walk";
			// End:0x1C3
			break;
		// End:0x1C0
		case 5:
			m_curPawn.m_eMovementPace = m_curPawn.5;
			Text = "run";
			// End:0x1C3
			break;
		// End:0xFFFF
		default:
			break;
	}
	Outer.Player.Console.Message(__NFUN_112__("eMovementPace=", Text), 6.0000000);
	return "";
	return;
}

exec function SeeCurPawn()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x1A
	if(__NFUN_114__(m_curPawn, none))
	{
		return;
	}
	// End:0x45
	if(Outer.__NFUN_533__(m_curPawn))
	{
		__NFUN_231__("SeePawn: success");		
	}
	else
	{
		__NFUN_231__("SeePawn: fail");
	}
	return;
}

//------------------------------------------------------------------
// UsePath
//------------------------------------------------------------------
exec function UsePath(int i)
{
	local R6Pawn.eMovementPace ePace;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x49
	if(__NFUN_114__(m_curPawn, none))
	{
		Outer.Player.Console.Message("no pawn", 6.0000000);
		return;
	}
	Outer.Player.Console.Message("Use path", 6.0000000);
	// End:0xBE
	if(__NFUN_154__(i, 1))
	{
		// End:0xAA
		if(m_curPawn.bIsCrouched)
		{
			ePace = m_curPawn.3;			
		}
		else
		{
			ePace = m_curPawn.5;
		}		
	}
	else
	{
		// End:0xE4
		if(m_curPawn.bIsCrouched)
		{
			ePace = m_curPawn.2;			
		}
		else
		{
			ePace = m_curPawn.4;
		}
	}
	R6AIController(m_curPawn.Controller).SetStateTestMakePath(Outer.Pawn, ePace);
	return;
}

//------------------------------------------------------------------
// CanWalk
//------------------------------------------------------------------
exec function CanWalk()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x49
	if(__NFUN_114__(m_curPawn, none))
	{
		Outer.Player.Console.Message("no pawn", 6.0000000);
		return;
	}
	// End:0xCB
	if(R6AIController(m_curPawn.Controller).__NFUN_1815__(Outer.Pawn.Location, true))
	{
		Outer.Player.Console.Message("CanWalkTo: true", 6.0000000);
		__NFUN_231__("CanWalkTo: true");		
	}
	else
	{
		Outer.Player.Console.Message("CanWalkTo: false", 6.0000000);
		__NFUN_231__("CanWalkTo: false");
	}
	return;
}

//------------------------------------------------------------------
// TestFindPathToMe
//------------------------------------------------------------------
exec function TestFindPathToMe()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x49
	if(__NFUN_114__(m_curPawn, none))
	{
		Outer.Player.Console.Message("no pawn", 6.0000000);
		return;
	}
	// End:0xB9
	if(__NFUN_114__(R6AIController(m_curPawn.Controller).__NFUN_517__(Outer.Pawn, true), none))
	{
		Outer.Player.Console.Message("FindPathToward: failed", 6.0000000);		
	}
	else
	{
		Outer.Player.Console.Message("FindPathToward: ok", 6.0000000);
	}
	// End:0x168
	if(__NFUN_114__(R6AIController(m_curPawn.Controller).__NFUN_518__(Outer.Pawn.Location, true), none))
	{
		Outer.Player.Console.Message("FindPathTo: failed", 6.0000000);		
	}
	else
	{
		Outer.Player.Console.Message("FindPathTo: ok", 6.0000000);
	}
	return;
}

//------------------------------------------------------------------
// MoveEscort
//------------------------------------------------------------------
exec function MoveEscort()
{
	local Vector vHit;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x49
	if(__NFUN_114__(m_curPawn, none))
	{
		Outer.Player.Console.Message("no pawn", 6.0000000);
		return;
	}
	// End:0x106
	if(__NFUN_119__(R6Hostage(m_curPawn), none))
	{
		GetPointedActor(false, true, vHit);
		__NFUN_184__(vHit.Z, __NFUN_172__(m_curPawn.CollisionHeight, float(2)));
		R6HostageAI(m_curPawn.Controller).SetStateEscorted(R6Pawn(Outer.Pawn), vHit, false);
		// End:0x106
		if(R6Hostage(m_curPawn).m_bEscorted)
		{
			Outer.Player.Console.Message("MOVE ESCORT", 6.0000000);
		}
	}
	Outer.Player.Console.Message("MOVE FAILED", 6.0000000);
	return;
}

//------------------------------------------------------------------
// SetPState: set the pawn's state
//	
//------------------------------------------------------------------
exec function SetPState(name stateToGo)
{
	// End:0x0D
	if(__NFUN_114__(m_curPawn, none))
	{
		return;
	}
	// End:0x1A
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_curPawn.__NFUN_113__(stateToGo);
	return;
}

//------------------------------------------------------------------
// SetCState: set the controller's state
//------------------------------------------------------------------
exec function SetCState(name stateToGo)
{
	// End:0x0D
	if(__NFUN_114__(m_curPawn, none))
	{
		return;
	}
	// End:0x1A
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_curPawn.__NFUN_113__(stateToGo);
	return;
}

//------------------------------------------------------------------
// SetHPos: set hostage position
//------------------------------------------------------------------
exec function SetHPos(int iPos)
{
	local R6Hostage.EStartingPosition ePos;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x1F
	if(__NFUN_114__(R6Hostage(m_curPawn), none))
	{
		return;
	}
	switch(iPos)
	{
		// End:0x35
		case 1:
			ePos = 1;
			// End:0x80
			break;
		// End:0x45
		case 2:
			ePos = 2;
			// End:0x80
			break;
		// End:0x55
		case 3:
			ePos = 3;
			// End:0x80
			break;
		// End:0x65
		case 4:
			ePos = 4;
			// End:0x80
			break;
		// End:0x75
		case 5:
			ePos = 5;
			// End:0x80
			break;
		// End:0xFFFF
		default:
			ePos = 0;
			break;
	}
	R6HostageAI(m_curPawn.Controller).SetPawnPosition(ePos);
	return;
}

exec function SetHRoll(int iRoll)
{
	local R6Hostage H;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x50
	if(__NFUN_154__(iRoll, 0))
	{
		Outer.Player.Console.Message("Roll disable ", 6.0000000);		
	}
	else
	{
		Outer.Player.Console.Message(__NFUN_112__("Roll: ", string(iRoll)), 6.0000000);
	}
	// End:0x143
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Hostage', H)
	{
		R6HostageAI(H.Controller).m_bDbgRoll = __NFUN_155__(iRoll, 0);
		R6HostageAI(H.Controller).m_iDbgRoll = iRoll;
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("SetHRoll:", string(R6HostageAI(H.Controller).m_bDbgRoll)), " iRoll: "), string(R6HostageAI(H.Controller).m_iDbgRoll)));		
	}	
	return;
}

//------------------------------------------------------------------
// Shake Parameters Cheats
//------------------------------------------------------------------
exec function DesignSF(float NewSpeedFactor)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6PlayerController(Outer.Pawn.Controller).m_fDesignerSpeedFactor = NewSpeedFactor;
	return;
}

exec function DesignJF(float NewJumpFactor)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6PlayerController(Outer.Pawn.Controller).m_fDesignerJumpFactor = NewJumpFactor;
	return;
}

exec function SetShake(bool bSet)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6PlayerController(Outer.Pawn.Controller).m_bShakeActive = bSet;
	return;
}

exec function DesignMaxRand(int NewMax)
{
	local R6Pawn CurrentPawn;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x3B
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Pawn', CurrentPawn)
	{
		CurrentPawn.m_iDesignRandomTweak = NewMax;		
	}	
	return;
}

exec function DesignArmor(int Light, int Medium, int Heavy)
{
	local R6Pawn CurrentPawn;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x63
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Pawn', CurrentPawn)
	{
		CurrentPawn.m_iDesignLightTweak = Light;
		CurrentPawn.m_iDesignMediumTweak = Medium;
		CurrentPawn.m_iDesignHeavyTweak = Heavy;		
	}	
	return;
}

exec function DesignToggleLog()
{
	local R6Pawn CurrentPawn;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x48
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Pawn', CurrentPawn)
	{
		CurrentPawn.m_bDesignToggleLog = __NFUN_129__(CurrentPawn.m_bDesignToggleLog);		
	}	
	return;
}

exec function DesignHBS(float fRange)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Outer.Pawn.EngineWeapon.SetHeartBeatRange(fRange);
	return;
}

//------------------------------------------------------------------
// Hostage / Civilian debugger
//	
//------------------------------------------------------------------
exec function hHelp()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	__NFUN_231__("Hostage / Civ Debugger");
	__NFUN_231__("======================");
	__NFUN_231__("  hReset.......: reset current hostage ptr");
	__NFUN_231__("  hLog.........: log hostage");
	__NFUN_231__("  hCiv.........: set to civilian");
	__NFUN_231__("  hHostage.....: set to hostage 0=Stand 1=Kneel");
	__NFUN_231__("  hPos.........: set position: 0=Stand, 1=Kneel, 2=Prone, 3=Foetus, 4=Crouch, 5=Random");
	__NFUN_231__("  hReact.......: react (Civ: 0=CivProne, 1=CivRunTowardRainbow, 2=CivRunForCover");
	__NFUN_231__("  hReact.......: react (hostage: anim index from 0 to 2 ");
	__NFUN_231__("  hFreeze......: go freeze");
	__NFUN_231__("  hHurt........: set health to hurt ");
	__NFUN_231__("  hWalkAnim....: set walk anim: 0=default 1=scared");
	__NFUN_231__("  hGre.........: play grenade reaction anim: 0=reset 1=blinded 2=gas");
	return;
}

function hDebugLog(string sz)
{
	__NFUN_231__(__NFUN_112__("hDebug: ", sz));
	return;
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
exec function hReset()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_Hostage = none;
	return;
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
exec function hLog()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x1A
	if(__NFUN_129__(hInit()))
	{
		return;
	}
	LogHostage(m_Hostage);
	return;
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
exec function bool hInit()
{
	local int iClosest;
	local R6Hostage H, hostage;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return false;
	}
	// End:0x1A
	if(__NFUN_119__(m_Hostage, none))
	{
		return true;
	}
	iClosest = 999999;
	hostage = none;
	// End:0xB7
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Hostage', H)
	{
		// End:0xB6
		if(__NFUN_176__(__NFUN_225__(__NFUN_216__(Outer.Pawn.Location, H.Location)), float(iClosest)))
		{
			iClosest = int(__NFUN_225__(__NFUN_216__(Outer.Pawn.Location, H.Location)));
			hostage = H;
		}		
	}	
	// End:0xFD
	if(__NFUN_114__(hostage, none))
	{
		Outer.Player.Console.Message("no hostage found", 6.0000000);
		return false;
	}
	Outer.Player.Console.Message(__NFUN_112__("found: ", string(hostage.Name)), 6.0000000);
	m_Hostage = hostage;
	m_Hostage.m_controller.m_bDbgIgnoreThreat = true;
	m_Hostage.m_controller.m_bDbgIgnoreRainbow = true;
	return true;
	return;
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
exec function hCiv()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x1A
	if(__NFUN_129__(hInit()))
	{
		return;
	}
	hDebugLog("CivInit");
	m_Hostage.m_controller.CivInit();
	return;
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
exec function hHostage(int iPos)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x1A
	if(__NFUN_129__(hInit()))
	{
		return;
	}
	// End:0x6C
	if(__NFUN_154__(iPos, 1))
	{
		hDebugLog("Hostage: kneel");
		m_Hostage.m_controller.SetStateGuarded(1, m_Hostage.m_mgr.9);		
	}
	else
	{
		hDebugLog("Hostage: standing");
		m_Hostage.m_controller.SetStateGuarded(0, m_Hostage.m_mgr.9);
	}
	return;
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
exec function hPos(int iPos)
{
	local R6Hostage.EStartingPosition ePos;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x1A
	if(__NFUN_129__(hInit()))
	{
		return;
	}
	switch(iPos)
	{
		// End:0x51
		case 1:
			ePos = 1;
			hDebugLog("SetPawnPosition: kneeling");
			// End:0x138
			break;
		// End:0x7F
		case 2:
			ePos = 2;
			hDebugLog("SetPawnPosition: prone");
			// End:0x138
			break;
		// End:0xAE
		case 3:
			ePos = 3;
			hDebugLog("SetPawnPosition: foetus");
			// End:0x138
			break;
		// End:0xDD
		case 4:
			ePos = 4;
			hDebugLog("SetPawnPosition: crouch");
			// End:0x138
			break;
		// End:0x10C
		case 5:
			ePos = 5;
			hDebugLog("SetPawnPosition: random");
			// End:0x138
			break;
		// End:0xFFFF
		default:
			ePos = 0;
			hDebugLog("SetPawnPosition: standing");
			break;
	}
	m_Hostage.m_controller.SetPawnPosition(ePos);
	return;
}

exec function hGre(int iGrenade)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x1A
	if(__NFUN_129__(hInit()))
	{
		return;
	}
	switch(iGrenade)
	{
		// End:0x37
		case 1:
			m_Hostage.PlayBlinded();
			// End:0x74
			break;
		// End:0x4E
		case 2:
			m_Hostage.PlayCoughing();
			// End:0x74
			break;
		// End:0xFFFF
		default:
			m_Hostage.EndOfGrenadeEffect(Outer.Pawn.2);
			break;
	}
	return;
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
exec function hReact(int iReact)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x1A
	if(__NFUN_129__(hInit()))
	{
		return;
	}
	// End:0x10E
	if(m_Hostage.m_controller.__NFUN_281__('Civilian'))
	{
		m_Hostage.m_controller.m_threatInfo.m_pawn = Outer.Pawn;
		// End:0xA4
		if(__NFUN_154__(iReact, 1))
		{
			hDebugLog("CivRunTowardRainbow");
			m_Hostage.m_controller.__NFUN_113__('CivRunTowardRainbow');			
		}
		else
		{
			// End:0xE2
			if(__NFUN_154__(iReact, 2))
			{
				hDebugLog("CivRunForCover");
				m_Hostage.m_controller.__NFUN_113__('CivRunForCover');				
			}
			else
			{
				hDebugLog("CivProne");
				m_Hostage.m_controller.__NFUN_113__('CivProne');
			}
		}		
	}
	else
	{
		// End:0x22D
		if(m_Hostage.isStandingHandUp())
		{
			// End:0x17D
			if(__NFUN_154__(iReact, 1))
			{
				hDebugLog("ANIM_eStandHandUpReact02");
				m_Hostage.SetAnimInfo(m_Hostage.m_controller.m_mgr.ANIM_eStandHandUpReact02);				
			}
			else
			{
				// End:0x1DB
				if(__NFUN_154__(iReact, 2))
				{
					hDebugLog("ANIM_eStandHandUpReact03");
					m_Hostage.SetAnimInfo(m_Hostage.m_controller.m_mgr.ANIM_eStandHandUpReact03);					
				}
				else
				{
					hDebugLog("ANIM_eStandHandUpReact01");
					m_Hostage.SetAnimInfo(m_Hostage.m_controller.m_mgr.ANIM_eStandHandUpReact01);
				}
			}			
		}
		else
		{
			// End:0x341
			if(__NFUN_154__(int(m_Hostage.m_ePosition), int(1)))
			{
				// End:0x29D
				if(__NFUN_154__(iReact, 1))
				{
					hDebugLog("ANIM_eKneelReact02");
					m_Hostage.SetAnimInfo(m_Hostage.m_controller.m_mgr.ANIM_eKneelReact02);					
				}
				else
				{
					// End:0x2F5
					if(__NFUN_154__(iReact, 2))
					{
						hDebugLog("ANIM_eKneelReact03");
						m_Hostage.SetAnimInfo(m_Hostage.m_controller.m_mgr.ANIM_eKneelReact03);						
					}
					else
					{
						hDebugLog("ANIM_eKneelReact01");
						m_Hostage.SetAnimInfo(m_Hostage.m_controller.m_mgr.ANIM_eKneelReact01);
					}
				}				
			}
			else
			{
				Outer.Player.Console.Message("can't play react", 6.0000000);
			}
		}
	}
	return;
}

//------------------------------------------------------------------
// hFreeze: 
//------------------------------------------------------------------
exec function hFreeze()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x1A
	if(__NFUN_129__(hInit()))
	{
		return;
	}
	// End:0x80
	if(__NFUN_132__(m_Hostage.isStandingHandUp(), __NFUN_154__(int(m_Hostage.m_ePosition), int(1))))
	{
		hDebugLog("State: Guarded_frozen");
		m_Hostage.m_controller.__NFUN_113__('Guarded_frozen');		
	}
	else
	{
		Outer.Player.Console.Message("can't go freeze", 6.0000000);
	}
	return;
}

//------------------------------------------------------------------
// hHurt
//------------------------------------------------------------------
exec function hHurt()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x1A
	if(__NFUN_129__(hInit()))
	{
		return;
	}
	m_Hostage.m_eHealth = 1;
	hWalkAnim(1);
	return;
}

//------------------------------------------------------------------
// hWalkAnim
//------------------------------------------------------------------
exec function hWalkAnim(int i)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x1A
	if(__NFUN_129__(hInit()))
	{
		return;
	}
	// End:0x43
	if(__NFUN_154__(i, 1))
	{
		m_Hostage.SetStandWalkingAnim(m_Hostage.1, true);		
	}
	else
	{
		m_Hostage.SetStandWalkingAnim(m_Hostage.0, true);
	}
	return;
}

//============================================================================
// function DrawRoute - 
//============================================================================
simulated function DrawRoute(R6AIController r6con, Canvas Canvas)
{
	local int i;
	local Vector vTemp;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0xBE
	if(__NFUN_119__(r6con.RouteCache[0], none))
	{
		i = 1;
		J0x2A:

		// End:0xBE [Loop If]
		if(__NFUN_130__(__NFUN_150__(i, 16), __NFUN_119__(r6con.RouteCache[i], none)))
		{
			Canvas.__NFUN_2403__(r6con.RouteCache[__NFUN_147__(i, 1)].Location, r6con.RouteCache[i].Location, Class'Engine.Canvas'.static.MakeColor(byte(255), byte(255), 0));
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x2A;
		}
	}
	// End:0x12A
	if(__NFUN_218__(r6con.Destination, vect(0.0000000, 0.0000000, 0.0000000)))
	{
		Canvas.__NFUN_2403__(r6con.Pawn.Location, r6con.Destination, Class'Engine.Canvas'.static.MakeColor(byte(255), byte(255), byte(255)));
	}
	// End:0x15E
	if(__NFUN_119__(r6con.Focus, none))
	{
		vTemp = r6con.Focus.Location;		
	}
	else
	{
		vTemp = r6con.FocalPoint;
	}
	Canvas.__NFUN_2403__(__NFUN_215__(r6con.Pawn.Location, r6con.Pawn.EyePosition()), vTemp, Class'Engine.Canvas'.static.MakeColor(byte(255), 0, 0));
	return;
}

// RotateMe "R6 Spine" pitch yaw roll
exec function RotateMe(name BoneName, int Pitch, int Yaw, int Roll, float InTime)
{
	local Rotator rOffset;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	rOffset.Pitch = Pitch;
	rOffset.Yaw = Yaw;
	rOffset.Roll = Roll;
	R6Pawn(Outer.Pawn).SetBoneRotation(BoneName, rOffset,, 1.0000000, InTime);
	__NFUN_231__(__NFUN_112__("RotateMe", string(BoneName)));
	return;
}

exec function ResetMeAll()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6Pawn(Outer.Pawn).ResetBoneRotation();
	R6Pawn(Outer.Pawn).SetBoneRotation('R6 Head', rot(0, 0, 0),, 1.0000000, 0.4000000);
	R6Pawn(Outer.Pawn).SetBoneRotation('R6 Neck', rot(0, 0, 0),, 1.0000000, 0.4000000);
	R6Pawn(Outer.Pawn).SetBoneRotation('R6 Spine', rot(0, 0, 0),, 1.0000000, 0.4000000);
	R6Pawn(Outer.Pawn).SetBoneRotation('R6 Spine1', rot(0, 0, 0),, 1.0000000, 0.4000000);
	R6Pawn(Outer.Pawn).SetBoneRotation('R6 Pelvis', rot(0, 0, 0),, 1.0000000, 0.4000000);
	return;
}

//------------------------------------------------------------------
// toggleNav
//	
//------------------------------------------------------------------
exec function toggleNav()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_bEnableNavDebug = __NFUN_129__(m_bEnableNavDebug);
	Outer.Player.Console.Message(__NFUN_112__("EnableNavPointDebug = ", string(m_bEnableNavDebug)), 6.0000000);
	// End:0x73
	if(m_bEnableNavDebug)
	{
		ToggleRadius();
	}
	return;
}

//------------------------------------------------------------------
// processNavDebug: when enabled, it check if there's a nav point
//  accessible from the player location.
//------------------------------------------------------------------
function processNavDebug(Canvas C)
{
	local Actor Path;
	local bool bFound;
	local string szName;
	local int i;
	local Vector vLoc;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x47
	if(__NFUN_132__(__NFUN_114__(Outer.Pawn, none), __NFUN_155__(int(Outer.Pawn.Physics), int(1))))
	{
		return;
	}
	Path = Outer.__NFUN_525__(true);
	// End:0x1D0
	if(__NFUN_114__(Path, none))
	{
		i = 0;
		J0x6C:

		// End:0xF9 [Loop If]
		if(__NFUN_150__(i, m_aNavPointLocation.Length))
		{
			vLoc = m_aNavPointLocation[i];
			// End:0xEF
			if(__NFUN_130__(Outer.__NFUN_548__(vLoc, Outer.Pawn.Location), __NFUN_176__(__NFUN_225__(__NFUN_216__(Outer.Pawn.Location, vLoc)), m_fNavPointDistance)))
			{
				bFound = true;
				// [Explicit Break]
				goto J0xF9;
			}
			__NFUN_163__(i);
			// [Loop Continue]
			goto J0x6C;
		}
		J0xF9:

		// End:0x1D0
		if(__NFUN_129__(bFound))
		{
			m_aNavPointLocation[m_iCurNavPoint] = Outer.Pawn.Location;
			szName = __NFUN_112__("Need NavPoint: ", string(m_iCurNavPoint));
			Outer.Pawn.__NFUN_1506__(Outer.Pawn.Location, vect(40.0000000, 40.0000000, 80.0000000), __NFUN_146__(10, m_iCurNavPoint), szName);
			__NFUN_231__(szName);
			Outer.Player.Console.Message(__NFUN_112__("**** ", szName), 10.0000000);
			__NFUN_165__(m_iCurNavPoint);
		}
	}
	return;
}

//============================================================================
// function KillThemAll - 
//============================================================================
exec function KillThemAll()
{
	local R6Pawn P;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x8F
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Pawn', P)
	{
		// End:0x8E
		if(__NFUN_129__(P.m_bIsPlayer))
		{
			P.ServerForceKillResult(4);
			P.R6TakeDamage(1000, 1000, Outer.Pawn, P.Location, vect(0.0000000, 0.0000000, 0.0000000), 0);
		}		
	}	
	return;
}

exec function dbgPeek()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_bTogglePeek = __NFUN_129__(m_bTogglePeek);
	Outer.Player.Console.Message(__NFUN_112__("DbgPeek = ", string(m_bTogglePeek)), 6.0000000);
	return;
}

function processDebugPeek(Canvas Canvas)
{
	local int YPos, YL;
	local R6Pawn P;
	local string szPeek;
	local Rotator rRotator;

	// End:0x3A
	if(__NFUN_132__(__NFUN_114__(Outer.Pawn, none), __NFUN_155__(int(Outer.Pawn.Physics), int(1))))
	{
		return;
	}
	Canvas.__NFUN_2626__(0, byte(255), 0);
	P = R6Pawn(Outer.ViewTarget);
	YPos = 350;
	YL = 10;
	Canvas.__NFUN_2623__(4.0000000, float(YPos));
	Canvas.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__("IsPeeking:  ", string(P.IsPeeking())), " Left: "), string(P.IsPeekingLeft())));
	__NFUN_161__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, float(YPos));
	Canvas.__NFUN_465__(__NFUN_112__("   m_fCrouchBlendRate= ", string(P.m_fCrouchBlendRate)));
	__NFUN_161__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, float(YPos));
	Canvas.__NFUN_465__(__NFUN_112__("   GetPeekingRate()= ", string(P.GetPeekingRate())));
	__NFUN_161__(YPos, YL);
	// End:0x1C7
	if(__NFUN_154__(int(P.m_ePeekingMode), int(2)))
	{
		szPeek = "fluid";		
	}
	else
	{
		// End:0x1EC
		if(__NFUN_154__(int(P.m_ePeekingMode), int(1)))
		{
			szPeek = "full";
		}
	}
	Canvas.__NFUN_2623__(4.0000000, float(YPos));
	Canvas.__NFUN_465__(__NFUN_112__("   m_ePeekingMode= ", szPeek));
	__NFUN_161__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, float(YPos));
	Canvas.__NFUN_465__(__NFUN_112__("   m_fPeekingGoal= ", string(P.m_fPeekingGoal)));
	__NFUN_161__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, float(YPos));
	Canvas.__NFUN_465__(__NFUN_112__("   m_fPeeking= ", string(P.m_fPeeking)));
	__NFUN_161__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, float(YPos));
	Canvas.__NFUN_465__(__NFUN_112__("   m_fLastValidPeeking= ", string(P.m_fLastValidPeeking)));
	__NFUN_161__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, float(YPos));
	Canvas.__NFUN_465__(__NFUN_112__("   m_bPeekingReturnToCenter= ", string(P.m_bPeekingReturnToCenter)));
	__NFUN_161__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, float(YPos));
	Canvas.__NFUN_465__(__NFUN_112__("   bIsCrouched= ", string(P.bIsCrouched)));
	__NFUN_161__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, float(YPos));
	Canvas.__NFUN_465__(__NFUN_112__("   PrepivotZ= ", string(P.PrePivot.Z)));
	__NFUN_161__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, float(YPos));
	Canvas.__NFUN_465__(__NFUN_112__("   PrePivotProneBackupZ= ", string(P.m_vPrePivotProneBackup.Z)));
	__NFUN_161__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, float(YPos));
	rRotator = P.GetBoneRotation('R6');
	Canvas.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   r6 bone y= ", string(rRotator.Yaw)), " p="), string(rRotator.Pitch)));
	__NFUN_161__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, float(YPos));
	Canvas.__NFUN_465__(__NFUN_112__("   m_rRotationOffset= ", string(P.m_rRotationOffset)));
	__NFUN_161__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, float(YPos));
	Canvas.__NFUN_465__(__NFUN_112__("   m_bPostureTransition= ", string(P.m_bPostureTransition)));
	__NFUN_161__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, float(YPos));
	Canvas.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   m_bPeekLeft= ", string(R6PlayerController(Outer.Pawn.Controller).m_bPeekLeft)), " m_bPeekRight="), string(R6PlayerController(Outer.Pawn.Controller).m_bPeekRight)));
	__NFUN_161__(YPos, YL);
	return;
}

exec function resetThreat()
{
	local R6HostageAI AI;
	local R6Hostage H;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x67
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Hostage', H)
	{
		AI = R6HostageAI(H.Controller);
		AI.m_threatInfo = AI.m_mgr.getDefaulThreatInfo();		
	}	
	return;
}

exec function toggleThreatInfo()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_bToggleThreatInfo = __NFUN_129__(m_bToggleThreatInfo);
	return;
}

function processThreatInfo(Canvas Canvas)
{
	local int YPos, YL;
	local R6Pawn P;
	local R6HostageAI AI;
	local R6Hostage H;

	Canvas.__NFUN_2626__(0, byte(255), 0);
	YPos = 100;
	YL = 16;
	// End:0xBF
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Hostage', H)
	{
		AI = R6HostageAI(H.Controller);
		Canvas.__NFUN_2623__(4.0000000, float(YPos));
		Canvas.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__("", string(AI)), " "), AI.m_mgr.GetThreatInfoLog(AI.m_threatInfo)));
		__NFUN_161__(YPos, YL);		
	}	
	return;
}

function processDebugPG(Canvas Canvas)
{
	local int YPos, YL;
	local R6Pawn P;
	local R6HostageAI AI;
	local R6Hostage H;

	// End:0x16
	if(__NFUN_114__(Outer.Pawn, none))
	{
		return;
	}
	Canvas.__NFUN_2626__(0, byte(255), 0);
	P = R6Pawn(Outer.Pawn);
	YPos = 300;
	YL = 16;
	// End:0xF1
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Hostage', H)
	{
		AI = R6HostageAI(H.Controller);
		Canvas.__NFUN_2623__(4.0000000, float(YPos));
		Canvas.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__("", string(AI)), " "), AI.m_mgr.GetThreatInfoLog(AI.m_threatInfo)));
		__NFUN_161__(YPos, YL);		
	}	
	return;
}

exec function sgi(int iLevel)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	ShowGameInfo(iLevel);
	return;
}

exec function ShowGameInfo(int iLevel)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_bToggleGameInfo = __NFUN_129__(m_bToggleGameInfo);
	m_iGameInfoLevel = iLevel;
	return;
}

//------------------------------------------------------------------
// displayMissionObjective
//	
//------------------------------------------------------------------
function displayMissionObjective(int iVerbose, Canvas C, int YL, int XPos, out int YPos, out int iLine, R6MissionObjectiveBase mo, out int iSubGroup)
{
	local int i, iSubLine;
	local string szIndent, szDesc, szDescID;
	local bool bDisplay, bDisplayFailure;

	// End:0x29
	if(__NFUN_151__(iSubGroup, 0))
	{
		szIndent = __NFUN_112__(__NFUN_112__("   (", string(iSubGroup)), ") ");		
	}
	else
	{
		szIndent = "   ";
	}
	// End:0xFA
	if(__NFUN_153__(iVerbose, 1))
	{
		// End:0xF7
		if(mo.m_bVisibleInMenu)
		{
			bDisplay = true;
			// End:0xA0
			if(__NFUN_122__(mo.m_szDescriptionInMenu, ""))
			{
				szDesc = "warning: m_szDescriptionInMenu is empty";				
			}
			else
			{
				szDesc = __NFUN_112__(__NFUN_112__(__NFUN_112__("", mo.m_szDescriptionInMenu), "= "), Localize("Game", mo.m_szDescriptionInMenu, Outer.Level.GetMissionObjLocFile(mo)));
			}
		}		
	}
	else
	{
		bDisplay = true;
		szDesc = mo.getDescription();
	}
	// End:0x25A
	if(bDisplay)
	{
		C.__NFUN_2623__(float(XPos), float(YPos));
		// End:0x1A2
		if(mo.isCompleted())
		{
			C.__NFUN_2626__(0, byte(255), 0);
			C.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("", szIndent), ""), string(iLine)), "- "), szDesc), " : completed"));			
		}
		else
		{
			// End:0x207
			if(mo.isFailed())
			{
				C.__NFUN_2626__(byte(255), 0, 0);
				C.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("", szIndent), ""), string(iLine)), "- "), szDesc), " : failed"));				
			}
			else
			{
				C.__NFUN_2626__(byte(255), byte(255), byte(255));
				C.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("", szIndent), ""), string(iLine)), "- "), szDesc));
			}
		}
		__NFUN_161__(YPos, YL);
	}
	// End:0x339
	if(__NFUN_153__(iVerbose, 2))
	{
		C.__NFUN_2623__(float(XPos), float(YPos));
		// End:0x339
		if(__NFUN_123__(mo.m_szDescriptionFailure, ""))
		{
			C.__NFUN_2626__(0, byte(255), 0);
			C.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("", szIndent), ""), string(iLine)), " ("), mo.m_szDescriptionFailure), "= "), Localize("Game", mo.m_szDescriptionFailure, Outer.Level.GetMissionObjLocFile(mo))), ")"));
			__NFUN_161__(YPos, YL);
			bDisplay = true;
		}
	}
	// End:0x349
	if(bDisplay)
	{
		__NFUN_163__(iLine);
	}
	// End:0x3DA
	if(__NFUN_151__(mo.GetNumSubMission(), 0))
	{
		__NFUN_165__(iSubGroup);
		i = 0;
		J0x36C:

		// End:0x3DA [Loop If]
		if(__NFUN_150__(i, mo.GetNumSubMission()))
		{
			iSubLine = __NFUN_146__(i, 1);
			displayMissionObjective(iVerbose, C, YL, XPos, YPos, iSubLine, mo.GetSubMissionObjective(i), iSubGroup);
			__NFUN_163__(i);
			// [Loop Continue]
			goto J0x36C;
		}
	}
	return;
}

function displayGameInfo(Canvas C)
{
	local int XPos, YPos, YL;
	local R6MissionObjectiveMgr moMgr;
	local int i, iLine;
	local bool bMoralityObj;
	local int iSubGroup, iDiffLevel;

	YPos = 90;
	XPos = 10;
	YL = 13;
	C.Font = C.MedFont;
	C.__NFUN_2623__(float(XPos), float(YPos));
	C.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__("GameMode = ", Outer.Level.GetGameTypeClassName(R6AbstractGameInfo(Outer.Level.Game).m_szGameTypeFlag)), " m_bGameOver="), string(R6AbstractGameInfo(Outer.Level.Game).m_bGameOver)));
	__NFUN_161__(YPos, YL);
	iDiffLevel = -1;
	// End:0x149
	if(__NFUN_119__(R6AbstractGameInfo(Outer.Level.Game), none))
	{
		iDiffLevel = R6AbstractGameInfo(Outer.Level.Game).m_iDiffLevel;		
	}
	else
	{
		// End:0x17F
		if(__NFUN_119__(Outer.GameReplicationInfo, none))
		{
			iDiffLevel = R6GameReplicationInfo(Outer.GameReplicationInfo).m_iDiffLevel;
		}
	}
	// End:0x275
	if(__NFUN_155__(iDiffLevel, -1))
	{
		C.__NFUN_2623__(float(XPos), float(YPos));
		switch(iDiffLevel)
		{
			// End:0x1DF
			case 1:
				C.__NFUN_465__("Diffilculty level: recruit ");
				// End:0x269
				break;
			// End:0x210
			case 2:
				C.__NFUN_465__("Diffilculty level: veteran ");
				// End:0x269
				break;
			// End:0x23E
			case 3:
				C.__NFUN_465__("Diffilculty level: elite");
				// End:0x269
				break;
			// End:0xFFFF
			default:
				C.__NFUN_465__("Diffilculty level: unknown");
				break;
		}
		__NFUN_161__(YPos, YL);
	}
	moMgr = R6AbstractGameInfo(Outer.Level.Game).m_missionMgr;
	// End:0x2AD
	if(__NFUN_114__(moMgr, none))
	{
		return;
	}
	// End:0x330
	if(__NFUN_154__(int(moMgr.m_eMissionObjectiveStatus), int(1)))
	{
		C.__NFUN_2626__(0, byte(255), 0);
		C.__NFUN_2623__(float(XPos), float(YPos));
		C.__NFUN_465__("-- MISSION OBJECTIVE: COMPLETED");
		__NFUN_161__(YPos, YL);		
	}
	else
	{
		// End:0x3B0
		if(__NFUN_154__(int(moMgr.m_eMissionObjectiveStatus), int(2)))
		{
			C.__NFUN_2626__(byte(255), 0, 0);
			C.__NFUN_2623__(float(XPos), float(YPos));
			C.__NFUN_465__("-- MISSION OBJECTIVE: FAILED");
			__NFUN_161__(YPos, YL);			
		}
		else
		{
			C.__NFUN_2626__(byte(255), byte(255), byte(255));
			C.__NFUN_2623__(float(XPos), float(YPos));
			C.__NFUN_465__("-- MISSION OBJECTIVE: in progress ");
			__NFUN_161__(YPos, YL);
		}
	}
	i = 0;
	J0x425:

	// End:0x4BA [Loop If]
	if(__NFUN_150__(i, moMgr.m_aMissionObjectives.Length))
	{
		// End:0x4A8
		if(__NFUN_129__(moMgr.m_aMissionObjectives[i].m_bMoralityObjective))
		{
			iSubGroup = 0;
			displayMissionObjective(m_iGameInfoLevel, C, YL, XPos, YPos, iLine, moMgr.m_aMissionObjectives[i], iSubGroup);
			// [Explicit Continue]
			goto J0x4B0;
		}
		bMoralityObj = true;
		J0x4B0:

		__NFUN_163__(i);
		// [Loop Continue]
		goto J0x425;
	}
	// End:0x52E
	if(bMoralityObj)
	{
		C.__NFUN_2626__(byte(255), byte(255), byte(255));
		C.__NFUN_2623__(float(XPos), float(YPos));
		C.__NFUN_465__("-- MISSION OBJECTIVE: morality ");
		__NFUN_161__(YPos, YL);
	}
	iLine = 0;
	i = 0;
	J0x53C:

	// End:0x5BD [Loop If]
	if(__NFUN_150__(i, moMgr.m_aMissionObjectives.Length))
	{
		// End:0x5B3
		if(moMgr.m_aMissionObjectives[i].m_bMoralityObjective)
		{
			displayMissionObjective(m_iGameInfoLevel, C, YL, XPos, YPos, iLine, moMgr.m_aMissionObjectives[i], iSubGroup);
		}
		__NFUN_163__(i);
		// [Loop Continue]
		goto J0x53C;
	}
	return;
}

exec function RendPawnState()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_bRendPawnState = __NFUN_129__(m_bRendPawnState);
	Outer.Player.Console.Message(__NFUN_112__("RendPawnState ", string(m_bRendPawnState)), 6.0000000);
	return;
}

exec function RendFocus()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_bRendFocus = __NFUN_129__(m_bRendFocus);
	Outer.Player.Console.Message(__NFUN_112__("RendFocus ", string(m_bRendFocus)), 6.0000000);
	return;
}

exec function SetRoundTime(int iSec)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x28
	if(__NFUN_114__(R6Pawn(Outer.Pawn), none))
	{
		return;
	}
	R6Pawn(Outer.Pawn).ServerSetRoundTime(iSec);
	return;
}

exec function SetBetTime(int iSec)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x28
	if(__NFUN_114__(R6Pawn(Outer.Pawn), none))
	{
		return;
	}
	R6Pawn(Outer.Pawn).ServerSetBetTime(iSec);
	return;
}

exec function ToggleCollision()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Outer.Player.Console.Message("ToggleCollision", 6.0000000);
	R6Pawn(Outer.Pawn).ServerToggleCollision();
	return;
}

exec function TestGetFrame()
{
	local R6Pawn P;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Outer.Player.Console.Message("TestGetFrame", 6.0000000);
	__NFUN_231__("*** was skeleton updated *** ");
	// End:0xC3
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Pawn', P)
	{
		// End:0xA8
		if(P.__NFUN_1501__())
		{
			__NFUN_231__(__NFUN_112__(string(P.Name), " yes "));
			// End:0xC2
			continue;
		}
		__NFUN_231__(__NFUN_112__(string(P.Name), " no "));		
	}	
	return;
}

//------------------------------------------------------------------
// CheckFrienship: check all problems related to friendship rules
//	
//------------------------------------------------------------------
exec function CheckFrienship()
{
	local Pawn p1, p2;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Outer.Player.Console.Message("CheckFrienship", 6.0000000);
	__NFUN_231__(" Check Friend/Enemy and Neutral relationship");
	// End:0x2B7
	foreach Outer.__NFUN_304__(Class'Engine.Pawn', p1)
	{
		// End:0x2B5
		foreach Outer.__NFUN_304__(Class'Engine.Pawn', p2)
		{
			// End:0x125
			if(__NFUN_114__(p1, p2))
			{
				// End:0x121
				if(p1.IsEnemy(p2))
				{
					__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("warning: ", string(p1.Name)), " is enemy with himself   m_iTeam="), string(p1.m_iTeam)));
				}
				continue;				
			}
			// End:0x1E4
			if(__NFUN_130__(p1.IsFriend(p2), p1.IsEnemy(p2)))
			{
				__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("warning: ", string(p1.Name)), " is friend and enemy with "), string(p2.Name)), " m_iTeamA="), string(p1.m_iTeam)), " m_iTeamB="), string(p2.m_iTeam)));
			}
			// End:0x2B4
			if(__NFUN_130__(p1.IsFriend(p2), p2.IsEnemy(p1)))
			{
				__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("warning: ", string(p1.Name)), " is friend with "), string(p2.Name)), ", and B consider A enemy    m_iTeamA="), string(p1.m_iTeam)), " m_iTeamB="), string(p2.m_iTeam)));
			}			
		}				
	}	
	return;
}

exec function LogFriendlyFire()
{
	local R6Pawn p1;
	local bool bAI;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Outer.Player.Console.Message("LogFriendlyFire", 6.0000000);
	__NFUN_231__("LOGGING FriendlyFire");
	// End:0x122
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Pawn', p1)
	{
		bAI = p1.Controller.__NFUN_303__('AIController');
		__NFUN_231__(__NFUN_112__(__NFUN_112__(string(p1.Name), " AI Controller="), string(bAI)));
		__NFUN_231__(__NFUN_112__("    m_bCanFireFriends =", string(p1.m_bCanFireFriends)));
		__NFUN_231__(__NFUN_112__("    m_bCanFireNeutrals=", string(p1.m_bCanFireNeutrals)));		
	}	
	return;
}

//------------------------------------------------------------------
// LogFriendship: list all frienship relation with all pawns
//	
//------------------------------------------------------------------
exec function LogFriendship(optional bool bCheckIfAlive)
{
	local Pawn p1, p2;
	local int iFriends, iEnemy, iNeutrals;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Outer.Player.Console.Message(__NFUN_112__("LogFrienship bCheckIfAlive=", string(bCheckIfAlive)), 6.0000000);
	__NFUN_231__(__NFUN_112__("LOGGING FRIENSHIP bCheckIfAlive=", string(bCheckIfAlive)));
	// End:0x3A9
	foreach Outer.__NFUN_304__(Class'Engine.Pawn', p1)
	{
		// End:0xC4
		if(__NFUN_130__(bCheckIfAlive, __NFUN_129__(p1.IsAlive())))
		{
			continue;			
		}
		iEnemy = 0;
		iFriends = 0;
		iNeutrals = 0;
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("", string(p1.Name)), "(team="), string(p1.m_iTeam)), ") is friend with: "));
		// End:0x1D0
		foreach Outer.__NFUN_304__(Class'Engine.Pawn', p2)
		{
			// End:0x14D
			if(__NFUN_114__(p1, p2))
			{
				continue;				
			}
			// End:0x1CF
			if(p1.IsFriend(p2))
			{
				// End:0x1CF
				if(__NFUN_132__(__NFUN_129__(bCheckIfAlive), __NFUN_130__(bCheckIfAlive, p2.IsAlive())))
				{
					__NFUN_165__(iFriends);
					__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   ", string(p2.Name)), "(team="), string(p2.m_iTeam)), ")"));
				}
			}			
		}		
		__NFUN_231__("  is enemy with: ");
		// End:0x295
		foreach Outer.__NFUN_304__(Class'Engine.Pawn', p2)
		{
			// End:0x212
			if(__NFUN_114__(p1, p2))
			{
				continue;				
			}
			// End:0x294
			if(p1.IsEnemy(p2))
			{
				// End:0x294
				if(__NFUN_132__(__NFUN_129__(bCheckIfAlive), __NFUN_130__(bCheckIfAlive, p2.IsAlive())))
				{
					__NFUN_165__(iEnemy);
					__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   ", string(p2.Name)), "(team="), string(p2.m_iTeam)), ")"));
				}
			}			
		}		
		__NFUN_231__("   is neutral with: ");
		// End:0x35D
		foreach Outer.__NFUN_304__(Class'Engine.Pawn', p2)
		{
			// End:0x2DA
			if(__NFUN_114__(p1, p2))
			{
				continue;				
			}
			// End:0x35C
			if(p1.IsNeutral(p2))
			{
				// End:0x35C
				if(__NFUN_132__(__NFUN_129__(bCheckIfAlive), __NFUN_130__(bCheckIfAlive, p2.IsAlive())))
				{
					__NFUN_165__(iNeutrals);
					__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   ", string(p2.Name)), "(team="), string(p2.m_iTeam)), ")"));
				}
			}			
		}		
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("-- Total friends= ", string(iFriends)), " Enemy="), string(iEnemy)), " Neutrals="), string(iNeutrals)));		
	}	
	return;
}

exec function ToggleMissionLog()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_bToggleMissionLog = __NFUN_129__(m_bToggleMissionLog);
	R6AbstractGameInfo(Outer.Level.Game).m_missionMgr.ToggleLog(m_bToggleMissionLog);
	Outer.Player.Console.Message(__NFUN_112__("ToggleMissionLog =", string(m_bToggleMissionLog)), 6.0000000);
	return;
}

exec function listzone()
{
	local R6AbstractInsertionZone aZone;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x5A
	foreach Outer.__NFUN_304__(Class'R6Abstract.R6AbstractInsertionZone', aZone)
	{
		Outer.logX(__NFUN_112__("R6AbstractInsertionZone: ", string(aZone)));		
	}	
	return;
}

function ListActors(Class<Actor> ClassName, optional bool bNumber, optional int iFrom, optional int iMax)
{
	local int i;
	local Actor aActor;

	// End:0x16
	if(__NFUN_154__(iMax, 0))
	{
		iMax = 99999;
	}
	// End:0xA0
	foreach Outer.__NFUN_304__(ClassName, aActor)
	{
		__NFUN_165__(i);
		// End:0x9F
		if(__NFUN_130__(__NFUN_153__(i, iFrom), __NFUN_152__(i, iMax)))
		{
			// End:0x89
			if(bNumber)
			{
				__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("  ", string(i)), "- "), string(aActor.Name)));
				// End:0x9F
				continue;
			}
			__NFUN_231__(__NFUN_112__("", string(aActor.Name)));
		}		
	}	
	return;
}

exec function GetNbTerro()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Outer.Player.Console.Message(__NFUN_112__("Number of terro=", string(GetActorsNb(Class'R6Engine.R6Terrorist', true))), 6.0000000);
	return;
}

exec function GetNbHostage()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Outer.Player.Console.Message(__NFUN_112__("Number of hostage=", string(GetActorsNb(Class'R6Engine.R6Hostage', true))), 6.0000000);
	return;
}

exec function GetNbRainbow()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Outer.Player.Console.Message(__NFUN_112__("Number of rainbow=", string(GetActorsNb(Class'R6Engine.R6Rainbow', true))), 6.0000000);
	return;
}

function int GetActorsNb(Class<Actor> ClassName, optional bool bNoLog)
{
	local int i;
	local Actor aActor;

	// End:0x21
	foreach Outer.__NFUN_304__(ClassName, aActor)
	{
		__NFUN_165__(i);		
	}	
	// End:0x42
	if(__NFUN_129__(bNoLog))
	{
		__NFUN_231__(__NFUN_112__(" total= ", string(i)));
	}
	return i;
	return;
}

exec function logActReset()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	m_iCounterLog = 0;
	m_iCounterLogMax = GetActorsNb(Class'Engine.Actor', true);
	return;
}

exec function logAct(int iNb, optional bool bNumber)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	ListActors(Class'Engine.Actor', bNumber, m_iCounterLog, __NFUN_146__(m_iCounterLog, iNb));
	__NFUN_161__(m_iCounterLog, iNb);
	// End:0x66
	if(__NFUN_153__(m_iCounterLog, m_iCounterLogMax))
	{
		__NFUN_231__(__NFUN_112__(" total= ", string(GetActorsNb(Class'Engine.Actor', true))));
	}
	return;
}

exec function ListEscort()
{
	local R6Rainbow R;
	local int i;
	local name szFollow;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	__NFUN_231__("List Escorted Hostages");
	__NFUN_231__("======================");
	// End:0x1E1
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Rainbow', R)
	{
		// End:0x74
		if(__NFUN_114__(R.m_aEscortedHostage[0], none))
		{
			continue;			
		}
		__NFUN_231__(__NFUN_112__("Rainbow= ", string(R.Name)));
		J0x93:

		// End:0x1E0 [Loop If]
		if(__NFUN_130__(__NFUN_150__(i, 4), __NFUN_119__(R.m_aEscortedHostage[i], none)))
		{
			// End:0xF5
			if(__NFUN_114__(R.m_aEscortedHostage[i].m_controller.m_pawnToFollow, none))
			{
				szFollow = 'None';				
			}
			else
			{
				szFollow = R.m_aEscortedHostage[i].m_controller.m_pawnToFollow.Name;
			}
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("   ", string(R.m_aEscortedHostage[i].Name)), " follows "), string(szFollow)));
			// End:0x1D6
			if(__NFUN_119__(R, R.m_aEscortedHostage[i].m_escortedByRainbow))
			{
				__NFUN_231__(__NFUN_112__("    Warning: wrong owner=", string(R.m_aEscortedHostage[i].m_escortedByRainbow.Name)));
			}
			__NFUN_163__(i);
			// [Loop Continue]
			goto J0x93;
		}		
	}	
	return;
}

exec function DbgPlayerStates()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Outer.GameReplicationInfo.m_bShowPlayerStates = __NFUN_129__(Outer.GameReplicationInfo.m_bShowPlayerStates);
	Outer.Player.Console.Message(__NFUN_112__("DbgPlayerStates = ", string(Outer.GameReplicationInfo.m_bShowPlayerStates)), 6.0000000);
	return;
}

exec function ForceKillResult(int iKillResult)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	__NFUN_231__(__NFUN_112__("New Force Kill = ", string(iKillResult)));
	R6Pawn(Outer.Pawn).ServerForceKillResult(iKillResult);
	return;
}

exec function ForceStunResult(int iStunResult)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	__NFUN_231__(__NFUN_112__("New Force Stun = ", string(iStunResult)));
	R6Pawn(Outer.Pawn).ServerForceStunResult(iStunResult);
	return;
}

exec function CallDebug()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6PlayerController(Outer.Pawn.Controller).__NFUN_1840__();
	return;
}

exec function shaketime(float fTime)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6PlayerController(Outer.Pawn.Controller).m_fShakeTime = fTime;
	return;
}

exec function MaxShake(float f)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6PlayerController(Outer.Pawn.Controller).m_fMaxShake = f;
	return;
}

exec function MaxShakeTime(float f)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6PlayerController(Outer.Pawn.Controller).m_fMaxShakeTime = f;
	R6PlayerController(Outer.Pawn.Controller).m_fCurrentShake = 0.0000000;
	return;
}

exec function PlayDare(string SoundName)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Outer.__NFUN_264__(Sound(DynamicLoadObject(SoundName, Class'Engine.Sound')));
	return;
}

exec function ResetRainbow()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x5E
	if(__NFUN_154__(int(Outer.Pawn.m_ePawnType), int(1)))
	{
		R6PlayerController(Outer.Pawn.Controller).m_TeamManager.ResetRainbowTeam();
	}
	return;
}

exec function HitValue(int iWhich, float fValue)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x4A
	if(__NFUN_154__(iWhich, 1))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactHit.iBlurIntensity = int(fValue);
	}
	// End:0x86
	if(__NFUN_154__(iWhich, 2))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactHit.fReturnTime = fValue;
	}
	// End:0xC2
	if(__NFUN_154__(iWhich, 3))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactHit.fRollMax = fValue;
	}
	// End:0xFE
	if(__NFUN_154__(iWhich, 4))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactHit.fRollSpeed = fValue;
	}
	// End:0x13A
	if(__NFUN_154__(iWhich, 5))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactHit.fWaveTime = fValue;
	}
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("New Hit Value = Blur:", string(R6PlayerController(Outer.Pawn.Controller).m_stImpactHit.iBlurIntensity)), " Return Time:"), string(R6PlayerController(Outer.Pawn.Controller).m_stImpactHit.fReturnTime)));
	return;
}

exec function StunValue(int iWhich, float fValue)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x4A
	if(__NFUN_154__(iWhich, 1))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactStun.iBlurIntensity = int(fValue);
	}
	// End:0x86
	if(__NFUN_154__(iWhich, 2))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactStun.fReturnTime = fValue;
	}
	// End:0xC2
	if(__NFUN_154__(iWhich, 3))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactStun.fRollMax = fValue;
	}
	// End:0xFE
	if(__NFUN_154__(iWhich, 4))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactStun.fRollSpeed = fValue;
	}
	// End:0x13A
	if(__NFUN_154__(iWhich, 5))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactStun.fWaveTime = fValue;
	}
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("New Stun Value: = Blur:", string(R6PlayerController(Outer.Pawn.Controller).m_stImpactStun.iBlurIntensity)), " Return Time:"), string(R6PlayerController(Outer.Pawn.Controller).m_stImpactStun.fReturnTime)));
	return;
}

exec function DazedValue(int iWhich, float fValue)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x4A
	if(__NFUN_154__(iWhich, 1))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactDazed.iBlurIntensity = int(fValue);
	}
	// End:0x86
	if(__NFUN_154__(iWhich, 2))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactDazed.fReturnTime = fValue;
	}
	// End:0xC2
	if(__NFUN_154__(iWhich, 3))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactDazed.fRollMax = fValue;
	}
	// End:0xFE
	if(__NFUN_154__(iWhich, 4))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactDazed.fRollSpeed = fValue;
	}
	// End:0x13A
	if(__NFUN_154__(iWhich, 5))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactDazed.fWaveTime = fValue;
	}
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("New Dazed Value: = Blur:", string(R6PlayerController(Outer.Pawn.Controller).m_stImpactDazed.iBlurIntensity)), " Return Time:"), string(R6PlayerController(Outer.Pawn.Controller).m_stImpactDazed.fReturnTime)));
	return;
}

exec function KOValue(int iWhich, float fValue)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x4A
	if(__NFUN_154__(iWhich, 1))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactKO.iBlurIntensity = int(fValue);
	}
	// End:0x86
	if(__NFUN_154__(iWhich, 2))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactKO.fReturnTime = fValue;
	}
	// End:0xC2
	if(__NFUN_154__(iWhich, 3))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactKO.fRollMax = fValue;
	}
	// End:0xFE
	if(__NFUN_154__(iWhich, 4))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactKO.fRollSpeed = fValue;
	}
	// End:0x13A
	if(__NFUN_154__(iWhich, 5))
	{
		R6PlayerController(Outer.Pawn.Controller).m_stImpactKO.fWaveTime = fValue;
	}
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("New KO Value: = Blur:", string(R6PlayerController(Outer.Pawn.Controller).m_stImpactKO.iBlurIntensity)), " Return Time:"), string(R6PlayerController(Outer.Pawn.Controller).m_stImpactKO.fReturnTime)));
	return;
}

///////////////////////////////////////////////////////////////////////////////////////
//  R6 Speed Debug functions - used to set the different movement speeds for the 
//								player controller
///////////////////////////////////////////////////////////////////////////////////////
exec function r6walk(float speed)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6Pawn(Outer.Pawn).m_fWalkingSpeed = speed;
	return;
}

exec function r6walkbackstrafe(float speed)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6Pawn(Outer.Pawn).m_fWalkingBackwardStrafeSpeed = speed;
	return;
}

exec function r6run(float speed)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6Pawn(Outer.Pawn).m_fRunningSpeed = speed;
	return;
}

exec function r6runbackstrafe(float speed)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6Pawn(Outer.Pawn).m_fRunningBackwardStrafeSpeed = speed;
	return;
}

exec function r6cwalk(float speed)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6Pawn(Outer.Pawn).m_fCrouchedWalkingSpeed = speed;
	return;
}

exec function r6cwalkbackstrafe(float speed)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6Pawn(Outer.Pawn).m_fCrouchedWalkingBackwardStrafeSpeed = speed;
	return;
}

exec function r6crun(float speed)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6Pawn(Outer.Pawn).m_fCrouchedRunningSpeed = speed;
	return;
}

exec function r6crunbackstrafe(float speed)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6Pawn(Outer.Pawn).m_fCrouchedRunningBackwardStrafeSpeed = speed;
	return;
}

exec function r6prone(float speed)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6Pawn(Outer.Pawn).m_fProneSpeed = speed;
	return;
}

exec function R6Ladder(float speed)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6Pawn(Outer.Pawn).LadderSpeed = speed;
	return;
}

exec function Armor(int armorType)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x71
	if(__NFUN_154__(armorType, 0))
	{
		R6Pawn(Outer.Pawn).m_eArmorType = 1;
		R6Pawn(Outer.Pawn).ClientMessage("Armor Class is now Light");		
	}
	else
	{
		// End:0xD6
		if(__NFUN_154__(armorType, 1))
		{
			R6Pawn(Outer.Pawn).m_eArmorType = 2;
			R6Pawn(Outer.Pawn).ClientMessage("Armor Class is now Medium");			
		}
		else
		{
			R6Pawn(Outer.Pawn).m_eArmorType = 3;
			R6Pawn(Outer.Pawn).ClientMessage("Armor Class is now Heavy");
		}
	}
	return;
}

exec function GetNetMode()
{
	switch(Outer.Level.NetMode)
	{
		// End:0x3B
		case NM_Standalone:
			__NFUN_231__(__NFUN_112__(string(self), " is NM_Standalone"));
			// End:0xBC
			break;
		// End:0x62
		case NM_DedicatedServer:
			__NFUN_231__(__NFUN_112__(string(self), " is NM_DedicatedServer"));
			// End:0xBC
			break;
		// End:0x86
		case NM_ListenServer:
			__NFUN_231__(__NFUN_112__(string(self), " is NM_ListenServer"));
			// End:0xBC
			break;
		// End:0xA4
		case NM_Client:
			__NFUN_231__(__NFUN_112__(string(self), " is NM_Client"));
			// End:0xBC
			break;
		// End:0xFFFF
		default:
			__NFUN_231__(__NFUN_112__(string(self), " is other"));
			// End:0xBC
			break;
			break;
	}
	return;
}

//------------------------------------------------------
// Begin R6Debug functions
//------------------------------------------------------
exec function UpdateBones()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	return;
}

///////////////////////////////////////////////////////////////////////////////////////
//  R6FixCamera()
//    rbrek - 5 oct 2001 
//    Debug function, only has an effect when behindView = true, camera will not move...
///////////////////////////////////////////////////////////////////////////////////////
exec function R6FixCamera()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6PlayerController(Outer.Pawn.Controller).m_bFixCamera = true;
	return;
}

///////////////////////////////////////////////////////////////////////////////////////
//  R6FreeCamera()
//    rbrek - 5 oct 2001 
//    Debug function, only has an effect when behindView = true, camera will not move...
///////////////////////////////////////////////////////////////////////////////////////
exec function R6FreeCamera()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6PlayerController(Outer.Pawn.Controller).m_bFixCamera = false;
	return;
}

exec function LogBandWidth(bool bLogBandWidth)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Outer.Level.m_bLogBandWidth = bLogBandWidth;
	R6PlayerController(Outer.Pawn.Controller).ServerLogBandWidth(bLogBandWidth);
	return;
}

exec function NetLogServer()
{
	local Actor ActorIterator;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x67
	foreach Outer.__NFUN_304__(Class'Engine.Actor', ActorIterator)
	{
		// End:0x66
		if(__NFUN_242__(ActorIterator.m_bLogNetTraffic, true))
		{
			R6PlayerController(Outer.Pawn.Controller).ServerNetLogActor(ActorIterator);
		}		
	}	
	return;
}

exec function LogActors()
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6PlayerController(Outer.Pawn.Controller).DoLogActors();
	// End:0x7B
	if(__NFUN_155__(int(Outer.Level.NetMode), int(NM_Standalone)))
	{
		R6PlayerController(Outer.Pawn.Controller).ServerLogActors();
	}
	return;
}

exec function Azimut()
{
	Outer.Player.Console.Message("//*********************************************\\", 10.0000000);
	Outer.Player.Console.Message("Pround [NDG] member, owning with style since 1975", 10.0000000);
	Outer.Player.Console.Message("\\****************** Azimut + Tap *************//", 10.0000000);
	return;
}

function DoWalk(Pawn aPawn)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	R6PlayerController(Outer.Pawn.Controller).bCheatFlying = false;
	aPawn.UnderWaterTime = aPawn.default.UnderWaterTime;
	aPawn.__NFUN_262__(true, true, true);
	aPawn.__NFUN_3970__(1);
	aPawn.bCollideWorld = true;
	R6PlayerController(Outer.Pawn.Controller).ClientReStart();
	return;
}

function DoGhost(Pawn aPawn)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	aPawn.UnderWaterTime = -1.0000000;
	R6PlayerController(Outer.Pawn.Controller).ClientMessage("You feel ethereal");
	aPawn.__NFUN_262__(false, false, false);
	aPawn.bCollideWorld = false;
	R6PlayerController(Outer.Pawn.Controller).bCheatFlying = true;
	R6PlayerController(Outer.Pawn.Controller).__NFUN_113__('PlayerFlying');
	R6PlayerController(Outer.Pawn.Controller).ClientGotoState('PlayerFlying', 'None');
	return;
}

exec function Ghost()
{
	R6PlayerController(Outer.Pawn.Controller).ServerGhost(Outer.Pawn);
	return;
}

exec function CompleteMission()
{
	R6PlayerController(Outer.Pawn.Controller).ServerCompleteMission();
	return;
}

exec function AbortMission()
{
	R6PlayerController(Outer.Pawn.Controller).ServerAbortMission();
	return;
}

exec function Walk()
{
	R6PlayerController(Outer.Pawn.Controller).ServerWalk(Outer.Pawn);
	return;
}

exec function Alkoliq()
{
	Outer.Player.Console.Message("Hi there! Hope you like the game and maybe we'll meet on-line", 10.0000000);
	Outer.Player.Console.Message("Aux membres de l'équipe Raven Shield, on a réussit, Vous êtes la meilleure équipe!", 10.0000000);
	Outer.Player.Console.Message("I would like to say thanks to Maggie for her support and patience. I love you!", 10.0000000);
	Outer.Player.Console.Message("Merci aussi à mon chat Kleenex, pour me rappeller que je dois retourner chez moi de temps en temps.", 10.0000000);
	Outer.Player.Console.Message("Special Thanks to An-Hoa for all the cakes she gave us during this project", 10.0000000);
	Outer.Player.Console.Message("   ", 10.0000000);
	Outer.Player.Console.Message("Now go and play!!!  Let The Bodies Hit The Floor!", 10.0000000);
	Outer.Player.Console.Message(" >>>> Joel Tremblay (Alkoliq) Janvier 2003 <<<< ", 10.0000000);
	return;
}

exec function RainbowSkill(float fMul)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x27
	if(__NFUN_178__(fMul, 0.0000000))
	{
		fMul = 1.0000000;
	}
	Outer.Level.m_fRainbowSkillMultiplier = fMul;
	Outer.Player.Console.Message(__NFUN_112__("Rainbow skill multiplier set to ", string(Outer.Level.m_fRainbowSkillMultiplier)), 6.0000000);
	return;
}

exec function TerroSkill(float fMul)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x27
	if(__NFUN_178__(fMul, 0.0000000))
	{
		fMul = 1.0000000;
	}
	Outer.Level.m_fTerroSkillMultiplier = fMul;
	Outer.Player.Console.Message(__NFUN_112__("Terrorist skill multiplier set to ", string(Outer.Level.m_fTerroSkillMultiplier)), 6.0000000);
	return;
}

exec function ShowSkill(float fMul)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Outer.Player.Console.Message(__NFUN_112__("Rainbow skill multiplier set to ", string(Outer.Level.m_fRainbowSkillMultiplier)), 6.0000000);
	Outer.Player.Console.Message(__NFUN_112__("Terrorist skill multiplier set to ", string(Outer.Level.m_fTerroSkillMultiplier)), 6.0000000);
	return;
}

exec function regroupHostages()
{
	local int Num;
	local R6Hostage H;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0xAF
	foreach Outer.__NFUN_304__(Class'R6Engine.R6Hostage', H)
	{
		// End:0xAE
		if(__NFUN_119__(H.m_controller, none))
		{
			H.m_controller.Order_GotoExtraction(Outer.Pawn);
			Outer.Player.Console.Message(__NFUN_112__(string(H.Name), " is regrouping on me"), 6.0000000);
		}		
	}	
	return;
}

exec function Thor()
{
	Outer.Player.Console.Message("En espérant que vous appréciez... les menus!", 10.0000000);
	Outer.Player.Console.Message("Remerciements à toute l'équipe prog de RS...", 10.0000000);
	Outer.Player.Console.Message("Une pensée pour Valérie, pour ma famille... et oui c'est moi, vous me reconnaissez?", 10.0000000);
	Outer.Player.Console.Message("Thor -- janvier 2003, déjà?!!!", 10.0000000);
	Outer.Player.Console.Message("Pour Azimut : '2 pixels à droite, 2 pixels à droite...' :)", 10.0000000);
	return;
}

exec function FullAmmo()
{
	local int iWeaponIndex;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	iWeaponIndex = 0;
	J0x14:

	// End:0x5B [Loop If]
	if(__NFUN_150__(iWeaponIndex, 4))
	{
		R6AbstractWeapon(R6Pawn(Outer.Pawn).m_WeaponsCarried[iWeaponIndex]).FullAmmo();
		__NFUN_165__(iWeaponIndex);
		// [Loop Continue]
		goto J0x14;
	}
	return;
}

defaultproperties
{
	m_bFirstPersonPlayerView=true
	m_fNavPointDistance=1200.0000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function HideWeapon
// REMOVED IN 1.60: function ShowWeapon
// REMOVED IN 1.60: function dbgWeapon
// REMOVED IN 1.60: function dbgHisWeapon
// REMOVED IN 1.60: function WOX
// REMOVED IN 1.60: function WOY
// REMOVED IN 1.60: function WOZ
// REMOVED IN 1.60: function ShowWO
// REMOVED IN 1.60: function HandDown
// REMOVED IN 1.60: function HandUp
// REMOVED IN 1.60: function DeployBP
// REMOVED IN 1.60: function CloseBP
// REMOVED IN 1.60: function SNDRecall
// REMOVED IN 1.60: function SNDMute
// REMOVED IN 1.60: function SNDChangeVolume
// REMOVED IN 1.60: function GetPrePivot
// REMOVED IN 1.60: function SetPrePivot
// REMOVED IN 1.60: function DoAJump
// REMOVED IN 1.60: function SetBombTimer
// REMOVED IN 1.60: function GetBombInfo
// REMOVED IN 1.60: function SetBombInfo
// REMOVED IN 1.60: function testBomb
// REMOVED IN 1.60: function Gwigre
// REMOVED IN 1.60: function Arsenic
// REMOVED IN 1.60: function ToggleSoundLog
// REMOVED IN 1.60: function pago
// REMOVED IN 1.60: function deks
