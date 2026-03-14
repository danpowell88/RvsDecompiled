//=============================================================================
// R6BroadcastHandler - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6BroadcastHandler extends BroadcastHandler
	config
 hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var bool m_bShowLog;

function bool IsSpectator(R6PlayerController A)
{
	return __NFUN_132__(__NFUN_132__(A.PlayerReplicationInfo.bIsSpectator, __NFUN_154__(A.PlayerReplicationInfo.TeamID, int(0))), __NFUN_154__(A.PlayerReplicationInfo.TeamID, int(4)));
	return;
}

function bool IsATeamMember(R6PlayerController A)
{
	return __NFUN_132__(__NFUN_154__(int(A.m_TeamSelection), int(2)), __NFUN_154__(int(A.m_TeamSelection), int(3)));
	return;
}

// A is supposed to be a team member
function bool IsSameTeam(R6PlayerController A, R6PlayerController B)
{
	// End:0x12
	if(__NFUN_129__(IsATeamMember(B)))
	{
		return false;
	}
	return __NFUN_154__(A.PlayerReplicationInfo.TeamID, B.PlayerReplicationInfo.TeamID);
	return;
}

function bool IsPlayerDead(R6PlayerController A)
{
	return __NFUN_151__(A.PlayerReplicationInfo.m_iHealth, 1);
	return;
}

function BroadcastTeam(Actor Sender, coerce string Msg, optional name type)
{
	local R6PlayerController aSender;
	local R6Pawn aSenderPawn;
	local PlayerReplicationInfo SenderPRI;
	local R6PlayerController B;
	local bool bSend, bGameTypeMsg;

	// End:0x2C
	if(__NFUN_119__(Pawn(Sender), none))
	{
		SenderPRI = Pawn(Sender).PlayerReplicationInfo;		
	}
	else
	{
		// End:0x55
		if(__NFUN_119__(Controller(Sender), none))
		{
			SenderPRI = Controller(Sender).PlayerReplicationInfo;
		}
	}
	aSender = R6PlayerController(Sender);
	// End:0x97
	if(__NFUN_114__(aSender, none))
	{
		__NFUN_231__("none = R6PlayerController(Sender)");
		return;
	}
	// End:0xC6
	if(__NFUN_129__(IsATeamMember(aSender)))
	{
		__NFUN_231__("!IsATeamMember( aSender )");
		return;
	}
	// End:0xF0
	if(__NFUN_130__(__NFUN_255__(type, 'Line'), __NFUN_129__(AllowsBroadcast(Sender, __NFUN_125__(Msg)))))
	{
		return;
	}
	aSenderPawn = R6Pawn(aSender.Pawn);
	// End:0x143
	if(__NFUN_130__(__NFUN_119__(aSenderPawn, none), __NFUN_119__(aSenderPawn.m_TeamMemberRepInfo, none)))
	{
		__NFUN_139__(aSenderPawn.m_TeamMemberRepInfo.m_BlinkCounter);
	}
	// End:0x1C3
	foreach __NFUN_313__(Class'R6Engine.R6PlayerController', B)
	{
		bSend = false;
		// End:0x19F
		if(IsSameTeam(aSender, B))
		{
			// End:0x189
			if(__NFUN_129__(IsPlayerDead(aSender)))
			{
				bSend = true;				
			}
			else
			{
				// End:0x19F
				if(IsPlayerDead(B))
				{
					bSend = true;
				}
			}
		}
		// End:0x1C2
		if(bSend)
		{
			BroadcastText(SenderPRI, B, Msg, type);
		}		
	}	
	return;
}

function DebugBroadcaster(R6PlayerController A, bool bSender)
{
	local string szName;

	// End:0x31
	if(__NFUN_119__(A.PlayerReplicationInfo, none))
	{
		szName = A.PlayerReplicationInfo.PlayerName;
	}
	__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Broadcast: ", szName), " bSender="), string(bSender)), " spec="), string(IsSpectator(A))), " dead="), string(IsPlayerDead(A))), " team="), string(IsATeamMember(A))), " teamID="), string(A.PlayerReplicationInfo.TeamID)), " health="), string(A.PlayerReplicationInfo.m_iHealth)));
	return;
}

function Broadcast(Actor Sender, coerce string Msg, optional name type)
{
	local R6PlayerController aSender;
	local R6Pawn aSenderPawn;
	local R6PlayerController B;
	local GameReplicationInfo _GRI;
	local PlayerReplicationInfo PRI;
	local bool bSend, bGameTypeMsg;

	// End:0x1A
	if(__NFUN_254__(type, 'GameMsg'))
	{
		bGameTypeMsg = true;		
	}
	else
	{
		// End:0x2B
		if(__NFUN_254__(type, 'TeamSay'))
		{
			return;
		}
	}
	aSender = R6PlayerController(Sender);
	// End:0x9F
	if(__NFUN_129__(bGameTypeMsg))
	{
		// End:0x64
		if(__NFUN_130__(__NFUN_114__(aSender, none), __NFUN_255__(type, 'ServerMessage')))
		{
			return;
		}
		// End:0x9F
		if(__NFUN_130__(__NFUN_130__(__NFUN_255__(type, 'Line'), __NFUN_255__(type, 'ServerMessage')), __NFUN_129__(AllowsBroadcast(Sender, __NFUN_125__(Msg)))))
		{
			return;
		}
	}
	// End:0xCB
	if(__NFUN_119__(Pawn(Sender), none))
	{
		PRI = Pawn(Sender).PlayerReplicationInfo;		
	}
	else
	{
		// End:0xF4
		if(__NFUN_119__(Controller(Sender), none))
		{
			PRI = Controller(Sender).PlayerReplicationInfo;
		}
	}
	// End:0x125
	if(__NFUN_130__(__NFUN_255__(type, 'ServerMessage'), __NFUN_129__(bGameTypeMsg)))
	{
		// End:0x125
		if(m_bShowLog)
		{
			DebugBroadcaster(aSender, true);
		}
	}
	// End:0x183
	if(__NFUN_119__(aSender, none))
	{
		aSenderPawn = R6Pawn(aSender.Pawn);
		// End:0x183
		if(__NFUN_130__(__NFUN_119__(aSenderPawn, none), __NFUN_119__(aSenderPawn.m_TeamMemberRepInfo, none)))
		{
			__NFUN_139__(aSenderPawn.m_TeamMemberRepInfo.m_BlinkCounter);
		}
	}
	// End:0x2EB
	foreach __NFUN_313__(Class'R6Engine.R6PlayerController', B)
	{
		// End:0x1B2
		if(__NFUN_114__(_GRI, none))
		{
			_GRI = B.GameReplicationInfo;
		}
		bSend = false;
		// End:0x1DF
		if(__NFUN_132__(__NFUN_254__(type, 'ServerMessage'), bGameTypeMsg))
		{
			bSend = true;			
		}
		else
		{
			// End:0x1F4
			if(m_bShowLog)
			{
				DebugBroadcaster(B, false);
			}
			// End:0x241
			if(__NFUN_130__(__NFUN_155__(int(_GRI.m_eCurrectServerState), _GRI.2), __NFUN_155__(int(_GRI.m_eCurrectServerState), _GRI.3)))
			{
				bSend = true;				
			}
			else
			{
				// End:0x278
				if(IsSpectator(aSender))
				{
					// End:0x275
					if(__NFUN_132__(IsSpectator(B), IsPlayerDead(B)))
					{
						bSend = true;
					}					
				}
				else
				{
					// End:0x2AF
					if(IsPlayerDead(aSender))
					{
						// End:0x2AC
						if(__NFUN_132__(IsPlayerDead(B), IsSpectator(B)))
						{
							bSend = true;
						}						
					}
					else
					{
						// End:0x2C7
						if(__NFUN_129__(IsPlayerDead(aSender)))
						{
							bSend = true;
						}
					}
				}
			}
		}
		// End:0x2EA
		if(bSend)
		{
			BroadcastText(PRI, B, Msg, type);
		}		
	}	
	return;
}

