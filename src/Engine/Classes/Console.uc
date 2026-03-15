//=============================================================================
// Console - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Console - A quick little command line console that accepts most commands.

//=============================================================================
class Console extends Interaction
    native
    config;

const MaxHistory = 16;

var globalconfig byte ConsoleKey;  // Key used to bring up the console
var int HistoryTop;
// NEW IN 1.60
var int HistoryBot;
// NEW IN 1.60
var int HistoryCur;
var globalconfig int iBrowserMaxNbServerPerPage;
var bool bTyping;  // Turn when someone is typing on the console
var bool bIgnoreKeys;  // Ignore Key presses until a new KeyDown is received
//R6CODE
var bool bShowLog;
var bool bShowConsoleLog;
var bool m_bStringIsTooLong;
var bool m_bStartedByGSClient;  // Flag to indicate if the game was launched by the ubi.com client
var bool m_bNonUbiMatchMaking;  // Flag to indicate that this game will not be using UBI.com
var bool m_bNonUbiMatchMakingHost;  // Flag to indicate that this host will not be using UBI.com
var bool m_bInterruptConnectionProcess;  // Flag to indicate that a process is interrupted by user or not
// NEW IN 1.60
var bool m_bAutoLoginFirstPass;
// NEW IN 1.60
var bool m_bChangeModInProgress;
var string TypedStr;  // Holds the current command, and the history
// NEW IN 1.60
var string History[16];

function GetAllMissionDescriptions(string szCurrentMapDir)
{
	return;
}

// Begin typing a command on the console.
exec function type()
{
	TypedStr = "";
	bShowConsoleLog = true;
	GotoState('Typing');
	return;
}

exec function Talk()
{
	TypedStr = "Say ";
	bShowConsoleLog = false;
	GotoState('Typing');
	return;
}

exec function TeamTalk()
{
	local GameReplicationInfo GameInfo;

	// End:0x67
	if((ViewportOwner.Actor != none))
	{
		GameInfo = ViewportOwner.Actor.GameReplicationInfo;
		// End:0x67
		if((!ViewportOwner.Actor.Level.IsGameTypeTeamAdversarial(GameInfo.m_szGameTypeFlagRep)))
		{
			return;
		}
	}
	TypedStr = "TeamSay ";
	bShowConsoleLog = false;
	GotoState('Typing');
	return;
}

event Message(coerce string Msg, float MsgLife)
{
	return;
}

function bool KeyEvent(Interactions.EInputKey Key, Interactions.EInputAction Action, float Delta)
{
	// End:0x46
	if(bShowLog)
	{
		Log(((("Console state \" KeyEvent eAction" @ string(Action)) @ "Key") @ string(Key)));
	}
	// End:0x5B
	if((int(Action) != int(1)))
	{
		return false;		
	}
	else
	{
		// End:0x7A
		if((int(Key) == int(ConsoleKey)))
		{
			GotoState('Typing');
			return true;			
		}
		else
		{
			return false;
		}
	}
	return;
}

function bool KeyType(Interactions.EInputKey Key)
{
	// End:0x31
	if(bShowLog)
	{
		Log(("Console state \" KeyType Key" @ string(Key)));
	}
	return false;
	return;
}

state Typing
{
// Begin typing a command on the console.
	exec function type()
	{
		TypedStr = "";
		GotoState('None');
		return;
	}

	function bool KeyType(Interactions.EInputKey Key)
	{
		local string OutStr;
		local float XL, YL;

		// End:0x36
		if(bShowLog)
		{
			Log(("Console state Typing KeyType Key" @ string(Key)));
		}
		// End:0x41
		if(bIgnoreKeys)
		{
			return true;
		}
		// End:0x4C
		if(m_bStringIsTooLong)
		{
			return true;
		}
		// End:0x13E
		if(((((int(Key) >= 32) && (int(Key) < 256)) && (int(Key) != Asc("~"))) && (int(Key) != Asc("`"))))
		{
			TypedStr = (TypedStr $ Chr(int(Key)));
			Class'Engine.Actor'.static.GetCanvas().Font = Class'Engine.Actor'.static.GetCanvas().SmallFont;
			OutStr = (("(>", TypedStr) @ "_");
			Class'Engine.Actor'.static.GetCanvas().StrLen(OutStr, XL, YL);
			// End:0x13C
			if((XL > (float(Class'Engine.Actor'.static.GetCanvas().SizeX) * 0.9500000)))
			{
				m_bStringIsTooLong = true;
			}
			return true;
		}
		return;
	}

	function bool KeyEvent(Interactions.EInputKey Key, Interactions.EInputAction Action, float Delta)
	{
		local string temp;
		local int i;

		// End:0x4A
		if(bShowLog)
		{
			Log(((("Console state Typing KeyEvent Action" @ string(Action)) @ "Key") @ string(Key)));
		}
		// End:0x62
		if((int(Action) == int(1)))
		{
			bIgnoreKeys = false;
		}
		// End:0xA0
		if((int(Key) == int(27)))
		{
			// End:0x96
			if((TypedStr != ""))
			{
				TypedStr = "";
				HistoryCur = HistoryTop;
				return true;				
			}
			else
			{
				GotoState('None');
			}			
		}
		else
		{
			// End:0xBD
			if(global.KeyEvent(Key, Action, Delta))
			{
				return true;				
			}
			else
			{
				// End:0xD2
				if((int(Action) != int(1)))
				{
					return false;					
				}
				else
				{
					// End:0x1D9
					if((int(Key) == int(13)))
					{
						// End:0x1CD
						if((TypedStr != ""))
						{
							Message(TypedStr, 6.0000000);
							History[HistoryTop] = TypedStr;
							HistoryTop = int((float((HistoryTop + 1)) % float(16)));
							// End:0x15F
							if(((HistoryBot == -1) || (HistoryBot == HistoryTop)))
							{
								HistoryBot = int((float((HistoryBot + 1)) % float(16)));
							}
							HistoryCur = HistoryTop;
							temp = TypedStr;
							TypedStr = "";
							// End:0x1B6
							if((!ConsoleCommand(temp)))
							{
								Message(Localize("Errors", "Exec", "R6Engine"), 6.0000000);
							}
							Message("", 6.0000000);
							GotoState('None');							
						}
						else
						{
							GotoState('None');
						}
						return true;						
					}
					else
					{
						// End:0x244
						if((int(Key) == int(38)))
						{
							// End:0x23F
							if((HistoryBot >= 0))
							{
								// End:0x211
								if((HistoryCur == HistoryBot))
								{
									HistoryCur = HistoryTop;									
								}
								else
								{
									(HistoryCur--);
									// End:0x22E
									if((HistoryCur < 0))
									{
										HistoryCur = (16 - 1);
									}
								}
								TypedStr = History[HistoryCur];
							}
							return true;							
						}
						else
						{
							// End:0x2A8
							if((int(Key) == int(40)))
							{
								// End:0x2A5
								if((HistoryBot >= 0))
								{
									// End:0x27C
									if((HistoryCur == HistoryTop))
									{
										HistoryCur = HistoryBot;										
									}
									else
									{
										HistoryCur = int((float((HistoryCur + 1)) % float(16)));
									}
									TypedStr = History[HistoryCur];
								}								
							}
							else
							{
								// End:0x2F0
								if(((int(Key) == int(8)) || (int(Key) == int(37))))
								{
									// End:0x2EE
									if((Len(TypedStr) > 0))
									{
										TypedStr = Left(TypedStr, (Len(TypedStr) - 1));
									}
									return true;
								}
							}
						}
					}
				}
			}
		}
		return true;
		return;
	}

	function PostRender(Canvas Canvas)
	{
		local float XL $ YL;
		local string OutStr;
		local float OrgX)