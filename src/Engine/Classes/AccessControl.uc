//=============================================================================
// AccessControl.
//
// AccessControl is a helper class for GameInfo.
// The AccessControl class determines whether or not the player is allowed to 
// login in the PreLogin() function, and also controls whether or not a player 
// can enter as a spectator or a game administrator.
//
//=============================================================================
class AccessControl extends Info;

// --- Variables ---
// var ? AdminClass; // REMOVED IN 1.60
// var ? IPBanned; // REMOVED IN 1.60
// var ? IPPolicies; // REMOVED IN 1.60
var config array<array> Banned;
// Password to enter game.
var string GamePassword;
// Password to receive bAdmin privileges.
var string AdminPassword;

// --- Functions ---
event PreLogin(out string Error, bool bSpectator, out string FailCode, string Options, string Address) {}
// ^ NEW IN 1.60
event bool IsGlobalIDBanned(string GlobalID) {}
// ^ NEW IN 1.60
function KickBan(string S) {}
function int NextMatchingID(string szBanPrefix, int iLastIt) {}
// ^ NEW IN 1.60
function int RemoveBan(string szBanPrefix) {}
// ^ NEW IN 1.60
function SetGamePassword(string P) {}
function SetAdminPassword(string P) {}
//#ifdef R6CODE
function string GetGamePassword() {}
// ^ NEW IN 1.60
function bool GamePasswordNeeded() {}
// ^ NEW IN 1.60

defaultproperties
{
}
