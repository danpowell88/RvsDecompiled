//=============================================================================
// LocalMessage - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// LocalMessage
//
// LocalMessages are abstract classes which contain an array of localized text.  
// The PlayerController function ReceiveLocalizedMessage() is used to send messages 
// to a specific player by specifying the LocalMessage class and index.  This allows 
// the message to be localized on the client side, and saves network bandwidth since 
// the text is not sent.  Actors (such as the GameInfo) use one or more LocalMessage 
// classes to send messages.  The BroadcastHandler function BroadcastLocalizedMessage() 
// is used to broadcast localized messages to all the players.
//
//=============================================================================
class LocalMessage extends Info
    notplaceable
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var int Lifetime;  // # of seconds to stay in HUD message queue.
var bool bComplexString;  // Indicates a multicolor string message class.
var bool bIsSpecial;  // If true, don't add to normal queue.
var bool bIsUnique;  // If true and special, only one can be in the HUD queue at a time.
var bool bIsConsoleMessage;  // If true, put a GetString on the console.
var bool bFadeMessage;  // If true, use fade out effect on message.
var bool bBeep;  // If true, beep!
var bool bOffsetYPos;  // If the YPos indicated isn't where the message appears.
// Canvas Variables
var bool bFromBottom;  // Subtract YPos.
var bool bCenter;  // Whether or not to center the message.
var float XPos;  // Coordinates to print message at.
// NEW IN 1.60
var float YPos;
var Class<LocalMessage> ChildMessage;  // In some cases, we need to refer to a child message.
var Color DrawColor;  // Color to display message with.

static function RenderComplexMessage(Canvas Canvas, out float XL, out float YL, optional string MessageString, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	return;
}

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	// End:0x34
	if((Class<Actor>(OptionalObject) != none))
	{
		return Class<Actor>(OptionalObject).static.GetLocalString(Switch, RelatedPRI_1, RelatedPRI_2);
	}
	return "";
	return;
}

static function string AssembleString(HUD myHUD, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional string MessageString)
{
	return "";
	return;
}

static function ClientReceive(PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	P.myHUD.LocalizedMessage(default.Class, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	// End:0x91
	if(default.bIsConsoleMessage)
	{
		P.Player.InteractionMaster.Process_Message(GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject), 6.0000000, P.Player.LocalInteractions);
	}
	return;
}

static function Color GetColor(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	return default.DrawColor;
	return;
}

static function float GetOffset(int Switch, float YL, float ClipY)
{
	return default.YPos;
	return;
}

static function int GetFontSize(int Switch)
{
	return;
}

defaultproperties
{
	Lifetime=6
	DrawColor=(R=255,G=255,B=255,A=255)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var s
