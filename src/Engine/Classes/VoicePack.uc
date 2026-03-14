//=============================================================================
// VoicePack.
//=============================================================================
class VoicePack extends Info
    abstract;

// --- Functions ---
function ClientInitialize(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageIndex) {}
function PlayerSpeech(name type, int Index, int Callsign) {}
static function byte GetMessageIndex(name PhraseName) {}
// ^ NEW IN 1.60

defaultproperties
{
}
