//=============================================================================
// MP2IODevice - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class MP2IODevice extends R6IODevice
    placeable;

var(IntruderMode) int m_iTerminalIndex;

simulated event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
	local bool bDisplayBombIcon;
	local Vector vActorDir, vFacingDir;

	// End:0x20
	if((int(R6PlayerController(PlayerController).m_TeamSelection) != int(2)))
	{
		return;
	}
	// End:0x3B
	if(((CanToggle() == false) || (!m_bRainbowCanInteract)))
	{
		return;
	}
	// End:0x58
	if(m_bIsActivated)
	{
		Query.iHasAction = 1;		
	}
	else
	{
		Query.iHasAction = 0;
		return;
	}
	Query.textureIcon = m_InteractionIcon;
	Query.iPlayerActionID = 3;
	Query.iTeamActionID = 3;
	Query.iTeamActionIDList[0] = 3;
	Query.iTeamActionIDList[1] = 0;
	Query.iTeamActionIDList[2] = 0;
	Query.iTeamActionIDList[3] = 0;
	// End:0x1A7
	if((fDistance < m_fCircumstantialActionRange))
	{
		vFacingDir = Vector(Rotation);
		vFacingDir.Z = 0.0000000;
		vFacingDir = Normal(vFacingDir);
		vActorDir = (Location - PlayerController.Pawn.Location);
		vActorDir.Z = 0.0000000;
		vActorDir = Normal(vActorDir);
		// End:0x193
		if((Dot(vActorDir, vFacingDir) > 0.8500000))
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

simulated function float GetTimeRequired(R6Pawn aPawn)
{
	local float fPlantingTime;

	// End:0x43
	if(bShowLog)
	{
		Log(((("GetTimeRequired" @ string(m_fPlantTimeMin)) @ string(aPawn)) @ string(aPawn.GetSkill(2))));
	}
	fPlantingTime = (m_fPlantTimeMin + ((float(1) - aPawn.GetSkill(2)) * (m_fPlantTimeMax - m_fPlantTimeMin)));
	// End:0xA4
	if((HasKit(aPawn) && ((fPlantingTime - m_fGainTimeWithElectronicsKit) > float(0))))
	{
		(fPlantingTime -= m_fGainTimeWithElectronicsKit);
	}
	// End:0xCC
	if((R6Rainbow(aPawn).m_bIsTheIntruder == true))
	{
		fPlantingTime = m_fPlantTimeMin;		
	}
	else
	{
		fPlantingTime = m_fPlantTimeMax;
	}
	return fPlantingTime;
	return;
}

function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup)
{
	// End:0x15
	if((m_bBulletGoThrough == true))
	{
		return iKillValue;		
	}
	else
	{
		return 0;
	}
	return;
}

defaultproperties
{
	m_iTerminalIndex=1
	m_fPlantTimeMin=1.0000000
	m_bRainbowCanInteract=true
	CollisionRadius=45.0000000
	CollisionHeight=45.0000000
	m_fCircumstantialActionRange=28.0000000
}