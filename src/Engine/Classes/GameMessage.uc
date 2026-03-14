// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class GameMessage extends LocalMessage;

// --- Variables ---
var localized string MaxedOutMessage;
var localized string NoNameChange;
var localized string NewTeamMessageTrailer;
var localized string NewTeamMessage;
var localized string GlobalNameChange;
var localized string OvertimeMessage;
var localized string EnteredMessage;
var localized string FailedSpawnMessage;
var localized string FailedTeamMessage;
var localized string LeftMessage;
var localized string SwitchLevelMessage;
var localized string FailedPlaceMessage;

// --- Functions ---
//
// Messages common to GameInfo derivatives.
//
static function string GetString(optional PlayerReplicationInfo RelatedPRI_1, optional Object OptionalObject, optional int Switch, optional PlayerReplicationInfo RelatedPRI_2) {}

defaultproperties
{
}
