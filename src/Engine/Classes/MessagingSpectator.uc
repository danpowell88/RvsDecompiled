//=============================================================================
// MessagingSpectator - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// MessagingSpectator - spectator base class for game helper spectators which receive messages
//=============================================================================
class MessagingSpectator extends PlayerController
    abstract
    config(User)
    notplaceable;

function PostBeginPlay()
{
	super.PostBeginPlay();
	bIsPlayer = false;
	return;
}

