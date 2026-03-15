//=============================================================================
// R6IOSelfDetonatingBomb - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6IOSelfDetonatingBomb : MissionPAck1
//  Like IOBomb, but it can self-detonate after a given amount of time
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6IOSelfDetonatingBomb extends R6IOBomb
    placeable;

var(R6ActionObject) float m_fSelfDetonationTime;  // MissionPack1 - Time required to self-detonate
var float m_fDefusedTimeMessage;  // defused message shown for 3 secs

function StartTimer()
{
	// End:0x32
	if((m_fSelfDetonationTime > float(0)))
	{
		m_fTimeLeft = m_fSelfDetonationTime;
		m_fTimeOfExplosion = m_fSelfDetonationTime;
		m_bIsActivated = false;
		ArmBomb(none);
	}
	return;
}

simulated function Timer()
{
	// End:0x7F
	if((Level.Game != none))
	{
		// End:0x7C
		if(((int(R6AbstractGameInfo(Level.Game).m_missionMgr.m_eMissionObjectiveStatus) != int(1)) && (int(R6AbstractGameInfo(Level.Game).m_missionMgr.m_eMissionObjectiveStatus) != int(2))))
		{
			super.Timer();
		}		
	}
	else
	{
		super.Timer();
	}
	return;
}

simulated function PostRender(Canvas C)
{
	local float fStrSizeX, fStrSizeY;
	local int X, Y;
	local string sTime;
	local int iTimeLeft;

	// End:0x29
	if((int(Level.NetMode) == int(NM_Client)))
	{
		iTimeLeft = int(m_fRepTimeLeft);		
	}
	else
	{
		iTimeLeft = int(m_fTimeLeft);
	}
	// End:0x196
	if(m_bIsActivated)
	{
		sTime = (Localize("Game", "TimeLeft", "R6GameInfo") $ " ");
		sTime = (sTime $ ConvertIntTimeToString(iTimeLeft, true));
		C.UseVirtualSize(true, 640.0000000, 480.0000000);
		X = int(C.HalfClipX);
		Y = int((C.HalfClipY / float(8)));
		C.Font = Font'R6Font.Rainbow6_14pt';
		// End:0x106
		if((iTimeLeft > 20))
		{
			C.SetDrawColor(byte(255), byte(255), byte(255));			
		}
		else
		{
			// End:0x12B
			if((iTimeLeft > 10))
			{
				C.SetDrawColor(byte(255), byte(255), 0);				
			}
			else
			{
				C.SetDrawColor(byte(255), 0, 0);
			}
		}
		C.StrLen(sTime, fStrSizeX, fStrSizeY);
		C.SetPos((float(X) - (fStrSizeX / float(2))), float((Y + 24)));
		C.DrawText(sTime);
	}
	return;
}

simulated function PostRender2(Canvas C)
{
	local float fStrSizeX, fStrSizeY;
	local int X, Y;
	local string sTime;

	// End:0x1D
	if(m_bIsActivated)
	{
		m_fDefusedTimeMessage = Level.TimeSeconds;
	}
	// End:0x142
	if((!m_bIsActivated))
	{
		// End:0x142
		if(((Level.TimeSeconds - m_fDefusedTimeMessage) < float(3)))
		{
			sTime = (Localize("Game", "BombDefused", "R6GameInfo") $ " ");
			C.UseVirtualSize(true, 640.0000000, 480.0000000);
			X = int(C.HalfClipX);
			Y = int((C.HalfClipY / float(8)));
			C.Font = Font'R6Font.Rainbow6_14pt';
			C.SetDrawColor(byte(255), byte(255), byte(255));
			C.StrLen(sTime, fStrSizeX, fStrSizeY);
			C.SetPos((float(X) - (fStrSizeX / float(2))), float((Y + 48)));
			C.DrawText(sTime);
		}
	}
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function ResetOriginalData
