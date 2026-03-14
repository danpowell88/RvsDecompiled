//=============================================================================
// ACTION_SetAlertness - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_SetAlertness extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

enum EAlertnessType
{
	ALERTNESS_IgnoreAll,            // 0
	ALERTNESS_IgnoreEnemies,        // 1
	ALERTNESS_StayOnScript,         // 2
	ALERTNESS_LeaveScriptForCombat  // 3
};

var(Action) ACTION_SetAlertness.EAlertnessType Alertness;

function bool InitActionFor(ScriptedController C)
{
	C.SetEnemyReaction(int(Alertness));
	return false;
	return;
}

function string GetActionString()
{
	local string S;

	switch(Alertness)
	{
		// End:0x21
		case 0:
			S = "Ignore all";
			// End:0x87
			break;
		// End:0x3F
		case 1:
			S = "Ignore enemies";
			// End:0x87
			break;
		// End:0x5D
		case 2:
			S = "Stay on script";
			// End:0x87
			break;
		// End:0x84
		case 3:
			S = "Leave script for combat";
			// End:0x87
			break;
		// End:0xFFFF
		default:
			break;
	}
	return __NFUN_168__(ActionString, S);
	return;
}

defaultproperties
{
	bValidForTrigger=false
	ActionString="set alertness"
}
