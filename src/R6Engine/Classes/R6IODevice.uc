//=============================================================================
// R6IODevice - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6IODevice : This should allow action moves on a Recon type device
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6IODevice extends R6IOObject
 placeable;

var(Debug) bool bShowLog;
var(R6ActionObject) float m_fPlantTimeMin;  // Base time required to disarmed the bomb if they have 100%, will be affected by the kit later (Must be higher then 2 seconds)
var(R6ActionObject) float m_fPlantTimeMax;  // Base time required to disarmed the bomb if they have 0%
var(R6ActionObject) Texture m_InteractionIcon;
var Sound m_PhoneBuggingSnd;
var Sound m_PhoneBuggingStopSnd;
var(R6ActionObject) array<Material> m_ArmedTextures;
var Vector m_vOffset;

function PostBeginPlay()
{
	super(R6InteractiveObject).PostBeginPlay();
	// End:0x85
	if(__NFUN_154__(int(Role), int(ROLE_Authority)))
	{
		// End:0x85
		if(__NFUN_132__(__NFUN_154__(int(m_eAnimToPlay), int(4)), __NFUN_154__(int(m_eAnimToPlay), int(3))))
		{
			AddSoundBankName("SFX_Penthouse_Single");
			// End:0x85
			if(__NFUN_154__(int(m_eAnimToPlay), int(3)))
			{
				m_StartSnd = m_PhoneBuggingSnd;
				m_InterruptedSnd = m_PhoneBuggingStopSnd;
				m_CompletedSnd = m_PhoneBuggingStopSnd;
			}
		}
	}
	return;
}

simulated event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
	local bool bDisplayBombIcon;
	local Vector vActorDir, vFacingDir;

	// End:0x1B
	if(__NFUN_132__(__NFUN_242__(CanToggle(), false), __NFUN_129__(m_bRainbowCanInteract)))
	{
		return;
	}
	// End:0x38
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
	// End:0x16F
	if(__NFUN_176__(fDistance, m_fCircumstantialActionRange))
	{
		vFacingDir = Vector(Rotation);
		vFacingDir.Z = 0.0000000;
		vActorDir = __NFUN_226__(__NFUN_216__(Location, PlayerController.Pawn.Location));
		vActorDir.Z = 0.0000000;
		// End:0x15B
		if(__NFUN_177__(__NFUN_219__(vActorDir, vFacingDir), 0.8500000))
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

simulated function string R6GetCircumstantialActionString(int iAction)
{
	switch(iAction)
	{
		// End:0xA6
		case int(3):
			switch(m_eAnimToPlay)
			{
				// End:0x43
				case 4:
					return Localize("RDVOrder", "Order_Computer", "R6Menu");
				// End:0x6F
				case 2:
					return Localize("RDVOrder", "Order_KeyPad", "R6Menu");
				// End:0xA0
				case 3:
					return Localize("RDVOrder", "Order_PlantDevice", "R6Menu");
				// End:0xFFFF
				default:
					return "";
					break;
			}
		// End:0xFFFF
		default:
			return "";
			break;
	}
	return;
}

simulated function ToggleDevice(R6Pawn aPawn)
{
	local int iSkinCount;

	// End:0x0E
	if(__NFUN_242__(CanToggle(), false))
	{
		return;
	}
	super.ToggleDevice(aPawn);
	// End:0x71
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_168__(__NFUN_168__(__NFUN_168__("Set Device", string(self)), "by pawn"), string(aPawn)), "and his controller"), string(aPawn.Controller)));
	}
	m_bIsActivated = false;
	iSkinCount = 0;
	J0x80:

	// End:0xB0 [Loop If]
	if(__NFUN_150__(iSkinCount, m_ArmedTextures.Length))
	{
		SetSkin(m_ArmedTextures[iSkinCount], iSkinCount);
		__NFUN_165__(iSkinCount);
		// [Loop Continue]
		goto J0x80;
	}
	R6AbstractGameInfo(Level.Game).IObjectInteract(aPawn, self);
	return;
}

simulated function bool HasKit(R6Pawn aPawn)
{
	return R6Rainbow(aPawn).m_bHasElectronicsKit;
	return;
}

simulated function float GetMaxTimeRequired()
{
	return m_fPlantTimeMax;
	return;
}

simulated function float GetTimeRequired(R6Pawn aPawn)
{
	local float fPlantingTime;

	// End:0x43
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_168__("GetTimeRequired", string(m_fPlantTimeMin)), string(aPawn)), string(aPawn.GetSkill(2))));
	}
	fPlantingTime = __NFUN_174__(m_fPlantTimeMin, __NFUN_171__(__NFUN_175__(float(1), aPawn.GetSkill(2)), __NFUN_175__(m_fPlantTimeMax, m_fPlantTimeMin)));
	// End:0xA4
	if(__NFUN_130__(HasKit(aPawn), __NFUN_177__(__NFUN_175__(fPlantingTime, m_fGainTimeWithElectronicsKit), float(0))))
	{
		__NFUN_185__(fPlantingTime, m_fGainTimeWithElectronicsKit);
	}
	return fPlantingTime;
	return;
}

defaultproperties
{
	m_fPlantTimeMin=4.0000000
	m_fPlantTimeMax=12.0000000
	m_InteractionIcon=Texture'R6ActionIcons.InteractiveDevice'
	m_PhoneBuggingSnd=Sound'SFX_Penthouse_Single.Play_PhoneBugging'
	m_PhoneBuggingStopSnd=Sound'SFX_Penthouse_Single.Stop_PhoneBugging_Go'
	m_bIsActivated=true
	m_StartSnd=Sound'SFX_Penthouse_Single.Play_seq_random_CompType'
	m_InterruptedSnd=Sound'SFX_Penthouse_Single.Stop_seq_random_CompType_Go'
	m_CompletedSnd=Sound'SFX_Penthouse_Single.Stop_seq_random_CompType_Go'
}
