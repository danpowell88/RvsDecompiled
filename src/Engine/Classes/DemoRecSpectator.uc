//=============================================================================
// DemoRecSpectator - spectator for demo recordings to replicate ClientMessages
//=============================================================================
class DemoRecSpectator extends MessagingSpectator;

// --- Variables ---
var PlayerController PlaybackActor;
var GameReplicationInfo PlaybackGRI;

// --- Functions ---
// function ? Tick(...); // REMOVED IN 1.60
delegate ClientMessage(optional name type, coerce string S) {}
function ClientVoiceMessage(byte messageID, name messagetype, PlayerReplicationInfo Recipient, PlayerReplicationInfo Sender) {}
delegate ReceiveLocalizedMessage(optional Object OptionalObject, optional PlayerReplicationInfo RelatedPRI_2, optional PlayerReplicationInfo RelatedPRI_1, optional int Switch, class<LocalMessage> Message) {}
function RepClientMessage(coerce string S, optional name type) {}
function RepClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID) {}
function RepReceiveLocalizedMessage(class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject) {}

defaultproperties
{
}
