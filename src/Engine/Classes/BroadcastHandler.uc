//=============================================================================
// BroadcastHandler
//
// Message broadcasting is delegated to BroadCastHandler by the GameInfo.  
// The BroadCastHandler handles both text messages (typed by a player) and 
// localized messages (which are identified by a LocalMessage class and id).  
// GameInfos produce localized messages using their DeathMessageClass and 
// GameMessageClass classes.
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class BroadcastHandler extends Info;

// --- Variables ---
var int SentText;
// Whether spectators are allowed to speak.
var config bool bMuteSpectators;

// --- Functions ---
function bool AllowsBroadcast(Actor broadcaster, int Len) {}
// ^ NEW IN 1.60
event AllowBroadcastLocalized(optional Object OptionalObject, optional PlayerReplicationInfo RelatedPRI_2, optional PlayerReplicationInfo RelatedPRI_1, optional int Switch, class<LocalMessage> Message, Actor Sender) {}
function BroadcastTeam(Actor Sender, optional name type, coerce string Msg) {}
function Broadcast(Actor Sender, coerce string Msg, optional name type) {}
function BroadcastLocalized(optional Object OptionalObject, optional PlayerReplicationInfo RelatedPRI_2, optional PlayerReplicationInfo RelatedPRI_1, optional int Switch, class<LocalMessage> Message, PlayerController Receiver, Actor Sender) {}
function BroadcastText(optional name type, coerce string Msg, PlayerController Receiver, PlayerReplicationInfo SenderPRI) {}
function UpdateSentText() {}

defaultproperties
{
}
