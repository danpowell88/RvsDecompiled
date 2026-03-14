//=============================================================================
// R6AlarmCallToSupport - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
/********************************************************************
	created:	2001/11/06
	filename: 	R6AlarmCallToSupport.uc
	author:		Jean-Francois Dube
*********************************************************************/
class R6AlarmCallToSupport extends R6Alarm;

enum ETerroristTarget
{
	TT_AlarmPosition,               // 0
	TT_GivenPosition                // 1
};

// NEW IN 1.60
var(R6AlarmSettings) R6AlarmCallToSupport.ETerroristTarget m_eTerroristTarget;
var(R6AlarmSettings) R6Pawn.eMovementPace m_ePace;
var(R6AlarmSettings) int m_iTerroristGroup;
var(R6AlarmSettings) float m_fActivationTime;
var float m_fTimeStart;
var(R6AlarmSettings) Sound m_sndAlarmSound;
var(R6AlarmSettings) Sound m_sndAlarmSoundStop;
var(R6AlarmSettings) array<R6IOSound> m_IOSoundList;

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
	local int i;

	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(false);
	}
	super(Actor).ResetOriginalData();
	__NFUN_118__('Tick');
	i = 0;
	J0x24:

	// End:0x6A [Loop If]
	if(__NFUN_150__(i, m_IOSoundList.Length))
	{
		m_IOSoundList[i].AmbientSound = none;
		m_IOSoundList[i].AmbientSoundStop = none;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x24;
	}
	m_fTimeStart = 0.0000000;
	__NFUN_118__('Tick');
	return;
}

function SetAlarm(Vector vLocation)
{
	local R6TerroristAI C;
	local bool bStartAlarm;
	local int i;

	bStartAlarm = false;
	// End:0xB6
	foreach __NFUN_304__(Class'R6Engine.R6TerroristAI', C)
	{
		// End:0xB5
		if(__NFUN_130__(C.m_pawn.IsAlive(), __NFUN_154__(C.m_pawn.m_iGroupID, m_iTerroristGroup)))
		{
			bStartAlarm = true;
			// End:0x8B
			if(__NFUN_154__(int(m_eTerroristTarget), int(0)))
			{
				C.GotoPointAndSearch(Location, m_ePace, true);
				// End:0xB5
				continue;
			}
			// End:0xB5
			if(__NFUN_154__(int(m_eTerroristTarget), int(1)))
			{
				C.GotoPointAndSearch(vLocation, m_ePace, true);
			}
		}		
	}	
	// End:0x127
	if(bStartAlarm)
	{
		i = 0;
		J0xC7:

		// End:0x115 [Loop If]
		if(__NFUN_150__(i, m_IOSoundList.Length))
		{
			m_IOSoundList[i].AmbientSound = m_sndAlarmSound;
			m_IOSoundList[i].AmbientSoundStop = m_sndAlarmSoundStop;
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0xC7;
		}
		m_fTimeStart = 0.0000000;
		__NFUN_117__('Tick');
	}
	return;
}

function Tick(float fDeltaTime)
{
	local int i;

	__NFUN_184__(m_fTimeStart, fDeltaTime);
	// End:0x59
	if(__NFUN_177__(m_fTimeStart, m_fActivationTime))
	{
		i = 0;
		J0x22:

		// End:0x52 [Loop If]
		if(__NFUN_150__(i, m_IOSoundList.Length))
		{
			m_IOSoundList[i].AmbientSound = none;
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x22;
		}
		__NFUN_118__('Tick');
	}
	return;
}

auto state StartUp
{Begin:

	__NFUN_118__('Tick');
	stop;				
}

defaultproperties
{
	m_eTerroristTarget=1
	m_ePace=5
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var ETerroristTarget
