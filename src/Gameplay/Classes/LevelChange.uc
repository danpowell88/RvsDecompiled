//=============================================================================
// LevelChange - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//
// Level Change
// When triggered causes change to level described in URL
// OBSOLETE - superceded by ScriptedTrigger
//
class LevelChange extends Triggers;

var() string URL;

function Trigger(Actor Other, Pawn EventInstigator)
{
	return;
}

defaultproperties
{
	bObsolete=true
}
