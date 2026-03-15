//=============================================================================
// R6IOProvider - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6IOProvider extends R6IOObject
    placeable;

var int m_iMP2DeviceAnim;
var(Debug) bool bShowLog;
var float m_fTimeLeft;
var float m_fRepTimeLeft;
var float m_fLastLevelTime;
var float m_fOxygeneLevelCAStart;
var(R6ActionObject) float m_fAugmentationPerSecond;
var float m_fTimeElapsed;
var(R6ActionObject) float m_fDisarmBombTimeMin;
var(R6ActionObject) float m_fDisarmBombTimeMax;
var(R6ActionObject) Texture m_ProviderIcon;

replication
{
	// Pos:0x000
	reliable if((int(Role) == int(ROLE_Authority)))
		m_fRepTimeLeft;
}

simulated function ResetOriginalData()
{
	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(false);
	}
	super.ResetOriginalData();
	m_fTimeLeft = 0.0000000;
	m_fRepTimeLeft = 0.0000000;
	m_fLastLevelTime = 0.0000000;
	return;
}

simulated function float GetTimeLeft()
{
	// End:0x22
	if((int(Level.NetMode) == int(NM_Client)))
	{
		return m_fRepTimeLeft;		
	}
	else
	{
		return m_fTimeLeft;
	}
	return;
}

simulated function Timer()
{
	local int iRemaining;

	super(R6InteractiveObject).Timer();
	return;
}

function ForceTimeLeft(float fTime)
{
	m_fTimeLeft = fTime;
	m_fRepTimeLeft = fTime;
	m_fLastLevelTime = Level.TimeSeconds;
	return;
}

simulated event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
	local bool bDisplayBombIcon;
	local Vector vActorDir, vFacingDir;
	local R6Pawn aPawn;

	// End:0x1B
	if(((CanToggle() == false) || (!m_bRainbowCanInteract)))
	{
		return;
	}
	Query.iHasAction = 0;
	aPawn = R6Pawn(PlayerController.Pawn);
	// End:0xA8
	if(m_bIsActivated)
	{
		Query.iHasAction = 1;
		Query.textureIcon = m_ProviderIcon;
		Query.iPlayerActionID = 1;
		Query.iTeamActionID = 1;
		Query.iTeamActionIDList[0] = 1;
	}
	Query.iTeamActionIDList[1] = 0;
	Query.iTeamActionIDList[2] = 0;
	Query.iTeamActionIDList[3] = 0;
	// End:0x183
	if((fDistance < m_fCircumstantialActionRange))
	{
		vFacingDir = Vector(Rotation);
		vFacingDir.Z = 0.0000000;
		vActorDir = Normal((Location - PlayerController.Pawn.Location));
		vActorDir.Z = 0.0000000;
		// End:0x16F
		if((Dot(vActorDir, vFacingDir) < -0.4000000))
		{
			Query.iInRange = 1;			
		}
		else
		{
			Query.iInRange = 0;
		}		
	}
	else
	{
		Query.iInRange = 0;
	}
	Query.bCanBeInterrupted = true;
	Query.fPlayerActionTimeRequired = GetTimeRequired(R6PlayerController(PlayerController).m_pawn);
	return;
}

simulated function ToggleDevice(R6Pawn aPawn)
{
	// End:0x0E
	if((CanToggle() == false))
	{
		return;
	}
	super.ToggleDevice(aPawn);
	SetTimer(1.0000000, true);
	return;
}

simulated function float GetMaxTimeRequired()
{
	return m_fDisarmBombTimeMax;
	return;
}

simulated function float GetTimeRequired(R6Pawn aPawn)
{
	local float fDisarmingBombTime;

	fDisarmingBombTime = ((Level.m_fOxygeneTopLevel - R6PlayerController(aPawn.Controller).m_fOxygeneLevel) / m_fAugmentationPerSecond);
	return fDisarmingBombTime;
	return;
}

simulated function R6CircumstantialActionProgressStart(R6AbstractCircumstantialActionQuery Query)
{
	m_fPlayerCAStartTime = Level.TimeSeconds;
	m_fOxygeneLevelCAStart = R6PlayerController(Query.aQueryOwner).m_fOxygeneLevel;
	m_fTimeElapsed = 0.0000000;
	PerformSoundAction(0);
	LockObjectUse(true);
	return;
}

simulated function R6CircumstantialActionCancel()
{
	LockObjectUse(false);
	PerformSoundAction(1);
	return;
}

simulated function int R6GetCircumstantialActionProgress(R6AbstractCircumstantialActionQuery Query, Pawn actingPawn)
{
	local float fPercentage, foxlevel, fTimeElapsed;

	fPercentage = ((Level.TimeSeconds - m_fPlayerCAStartTime) / Query.fPlayerActionTimeRequired);
	fTimeElapsed = ((Level.TimeSeconds - m_fTimeElapsed) - m_fPlayerCAStartTime);
	// End:0xD8
	if((fTimeElapsed > 0.5000000))
	{
		foxlevel = float(int((Level.TimeSeconds - m_fPlayerCAStartTime)));
		(foxlevel *= m_fAugmentationPerSecond);
		(foxlevel += m_fOxygeneLevelCAStart);
		// End:0xCD
		if((foxlevel < Level.m_fOxygeneTopLevel))
		{
			R6PlayerController(actingPawn.Controller).addToOxygenLevel(foxlevel);
		}
		m_fTimeElapsed = fTimeElapsed;
	}
	(fPercentage *= float(100));
	// End:0x123
	if((fPercentage >= float(100)))
	{
		R6PlayerController(actingPawn.Controller).addToOxygenLevel(Level.m_fOxygeneTopLevel);
		LockObjectUse(false);
	}
	// End:0x14B
	if(((fPercentage >= float(100)) && (int(m_ObjectState) != int(2))))
	{
		PerformSoundAction(2);
	}
	return int(fPercentage);
	return;
}

defaultproperties
{
	m_iMP2DeviceAnim=2
	m_fDisarmBombTimeMax=12.0000000
	m_eAnimToPlay=5
	m_bIsActivated=true
	m_StartSnd=Sound'Foley_Bomb.Play_Bomb_Defusing'
	m_InterruptedSnd=Sound'Foley_Bomb.Stop_Go_Bomb_Defusing'
	m_CompletedSnd=Sound'Foley_Bomb.Stop_Go_Bomb_Defused'
	m_bRainbowCanInteract=true
	m_fSoundRadiusActivation=5600.0000000
	m_fCircumstantialActionRange=60.0000000
}