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
	return ((A.PlayerReplicationInfo.bIsSpectator || (A.PlayerReplicationInfo.TeamID == int(0))) || (A.PlayerReplicationInfo.TeamID == int(4)));
	return;
}

function bool IsATeamMember(R6PlayerController A)
{
	return ((int(A.m_TeamSelection) == int(2)) || (int(A.m_TeamSelection) == int(3)));
	return;
}

// A is supposed to be a team member
function bool IsSameTeam(R6PlayerController A, R6PlayerController B)
{
	// End:0x12
	if((!IsATeamMember(B)))
	{
		return false;
	}
	return (A.PlayerReplicationInfo.TeamID == B.PlayerReplicationInfo.TeamID);
	return;
}

function bool IsPlayerDead(R6PlayerController A)
{
	return (A.PlayerReplicationInfo.m_iHealth > 1);
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
	if((Pawn(Sender) != none))
	{
		SenderPRI = Pawn(Sender).PlayerReplicationInfo;		
	}
	else
	{
		// End:0x55
		if((Controller(Sender) != none))
		{
			SenderPRI = Controller(Sender).PlayerReplicationInfo;
		}
	}
	aSender = R6PlayerController(Sender);
	// End:0x97
	if((aSender == none))
	{
		Log("none = R6PlayerController(Sender)");
		return;
	}
	// End:0xC6
	if((!IsATeamMember(aSender)))
	{
		Log("!IsATeamMember( aSender )");
		return;
	}
	// End:0xF0
	if(((type != 'Line') && (!AllowsBroadcast(Sender, Len(Msg)))))
	{
		return;
	}
	aSenderPawn = R6Pawn(aSender.Pawn);
	// End:0x143
	if(((aSenderPawn != none) && (aSenderPawn.m_TeamMemberRepInfo != none)))
	{
		(aSenderPawn.m_TeamMemberRepInfo.m_BlinkCounter++);
	}
	// End:0x1C3
	foreach DynamicActors(Class'R6Engine.R6PlayerController', B)
	{
		bSend = false;
		// End:0x19F
		if(IsSameTeam(aSender, B))
		{
			// End:0x189
			if((!IsPlayerDead(aSender)))
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
	if((A.PlayerReplicationInfo != none))
	{
		szName = A.PlayerReplicationInfo.PlayerName;
	}
	Log(((((((((((((("Broadcast: " $ szName) $ " bSender=") $ string(bSender)) $ " spec=") $ string(IsSpectator(A))) $ " dead=") $ string(IsPlayerDead(A))) $ " team=") $ string(IsATeamMember(A))) $ " teamID=") $ string(A.PlayerReplicationInfo.TeamID)) $ " health=") $ string(A.PlayerReplicationInfo.m_iHealth)));
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
	if((type == 'GameMsg'))
	{
		bGameTypeMsg = true;		
	}
	else
	{
		// End:0x2B
		if((type == 'TeamSay'))
		{
			return;
		}
	}
	aSender = R6PlayerController(Sender);
	// End:0x9F
	if((!bGameTypeMsg))
	{
		// End:0x64
		if(((aSender == none) && (type != 'ServerMessage')))
		{
			return;
		}
		// End:0x9F
		if((((type != 'Line') && (type != 'ServerMessage')) && (!AllowsBroadcast(Sender, Len(Msg)))))
		{
			return;
		}
	}
	// End:0xCB
	if((Pawn(Sender) != none))
	{
		PRI = Pawn(Sender).PlayerReplicationInfo;		
	}
	else
	{
		// End:0xF4
		if((Controller(Sender) != none))
		{
			PRI = Controller(Sender).PlayerReplicationInfo;
		}
	}
	// End:0x125
	if(((type != 'ServerMessage') && (!bGameTypeMsg)))
	{
		// End:0x125
		if(m_bShowLog)
		{
			DebugBroadcaster(aSender, true);
		}
	}
	// End:0x183
	if((aSender != none))
	{
		aSenderPawn = R6Pawn(aSender.Pawn);
		// End:0x183
		if(((aSenderPawn != none) && (aSenderPawn.m_TeamMemberRepInfo != none)))
		{
			(aSenderPawn.m_TeamMemberRepInfo.m_BlinkCounter++);
		}
	}
	// End:0x2EB
	foreach DynamicActors(Class'R6Engine.R6PlayerController', B)
	{
		// End:0x1B2
		if((_GRI == none))
		{
			_GRI = B.GameReplicationInfo;
		}
		bSend = false;
		// End:0x1DF
		if(((type == 'ServerMessage') || bGameTypeMsg))
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
			if(((int(_GRI.m_eCurrectServerState) != _GRI.2) && (int(_GRI.m_eCurrectServerState) != _GRI.3)))
			{
				bSend = true;				
			}
			else
			{
				// End:0x278
				if(IsSpectator(aSender))
				{
					// End:0x275
					if((IsSpectator(B) || IsPlayerDead(B)))
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
						if((IsPlayerDead(B) || IsSpectator(B)))
						{
							bSend = true;
						}						
					}
					else
					{
						// End:0x2C7
						if((!IsPlayerDead(aSender)))
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

