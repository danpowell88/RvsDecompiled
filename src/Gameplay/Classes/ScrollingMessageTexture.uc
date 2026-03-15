//=============================================================================
// ScrollingMessageTexture - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ScrollingMessageTexture extends ClientScriptedTexture
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var() int PixelsPerSecond;
var() int ScrollWidth;
var int Position;
var() bool bCaps;
var() bool bResetPosOnTextChange;
var() float YPos;
var float LastDrawTime;
var() Font Font;
var PlayerController Player;
var() Color FontColor;
var() localized string ScrollingMessage;
var localized string HisMessage;
// NEW IN 1.60
var localized string HerMessage;
var string OldText;

simulated function FindPlayer()
{
	local Controller P;

	P = Level.ControllerList;
	J0x14:

	// End:0x7D [Loop If]
	if((P != none))
	{
		// End:0x66
		if((P.IsA('PlayerController') && (Viewport(PlayerController(P).Player) != none)))
		{
			Player = PlayerController(P);
			// [Explicit Break]
			goto J0x7D;
		}
		P = P.nextController;
		// [Loop Continue]
		goto J0x14;
	}
	J0x7D:

	return;
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local string Text;
	local PlayerReplicationInfo Leading, PRI;

	// End:0x11
	if((Player == none))
	{
		FindPlayer();
	}
	// End:0x4A
	if((((Player == none) || (Player.PlayerReplicationInfo == none)) || (Player.GameReplicationInfo == none)))
	{
		return;
	}
	// End:0x6E
	if((LastDrawTime == float(0)))
	{
		Position = Tex.USize;		
	}
	else
	{
		(Position -= int(((Level.TimeSeconds - LastDrawTime) * float(PixelsPerSecond))));
	}
	// End:0xBA
	if((Position < (-ScrollWidth)))
	{
		Position = Tex.USize;
	}
	LastDrawTime = Level.TimeSeconds;
	Text = ScrollingMessage;
	// End:0x111
	if(Player.PlayerReplicationInfo.bIsFemale)
	{
		Text = Replace(Text, "%h", HerMessage);		
	}
	else
	{
		Text = Replace(Text, "%h", HisMessage);
	}
	Text = Replace(Text, "%p", Player.PlayerReplicationInfo.PlayerName);
	// End:0x258
	if(((InStr(Text, "%lf") != -1) || (InStr(Text, "%lp") != -1)))
	{
		Leading = none;
		// End:0x1EC
		foreach AllActors(Class'Engine.PlayerReplicationInfo', PRI)
		{
			// End:0x1EB
			if(((!PRI.bIsSpectator) && ((Leading == none) || (PRI.Score > Leading.Score))))
			{
				Leading = PRI;
			}			
		}		
		// End:0x20C
		if((Leading == none))
		{
			Leading = Player.PlayerReplicationInfo;
		}
		Text = Replace(Text, "%lp", Leading.PlayerName);
		Text = Replace(Text, "%lf", string(int(Leading.Score)));
	}
	// End:0x26E
	if(bCaps)
	{
		Text = Caps(Text);
	}
	// End:0x2A7
	if(((Text != OldText) && bResetPosOnTextChange))
	{
		Position = Tex.USize;
		OldText = Text;
	}
	Tex.DrawColoredText(float(Position), YPos, Text, Font, FontColor);
	return;
}

simulated function string Replace(string Text, string Match, string Replacement)
{
	local int i;

	i = InStr(Text, Match);
	// End:0x5F
	if((i != -1))
	{
		return ((Left(Text, i) $ Replacement) $ Replace(Mid(Text, (i + Len(Match))), Match, Replacement));		
	}
	else
	{
		return Text;
	}
	return;
}

defaultproperties
{
	bResetPosOnTextChange=true
	HisMessage="his"
	HerMessage="her"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var e
