//=============================================================================
//  R6NoRules.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/24 * Created by Aristomenis Kolokathis 
//                      No rules for MultiPlayer
//=============================================================================
class R6NoRules extends R6MultiPlayerGameInfo;

// --- Functions ---
event PlayerController Login(out string Error, string Options, string Portal) {}
// ^ NEW IN 1.60
function ResetPlayerTeam(Controller aPlayer) {}
function LetPlayerPopIn(Controller aPlayer) {}
function PlayerReadySelected(PlayerController _Controller) {}

state InMPWaitForPlayersMenu
{
    function Tick(float DeltaTime) {}
    function BeginState() {}
}

state InBetweenRoundMenu
{
    function Tick(float DeltaTime) {}
}

defaultproperties
{
}
