//=============================================================================
// AccessControl - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// AccessControl.
//
// AccessControl is a helper class for GameInfo.
// The AccessControl class determines whether or not the player is allowed to 
// login in the PreLogin() function, and also controls whether or not a player 
// can enter as a spectator or a game administrator.
//
//=============================================================================

/* #ifndef R6CODE
class AccessControl extends Info
    config(BanList)
    notplaceable
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var config array<string> Banned;
var private string AdminPassword;  // Password to receive bAdmin privileges.
var private string GamePassword;  // Password to enter game.

function SetAdminPassword(string P)
{
	AdminPassword = P;
	return;
}

function SetGamePassword(string P)
{
	GamePassword = P;
	return;
}

//#ifdef R6CODE 
function string GetGamePassword()
{
	return GamePassword;
	return;
}

function bool GamePasswordNeeded()
{
	return (GamePassword != "");
	return;
}

function KickBan(string S)
{
	local Controller _Ctrl;
	local PlayerController P;
	local string ID;
	local int j, i;

	_Ctrl = Level.ControllerList;
	J0x14:

	// End:0xEC [Loop If]
	if((_Ctrl != none))
	{
		P = PlayerController(_Ctrl);
		// End:0xD5
		if((((P != none) && (P.PlayerReplicationInfo.PlayerName ~= S)) && (NetConnection(P.Player) != none)))
		{
			ID = P.m_szGlobalID;
			// End:0xD3
			if((!IsGlobalIDBanned(ID)))
			{
				Log(("Adding ID Ban for: " $ Caps(ID)));
				Banned[Banned.Length] = Caps(ID);
				SaveConfig();
			}
			return;
		}
		_Ctrl = _Ctrl.nextController;
		// [Loop Continue]
		goto J0x14;
	}
	return;
}

function int RemoveBan(string szBanPrefix)
{
	local int i, iMatchesFound, iPosFound;

	iMatchesFound = 0;
	i = -1;
	J0x12:

	(i++);
	i = NextMatchingID(szBanPrefix, i);
	// End:0x50
	if((i > -1))
	{
		(iMatchesFound++);
		iPosFound = i;
	}
	// End:0x12
	if(!((i == -1)))
		goto J0x12;
	// End:0x79
	if((iMatchesFound == 1))
	{
		Banned.Remove(iPosFound, 1);
		SaveConfig();
	}
	return iMatchesFound;
	return;
}

function int NextMatchingID(string szBanPrefix, int iLastIt)
{
	local int i;

	i = iLastIt;
	J0x0B:

	// End:0x4B [Loop If]
	if((i < Banned.Length))
	{
		// End:0x41
		if((Strnicmp(Banned[i], szBanPrefix, Len(szBanPrefix)) == 0))
		{
			return i;
		}
		(i++);
		// [Loop Continue]
		goto J0x0B;
	}
	// End:0x61
	if((i >= Banned.Length))
	{
		return -1;
	}
	return;
}

// NEW IN 1.60
event PreLogin(string Options, string Address, out string Error, out string FailCode, bool bSpectator)
{
	local string InPassword, SpectatorClass;
	local PlayerController P;

	Error = "";
	InPassword = Level.Game.ParseOption(Options, "Password");
	// End:0x92
	if(((int(Level.NetMode) != int(NM_Standalone)) && Level.Game.AtCapacity(bSpectator)))
	{
		Error = "PopUp_Error_ServerFull";		
	}
	else
	{
		// End:0xF7
		if((((GamePassword != "") && (InPassword != GamePassword)) && ((AdminPassword == "") || (InPassword != AdminPassword))))
		{
			Error = "PopUp_Error_PassWd";
			FailCode = "WRONGPW";
		}
	}
	return;
}

event bool IsGlobalIDBanned(string GlobalID)
{
	local int i;
	local string szGlobalID;

	i = 0;
	J0x07:

	// End:0x38 [Loop If]
	if((i < Banned.Length))
	{
		// End:0x2E
		if((Banned[i] ~= GlobalID))
		{
			return true;
		}
		(++i);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var IPPolicies50
// REMOVED IN 1.60: var IPBanned
// REMOVED IN 1.60: var AdminClass
