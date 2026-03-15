//=============================================================================
// DemoRecSpectator - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// DemoRecSpectator - spectator for demo recordings to replicate ClientMessages
//=============================================================================
class DemoRecSpectator extends MessagingSpectator
    config(User)
    notplaceable;

var PlayerController PlaybackActor;
var GameReplicationInfo PlaybackGRI;

replication
{
	// Pos:0x000
	reliable if(bDemoRecording)
		RepClientMessage, RepClientVoiceMessage, 
		RepReceiveLocalizedMessage;
}

function ClientMessage(coerce string S, optional name type)
{
	RepClientMessage(S, type);
	return;
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	RepClientVoiceMessage(Sender, Recipient, messagetype, messageID);
	return;
}

function ReceiveLocalizedMessage(Class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	RepReceiveLocalizedMessage(Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	return;
}

simulated function RepClientMessage(coerce string S, optional name type)
{
	return;
}

simulated function RepClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	return;
}

simulated function RepReceiveLocalizedMessage(Class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function Tick
