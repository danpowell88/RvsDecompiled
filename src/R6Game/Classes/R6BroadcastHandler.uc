// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Game.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6BroadcastHandler extends BroadcastHandler;

// --- Variables ---
var bool m_bShowLog;

// --- Functions ---
function Broadcast(optional name type, Actor Sender, coerce string Msg) {}
function DebugBroadcaster(R6PlayerController A, bool bSender) {}
function bool IsATeamMember(R6PlayerController A) {}
// ^ NEW IN 1.60
function BroadcastTeam(Actor Sender, optional name type, coerce string Msg) {}
function bool IsPlayerDead(R6PlayerController A) {}
// ^ NEW IN 1.60
// A is supposed to be a team member
function bool IsSameTeam(R6PlayerController B, R6PlayerController A) {}
// ^ NEW IN 1.60
function bool IsSpectator(R6PlayerController A) {}
// ^ NEW IN 1.60

defaultproperties
{
}
