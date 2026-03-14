//=============================================================================
// HUD - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// HUD: Superclass of the heads-up display.
//=============================================================================
class HUD extends Actor
    native
    notplaceable;

const c_iTextMessagesMax = 6;
const c_iTextKillMessagesMax = 4;
const c_iTextServerMessagesMax = 3;

struct HUDLocalizedMessage
{
	var Class<LocalMessage> Message;
	var int Switch;
	var PlayerReplicationInfo RelatedPRI;
	var Object OptionalObject;
	var float EndOfLife;
	var float Lifetime;
	var bool bDrawing;
	var int numLines;
	var string StringMessage;
	var Color DrawColor;
	var Font StringFont;
	var float XL;
// NEW IN 1.60
	var float YL;
	var float YPos;
};

// NEW IN 1.60
var byte MessageUseBigFont[3];
//#ifndef R6CODE
//var ScoreBoard Scoreboard;
//#endif
var bool bShowScores;
var bool bShowDebugInfo;  // if true, show properties of current ViewTarget
var bool bHideCenterMessages;  // don't draw centered messages (screen center being used)
var bool bBadConnectionAlert;  // display warning about bad connection
var bool bHideHUD;  // Should the hud display itself.
var float MessageLife[6];
var float MessageKillLife[4];
var float MessageServerLife[3];
// Stock fonts.
var Font SmallFont;  // Small system font.
var Font MedFont;  // Medium system font.
var Font BigFont;  // Big system font.
var Font LargeFont;  // Largest system font.
//#ifdef R6CODE
var R6GameColors Colors;
var HUD nextHUD;  // list of huds which render to the canvas
var PlayerController PlayerOwner;  // always the actual owner
//R6CODE
var Font m_FontRainbow6_14pt;
var Font m_FontRainbow6_17pt;
var Font m_FontRainbow6_22pt;
var Font m_FontRainbow6_36pt;
var Material m_ConsoleBackground;
//R6CONSOLE
var Color m_ChatMessagesColor;
var Color m_KillMessagesColor;
var Color m_ServerMessagesColor;
var string HUDConfigWindowType;
var localized string LoadingMessage;
var localized string SavingMessage;
var localized string ConnectingMessage;
var localized string PausedMessage;
var localized string PrecachingMessage;
var string TextMessages[6];
var string TextKillMessages[4];
var string TextServerMessages[3];

// Export UHUD::execDraw3DLine(FFrame&, void* const)
native final function Draw3DLine(Vector Start, Vector End, Color LineColor);

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	PlayerOwner = PlayerController(Owner);
	Colors = new (none) Class'Engine.R6GameColors';
	// End:0x40
	if(__NFUN_154__(int(Level.NetMode), int(NM_DedicatedServer)))
	{
		return;
	}
	SmallFont = Font(DynamicLoadObject("R6Font.SmallFont", Class'Engine.Font'));
	MedFont = SmallFont;
	BigFont = SmallFont;
	LargeFont = SmallFont;
	m_FontRainbow6_14pt = Font(DynamicLoadObject("R6Font.Rainbow6_14pt", Class'Engine.Font'));
	m_FontRainbow6_17pt = Font(DynamicLoadObject("R6Font.Rainbow6_17pt", Class'Engine.Font'));
	m_FontRainbow6_22pt = Font(DynamicLoadObject("R6Font.Rainbow6_22pt", Class'Engine.Font'));
	m_FontRainbow6_36pt = Font(DynamicLoadObject("R6Font.Rainbow6_36pt", Class'Engine.Font'));
	return;
}

simulated event Destroyed()
{
	PlayerOwner = none;
	super.Destroyed();
	return;
}

event ShowUpgradeMenu()
{
	return;
}

function PlayStartupMessage(byte Stage)
{
	return;
}

function ClearMessage(out HUDLocalizedMessage M)
{
	M.Message = none;
	M.Switch = 0;
	M.RelatedPRI = none;
	M.OptionalObject = none;
	M.EndOfLife = 0.0000000;
	M.StringMessage = "";
	M.DrawColor = Class'Engine.Canvas'.static.MakeColor(byte(255), byte(255), byte(255));
	M.XL = 0.0000000;
	M.bDrawing = false;
	return;
}

function CopyMessage(out HUDLocalizedMessage M1, HUDLocalizedMessage M2)
{
	M1.Message = M2.Message;
	M1.Switch = M2.Switch;
	M1.RelatedPRI = M2.RelatedPRI;
	M1.OptionalObject = M2.OptionalObject;
	M1.EndOfLife = M2.EndOfLife;
	M1.StringMessage = M2.StringMessage;
	M1.DrawColor = M2.DrawColor;
	M1.XL = M2.XL;
	M1.YL = M2.YL;
	M1.YPos = M2.YPos;
	M1.bDrawing = M2.bDrawing;
	M1.Lifetime = M2.Lifetime;
	M1.numLines = M2.numLines;
	return;
}

simulated event WorldSpaceOverlays()
{
	// End:0x2A
	if(__NFUN_130__(bShowDebugInfo, __NFUN_119__(Pawn(PlayerOwner.ViewTarget), none)))
	{
		DrawRoute();
	}
	return;
}

event RenderFirstPersonGun(Canvas Canvas)
{
	local Pawn P;

	// End:0x6B
	if(__NFUN_129__(PlayerOwner.bBehindView))
	{
		P = Pawn(PlayerOwner.ViewTarget);
		// End:0x6B
		if(__NFUN_130__(__NFUN_119__(P, none), __NFUN_119__(P.EngineWeapon, none)))
		{
			P.EngineWeapon.RenderOverlays(Canvas);
		}
	}
	return;
}

// R6CODE
simulated event PostFadeRender(Canvas Canvas)
{
	return;
}

simulated event PostRender(Canvas Canvas)
{
	local HUD H;
	local float YL, YPos;
	local Pawn P;

	DisplayMessages(Canvas);
	// End:0x44
	if(__NFUN_130__(__NFUN_129__(bHideCenterMessages), __NFUN_177__(PlayerOwner.ProgressTimeOut, Level.TimeSeconds)))
	{
		DisplayProgressMessage(Canvas);
	}
	// End:0x53
	if(bBadConnectionAlert)
	{
		DisplayBadConnectionAlert();
	}
	// End:0x9C
	if(bShowDebugInfo)
	{
		YPos = 5.0000000;
		UseSmallFont(Canvas);
		PlayerOwner.ViewTarget.DisplayDebug(Canvas, YL, YPos);		
	}
	else
	{
		H = self;
		J0xA3:

		// End:0xD9 [Loop If]
		if(__NFUN_119__(H, none))
		{
			H.DrawHUD(Canvas);
			H = H.nextHUD;
			// [Loop Continue]
			goto J0xA3;
		}
	}
	return;
}

simulated function DrawRoute()
{
	local int i;
	local Controller C;
	local Vector Start, End, RealStart;
	local bool bPath;

	C = Pawn(PlayerOwner.ViewTarget).Controller;
	// End:0x2F
	if(__NFUN_114__(C, none))
	{
		return;
	}
	// End:0x6C
	if(__NFUN_119__(C.CurrentPath, none))
	{
		Start = C.CurrentPath.Start.Location;		
	}
	else
	{
		Start = PlayerOwner.ViewTarget.Location;
	}
	RealStart = Start;
	// End:0xFE
	if(C.bAdjusting)
	{
		Draw3DLine(C.Pawn.Location, C.AdjustLoc, Class'Engine.Canvas'.static.MakeColor(byte(255), 0, byte(255)));
		Start = C.AdjustLoc;
	}
	// End:0x2DC
	if(__NFUN_132__(__NFUN_114__(C, PlayerOwner), __NFUN_130__(__NFUN_114__(C.MoveTarget, C.RouteCache[0]), __NFUN_119__(C.MoveTarget, none))))
	{
		// End:0x1F8
		if(__NFUN_130__(__NFUN_114__(C, PlayerOwner), __NFUN_218__(C.Destination, vect(0.0000000, 0.0000000, 0.0000000))))
		{
			// End:0x1DE
			if(C.__NFUN_521__(C.Destination))
			{
				Draw3DLine(C.Pawn.Location, C.Destination, Class'Engine.Canvas'.static.MakeColor(byte(255), byte(255), byte(255)));
				return;
			}
			C.__NFUN_518__(C.Destination);
		}
		i = 0;
		J0x1FF:

		// End:0x29C [Loop If]
		if(__NFUN_150__(i, 16))
		{
			// End:0x228
			if(__NFUN_114__(C.RouteCache[i], none))
			{
				// [Explicit Break]
				goto J0x29C;
			}
			bPath = true;
			Draw3DLine(Start, C.RouteCache[i].Location, Class'Engine.Canvas'.static.MakeColor(0, byte(255), 0));
			Start = C.RouteCache[i].Location;
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x1FF;
		}
		J0x29C:

		// End:0x2D9
		if(bPath)
		{
			Draw3DLine(RealStart, C.Destination, Class'Engine.Canvas'.static.MakeColor(byte(255), byte(255), byte(255)));
		}		
	}
	else
	{
		// End:0x339
		if(__NFUN_218__(PlayerOwner.ViewTarget.Velocity, vect(0.0000000, 0.0000000, 0.0000000)))
		{
			Draw3DLine(RealStart, C.Destination, Class'Engine.Canvas'.static.MakeColor(byte(255), byte(255), byte(255)));
		}
	}
	// End:0x34A
	if(__NFUN_114__(C, PlayerOwner))
	{
		return;
	}
	// End:0x37E
	if(__NFUN_119__(C.Focus, none))
	{
		End = C.Focus.Location;		
	}
	else
	{
		End = C.FocalPoint;
	}
	return;
}

function DrawHUD(Canvas Canvas)
{
	return;
}

simulated function DisplayProgressMessage(Canvas Canvas)
{
	local int i;
	local float XL, YL, YOffset;
	local GameReplicationInfo GRI;

	PlayerOwner.ProgressTimeOut = __NFUN_244__(PlayerOwner.ProgressTimeOut, __NFUN_174__(Level.TimeSeconds, float(8)));
	Canvas.Style = 5;
	Canvas.Font = m_FontRainbow6_22pt;
	// End:0x77
	if(__NFUN_114__(Canvas.Font, none))
	{
		UseLargeFont(Canvas);
	}
	YOffset = __NFUN_171__(0.3000000, Canvas.ClipY);
	i = 0;
	J0x99:

	// End:0x15B [Loop If]
	if(__NFUN_150__(i, 4))
	{
		Canvas.DrawColor = PlayerOwner.ProgressColor[i];
		Canvas.__NFUN_464__(PlayerOwner.ProgressMessage[i], XL, YL);
		Canvas.__NFUN_2623__(__NFUN_171__(0.5000000, __NFUN_175__(Canvas.ClipX, XL)), YOffset);
		Canvas.__NFUN_465__(PlayerOwner.ProgressMessage[i], false);
		__NFUN_184__(YOffset, __NFUN_174__(YL, float(1)));
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x99;
	}
	Canvas.__NFUN_2626__(byte(255), byte(255), byte(255));
	return;
}

function DisplayBadConnectionAlert()
{
	return;
}

simulated function Message(PlayerReplicationInfo PRI, coerce string Msg, name MsgType)
{
	// End:0x41
	if(__NFUN_132__(__NFUN_254__(MsgType, 'Say'), __NFUN_254__(MsgType, 'TeamSay')))
	{
		Msg = __NFUN_112__(__NFUN_112__(PRI.PlayerName, ": "), Msg);
	}
	AddTextMessage(Msg, Class'Engine.LocalMessage');
	return;
}

simulated function LocalizedMessage(Class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional string CriticalString)
{
	return;
}

simulated function PlayReceivedMessage(string S, string PName, ZoneInfo PZone)
{
	PlayerOwner.ClientMessage(S);
	return;
}

function bool ProcessKeyEvent(int Key, int Action, float Delta)
{
	// End:0x2A
	if(__NFUN_119__(nextHUD, none))
	{
		return nextHUD.ProcessKeyEvent(Key, Action, Delta);
	}
	return false;
	return;
}

function DisplayMessages(Canvas Canvas)
{
	return;
}

function AddTextMessage(string M, Class<LocalMessage> MessageClass)
{
	local int i, iLifeTime;

	// End:0x16
	if(__NFUN_129__(PlayerOwner.ShouldDisplayIncomingMessages()))
	{
		return;
	}
	iLifeTime = __NFUN_146__(MessageClass.default.Lifetime, 2);
	Class'Engine.Actor'.static.__NFUN_2620__(M, m_ChatMessagesColor);
	i = 0;
	J0x4B:

	// End:0x99 [Loop If]
	if(__NFUN_150__(i, 6))
	{
		// End:0x8F
		if(__NFUN_122__(TextMessages[i], ""))
		{
			TextMessages[i] = M;
			MessageLife[i] = float(iLifeTime);
			return;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x4B;
	}
	i = 0;
	J0xA0:

	// End:0xED [Loop If]
	if(__NFUN_150__(i, __NFUN_147__(6, 1)))
	{
		TextMessages[i] = TextMessages[__NFUN_146__(i, 1)];
		MessageLife[i] = MessageLife[__NFUN_146__(i, 1)];
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xA0;
	}
	TextMessages[__NFUN_147__(6, 1)] = M;
	MessageLife[__NFUN_147__(6, 1)] = float(iLifeTime);
	return;
}

//R6CODE
function AddDeathTextMessage(string M, Class<LocalMessage> MessageClass)
{
	local int i;

	// End:0x31
	if(__NFUN_130__(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)), __NFUN_129__(PlayerOwner.ShouldDisplayIncomingMessages())))
	{
		return;
	}
	Class'Engine.Actor'.static.__NFUN_2620__(M, m_KillMessagesColor);
	i = 0;
	J0x4E:

	// End:0xA5 [Loop If]
	if(__NFUN_150__(i, 4))
	{
		// End:0x9B
		if(__NFUN_122__(TextKillMessages[i], ""))
		{
			TextKillMessages[i] = M;
			MessageKillLife[i] = float(MessageClass.default.Lifetime);
			return;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x4E;
	}
	i = 0;
	J0xAC:

	// End:0xF9 [Loop If]
	if(__NFUN_150__(i, __NFUN_147__(4, 1)))
	{
		TextKillMessages[i] = TextKillMessages[__NFUN_146__(i, 1)];
		MessageKillLife[i] = MessageKillLife[__NFUN_146__(i, 1)];
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xAC;
	}
	TextKillMessages[__NFUN_147__(4, 1)] = M;
	MessageKillLife[__NFUN_147__(4, 1)] = float(MessageClass.default.Lifetime);
	return;
}

//function AddTextServerMessage(string M, class<LocalMessage> MessageClass)
// R6CODE
function AddTextServerMessage(string M, Class<LocalMessage> MessageClass, optional int iLifeTime, optional byte bMessageUseBigFont)
{
	local int i;

	Class'Engine.Actor'.static.__NFUN_2620__(M, m_ServerMessagesColor, bMessageUseBigFont);
	i = 0;
	J0x22:

	// End:0xAB [Loop If]
	if(__NFUN_150__(i, 3))
	{
		// End:0xA1
		if(__NFUN_122__(TextServerMessages[i], ""))
		{
			TextServerMessages[i] = M;
			MessageUseBigFont[i] = bMessageUseBigFont;
			// End:0x8C
			if(__NFUN_152__(iLifeTime, 0))
			{
				MessageServerLife[i] = float(MessageClass.default.Lifetime);				
			}
			else
			{
				MessageServerLife[i] = float(iLifeTime);
			}
			return;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x22;
	}
	i = 0;
	J0xB2:

	// End:0x119 [Loop If]
	if(__NFUN_150__(i, __NFUN_147__(3, 1)))
	{
		TextServerMessages[i] = TextServerMessages[__NFUN_146__(i, 1)];
		MessageServerLife[i] = MessageServerLife[__NFUN_146__(i, 1)];
		MessageUseBigFont[i] = MessageUseBigFont[__NFUN_146__(i, 1)];
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0xB2;
	}
	TextServerMessages[__NFUN_147__(3, 1)] = M;
	MessageUseBigFont[__NFUN_147__(3, 1)] = bMessageUseBigFont;
	MessageServerLife[__NFUN_147__(3, 1)] = float(MessageClass.default.Lifetime);
	return;
}

function UseSmallFont(Canvas Canvas)
{
	// End:0x31
	if(__NFUN_178__(Canvas.ClipX, float(640)))
	{
		Canvas.Font = SmallFont;		
	}
	else
	{
		Canvas.Font = MedFont;
	}
	return;
}

function UseMediumFont(Canvas Canvas)
{
	// End:0x31
	if(__NFUN_178__(Canvas.ClipX, float(640)))
	{
		Canvas.Font = MedFont;		
	}
	else
	{
		Canvas.Font = BigFont;
	}
	return;
}

function UseLargeFont(Canvas Canvas)
{
	// End:0x31
	if(__NFUN_178__(Canvas.ClipX, float(640)))
	{
		Canvas.Font = BigFont;		
	}
	else
	{
		Canvas.Font = LargeFont;
	}
	return;
}

function UseHugeFont(Canvas Canvas)
{
	Canvas.Font = LargeFont;
	return;
}

defaultproperties
{
	m_ChatMessagesColor=(R=255,G=255,B=255,A=255)
	m_KillMessagesColor=(R=255,G=128,B=128,A=255)
	m_ServerMessagesColor=(R=128,G=255,B=128,A=255)
	LoadingMessage="LOADING"
	SavingMessage="SAVING"
	ConnectingMessage="CONNECTING"
	PausedMessage="PAUSED"
	RemoteRole=0
	bHidden=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var L
// REMOVED IN 1.60: function ShowScores
// REMOVED IN 1.60: function ShowDebug
// REMOVED IN 1.60: function PrintActionMessage
// REMOVED IN 1.60: function DrawLevelAction
