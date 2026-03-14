//=============================================================================
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
class LocalMessage extends Info;

// --- Variables ---
// # of seconds to stay in HUD message queue.
var int Lifetime;
// Coordinates to print message at.
var float YPos;
// Color to display message with.
var Color DrawColor;
// If true, put a GetString on the console.
var bool bIsConsoleMessage;
// Indicates a multicolor string message class.
var bool bComplexString;
// If true, don't add to normal queue.
var bool bIsSpecial;
// If true and special, only one can be in the HUD queue at a time.
var bool bIsUnique;
// If true, use fade out effect on message.
var bool bFadeMessage;
// If true, beep!
var bool bBeep;
// If the YPos indicated isn't where the message appears.
var bool bOffsetYPos;
// In some cases, we need to refer to a child message.
var class<LocalMessage> ChildMessage;
// Canvas Variables
// Subtract YPos.
var bool bFromBottom;
var float XPos;
// ^ NEW IN 1.60
// Whether or not to center the message.
var bool bCenter;

// --- Functions ---
static function string GetString(optional Object OptionalObject, optional PlayerReplicationInfo RelatedPRI_2, optional PlayerReplicationInfo RelatedPRI_1, optional int Switch) {}
// ^ NEW IN 1.60
static function ClientReceive(PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject) {}
static function RenderComplexMessage(Canvas Canvas, out float XL, out float YL, optional string MessageString, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject) {}
static function string AssembleString(HUD myHUD, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional string MessageString) {}
// ^ NEW IN 1.60
static function Color GetColor(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2) {}
// ^ NEW IN 1.60
static function float GetOffset(int Switch, float YL, float ClipY) {}
// ^ NEW IN 1.60
static function int GetFontSize(int Switch) {}
// ^ NEW IN 1.60

defaultproperties
{
}
