//=============================================================================
// VoicePack - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// VoicePack.
//=============================================================================
class VoicePack extends Info
    abstract
    notplaceable
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

function ClientInitialize(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageIndex)
{
	return;
}

function PlayerSpeech(name type, int Index, int Callsign)
{
	return;
}

static function byte GetMessageIndex(name PhraseName)
{
	return 0;
	return;
}

defaultproperties
{
	RemoteRole=0
	LifeSpan=10.0000000
}
