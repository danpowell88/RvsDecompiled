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
	__NFUN_113__('Typing');
	return;
}

exec function Talk()
{
	TypedStr = "Say ";
	bShowConsoleLog = false;
	__NFUN_113__('Typing');
	return;
}

exec function TeamTalk()
{
	local GameReplicationInfo GameInfo;

	// End:0x67
	if(__NFUN_119__(ViewportOwner.Actor, none))
	{
		GameInfo = ViewportOwner.Actor.GameReplicationInfo;
		// End:0x67
		if(__NFUN_129__(ViewportOwner.Actor.Level.IsGameTypeTeamAdversarial(GameInfo.m_szGameTypeFlagRep)))
		{
			return;
		}
	}
	TypedStr = "TeamSay ";
	bShowConsoleLog = false;
	__NFUN_113__('Typing');
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
		__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_168__("Console state \" KeyEvent eAction", string(Action)), "Key"), string(Key)));
	}
	// End:0x5B
	if(__NFUN_155__(int(Action), int(1)))
	{
		return false;		
	}
	else
	{
		// End:0x7A
		if(__NFUN_154__(int(Key), int(ConsoleKey)))
		{
			__NFUN_113__('Typing');
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
		__NFUN_231__(__NFUN_168__("Console state \" KeyType Key", string(Key)));
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
		__NFUN_113__('None');
		return;
	}

	function bool KeyType(Interactions.EInputKey Key)
	{
		local string OutStr;
		local float XL, YL;

		// End:0x36
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__("Console state Typing KeyType Key", string(Key)));
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
		if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_153__(int(Key), 32), __NFUN_150__(int(Key), 256)), __NFUN_155__(int(Key), __NFUN_237__("~"))), __NFUN_155__(int(Key), __NFUN_237__("`"))))
		{
			TypedStr = __NFUN_112__(TypedStr, __NFUN_236__(int(Key)));
			Class'Engine.Actor'.static.__NFUN_2618__().Font = Class'Engine.Actor'.static.__NFUN_2618__().SmallFont;
			OutStr = __NFUN_112__(__NFUN_168__("(>", TypedStr), "_");
			Class'Engine.Actor'.static.__NFUN_2618__().__NFUN_464__(OutStr, XL, YL);
			// End:0x13C
			if(__NFUN_177__(XL, __NFUN_171__(float(Class'Engine.Actor'.static.__NFUN_2618__().SizeX), 0.9500000)))
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
			__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_168__("Console state Typing KeyEvent Action", string(Action)), "Key"), string(Key)));
		}
		// End:0x62
		if(__NFUN_154__(int(Action), int(1)))
		{
			bIgnoreKeys = false;
		}
		// End:0xA0
		if(__NFUN_154__(int(Key), int(27)))
		{
			// End:0x96
			if(__NFUN_123__(TypedStr, ""))
			{
				TypedStr = "";
				HistoryCur = HistoryTop;
				return true;				
			}
			else
			{
				__NFUN_113__('None');
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
				if(__NFUN_155__(int(Action), int(1)))
				{
					return false;					
				}
				else
				{
					// End:0x1D9
					if(__NFUN_154__(int(Key), int(13)))
					{
						// End:0x1CD
						if(__NFUN_123__(TypedStr, ""))
						{
							Message(TypedStr, 6.0000000);
							History[HistoryTop] = TypedStr;
							HistoryTop = int(__NFUN_173__(float(__NFUN_146__(HistoryTop, 1)), float(16)));
							// End:0x15F
							if(__NFUN_132__(__NFUN_154__(HistoryBot, -1), __NFUN_154__(HistoryBot, HistoryTop)))
							{
								HistoryBot = int(__NFUN_173__(float(__NFUN_146__(HistoryBot, 1)), float(16)));
							}
							HistoryCur = HistoryTop;
							temp = TypedStr;
							TypedStr = "";
							// End:0x1B6
							if(__NFUN_129__(ConsoleCommand(temp)))
							{
								Message(Localize("Errors", "Exec", "R6Engine"), 6.0000000);
							}
							Message("", 6.0000000);
							__NFUN_113__('None');							
						}
						else
						{
							__NFUN_113__('None');
						}
						return true;						
					}
					else
					{
						// End:0x244
						if(__NFUN_154__(int(Key), int(38)))
						{
							// End:0x23F
							if(__NFUN_153__(HistoryBot, 0))
							{
								// End:0x211
								if(__NFUN_154__(HistoryCur, HistoryBot))
								{
									HistoryCur = HistoryTop;									
								}
								else
								{
									__NFUN_166__(HistoryCur);
									// End:0x22E
									if(__NFUN_150__(HistoryCur, 0))
									{
										HistoryCur = __NFUN_147__(16, 1);
									}
								}
								TypedStr = History[HistoryCur];
							}
							return true;							
						}
						else
						{
							// End:0x2A8
							if(__NFUN_154__(int(Key), int(40)))
							{
								// End:0x2A5
								if(__NFUN_153__(HistoryBot, 0))
								{
									// End:0x27C
									if(__NFUN_154__(HistoryCur, HistoryTop))
									{
										HistoryCur = HistoryBot;										
									}
									else
									{
										HistoryCur = int(__NFUN_173__(float(__NFUN_146__(HistoryCur, 1)), float(16)));
									}
									TypedStr = History[HistoryCur];
								}								
							}
							else
							{
								// End:0x2F0
								if(__NFUN_132__(__NFUN_154__(int(Key), int(8)), __NFUN_154__(int(Key), int(37))))
								{
									// End:0x2EE
									if(__NFUN_151__(__NFUN_125__(TypedStr), 0))
									{
										TypedStr = __NFUN_128__(TypedStr, __NFUN_147__(__NFUN_125__(TypedStr), 1));
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
		local float XL, YL;
		local string OutStr;
		local float OrgX, OrgY;

		OrgX = Canvas.OrgX;
		OrgY = Canvas.OrgY;
		Canvas.__NFUN_2624__(0.0000000, 0.0000000);
		Canvas.ClipX = float(Canvas.SizeX);
		Canvas.ClipY = float(Canvas.SizeY);
		Canvas.Style = 1;
		Canvas.Font = Canvas.SmallFont;
		OutStr = __NFUN_112__(__NFUN_168__(">", TypedStr), "_");
		Canvas.__NFUN_464__(OutStr, XL, YL);
		Canvas.__NFUN_2623__(0.0000000, __NFUN_175__(float(__NFUN_147__(Canvas.SizeY, 6)), YL));
		Canvas.__NFUN_466__(Texture'Engine.ConsoleBK', float(Canvas.SizeX), __NFUN_174__(YL, float(6)), 0.0000000, 0.0000000, 32.0000000, 32.0000000);
		Canvas.__NFUN_2623__(0.0000000, __NFUN_175__(float(__NFUN_147__(Canvas.SizeY, 8)), YL));
		Canvas.__NFUN_2626__(128, 128, 128);
		Canvas.__NFUN_466__(Texture'Engine.ConsoleBdr', float(Canvas.SizeX), 2.0000000, 0.0000000, 0.0000000, 32.0000000, 32.0000000);
		Canvas.__NFUN_2626__(byte(255), byte(255), byte(255));
		Canvas.__NFUN_2623__(0.0000000, __NFUN_175__(float(__NFUN_147__(Canvas.SizeY, 3)), YL));
		Canvas.bCenter = false;
		Canvas.__NFUN_465__(OutStr, false);
		Canvas.__NFUN_2624__(OrgX, OrgY);
		return;
	}

	function BeginState()
	{
		bTyping = true;
		bVisible = true;
		bIgnoreKeys = true;
		HistoryCur = HistoryTop;
		m_bStringIsTooLong = false;
		return;
	}

	function EndState()
	{
		bTyping = false;
		bVisible = false;
		return;
	}
	stop;
}

defaultproperties
{
	ConsoleKey=192
	HistoryBot=-1
	iBrowserMaxNbServerPerPage=400
	bRequiresTick=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var r
// REMOVED IN 1.60: function GameServiceTick
// REMOVED IN 1.60: function ListMods
// REMOVED IN 1.60: function ShowModInfo
// REMOVED IN 1.60: function ListRegObj
