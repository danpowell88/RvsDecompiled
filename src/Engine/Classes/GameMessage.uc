//=============================================================================
// GameMessage - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class GameMessage extends LocalMessage
	notplaceable
 hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var localized string SwitchLevelMessage;
var localized string LeftMessage;
var localized string FailedTeamMessage;
var localized string FailedPlaceMessage;
var localized string FailedSpawnMessage;
var localized string EnteredMessage;
var localized string MaxedOutMessage;
var localized string OvertimeMessage;
var localized string GlobalNameChange;
var localized string NewTeamMessage;
var localized string NewTeamMessageTrailer;
var localized string NoNameChange;

//
// Messages common to GameInfo derivatives.
//
static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	switch(Switch)
	{
		// End:0x14
		case 0:
			return default.OvertimeMessage;
			// End:0x123
			break;
		// End:0x3F
		case 1:
			// End:0x26
			if(__NFUN_114__(RelatedPRI_1, none))
			{
				return "";
			}
			return __NFUN_112__(RelatedPRI_1.PlayerName, default.EnteredMessage);
			// End:0x123
			break;
		// End:0x7B
		case 2:
			// End:0x52
			if(__NFUN_114__(RelatedPRI_1, none))
			{
				return "";
			}
			return __NFUN_168__(__NFUN_168__(RelatedPRI_1.OldName, default.GlobalNameChange), RelatedPRI_1.PlayerName);
			// End:0x123
			break;
		// End:0xBC
		case 3:
			// End:0x8E
			if(__NFUN_114__(RelatedPRI_1, none))
			{
				return "";
			}
			// End:0x9C
			if(__NFUN_114__(OptionalObject, none))
			{
				return "";
			}
			return __NFUN_168__(__NFUN_168__(RelatedPRI_1.PlayerName, default.NewTeamMessage), default.NewTeamMessageTrailer);
			// End:0x123
			break;
		// End:0xE8
		case 4:
			// End:0xCF
			if(__NFUN_114__(RelatedPRI_1, none))
			{
				return "";
			}
			return __NFUN_112__(RelatedPRI_1.PlayerName, default.LeftMessage);
			// End:0x123
			break;
		// End:0xF6
		case 5:
			return default.SwitchLevelMessage;
			// End:0x123
			break;
		// End:0x104
		case 6:
			return default.FailedTeamMessage;
			// End:0x123
			break;
		// End:0x112
		case 7:
			return default.MaxedOutMessage;
			// End:0x123
			break;
		// End:0x120
		case 8:
			return default.NoNameChange;
			// End:0x123
			break;
		// End:0xFFFF
		default:
			break;
	}
	return "";
	return;
}

defaultproperties
{
	SwitchLevelMessage="Switching Levels"
	LeftMessage=" left the game."
	FailedTeamMessage="Could not find team for player"
	FailedPlaceMessage="Could not find a starting spot"
	FailedSpawnMessage="Could not spawn player"
	EnteredMessage=" entered the game."
	MaxedOutMessage="Server is already at capacity."
	OvertimeMessage="Score tied at the end of regulation. Sudden Death Overtime!!!"
	GlobalNameChange="changed name to"
	NewTeamMessage="is now on"
	NoNameChange="Name is already in use."
}
