//=============================================================================
// BroadcastHandler - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
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
class BroadcastHandler extends Info
    config
    notplaceable
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var int SentText;
var config bool bMuteSpectators;  // Whether spectators are allowed to speak.

function UpdateSentText()
{
	SentText = 0;
	return;
}

function bool AllowsBroadcast(Actor broadcaster, int Len)
{
	// End:0x36
	if(__NFUN_130__(__NFUN_130__(bMuteSpectators, __NFUN_119__(PlayerController(broadcaster), none)), PlayerController(broadcaster).bOnlySpectator))
	{
		return false;
	}
	__NFUN_161__(SentText, Len);
	return __NFUN_150__(SentText, 260);
	return;
}

function BroadcastText(PlayerReplicationInfo SenderPRI, PlayerController Receiver, coerce string Msg, optional name type)
{
	Receiver.TeamMessage(SenderPRI, Msg, type);
	return;
}

function BroadcastLocalized(Actor Sender, PlayerController Receiver, Class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	Receiver.ReceiveLocalizedMessage(Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	return;
}

function Broadcast(Actor Sender, coerce string Msg, optional name type)
{
	local PlayerController P;
	local PlayerReplicationInfo PRI;

	// End:0x19
	if(__NFUN_129__(AllowsBroadcast(Sender, __NFUN_125__(Msg))))
	{
		return;
	}
	// End:0x45
	if(__NFUN_119__(Pawn(Sender), none))
	{
		PRI = Pawn(Sender).PlayerReplicationInfo;		
	}
	else
	{
		// End:0x6E
		if(__NFUN_119__(Controller(Sender), none))
		{
			PRI = Controller(Sender).PlayerReplicationInfo;
		}
	}
	// End:0x99
	foreach __NFUN_313__(Class'Engine.PlayerController', P)
	{
		BroadcastText(PRI, P, Msg, type);		
	}	
	return;
}

function BroadcastTeam(Actor Sender, coerce string Msg, optional name type)
{
	local PlayerController P;
	local PlayerReplicationInfo PRI;

	// End:0x2C
	if(__NFUN_119__(Pawn(Sender), none))
	{
		PRI = Pawn(Sender).PlayerReplicationInfo;		
	}
	else
	{
		// End:0x55
		if(__NFUN_119__(Controller(Sender), none))
		{
			PRI = Controller(Sender).PlayerReplicationInfo;
		}
	}
	// End:0xAA
	foreach __NFUN_313__(Class'Engine.PlayerController', P)
	{
		// End:0xA9
		if(__NFUN_154__(P.PlayerReplicationInfo.TeamID, PRI.TeamID))
		{
			BroadcastText(PRI, P, Msg, type);
		}		
	}	
	return;
}

event AllowBroadcastLocalized(Actor Sender, Class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	local PlayerController P;

	// End:0x3A
	foreach __NFUN_313__(Class'Engine.PlayerController', P)
	{
		BroadcastLocalized(Sender, P, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);		
	}	
	return;
}

