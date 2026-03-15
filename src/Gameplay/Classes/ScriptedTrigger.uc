//=============================================================================
// ScriptedTrigger - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// ScriptedTrigger
// replaces Counter, Dispatcher, SpecialEventTrigger
//=============================================================================
class ScriptedTrigger extends ScriptedSequence;

function PostBeginPlay()
{
	local ScriptedTriggerController TriggerController;

	super(Actor).PostBeginPlay();
	TriggerController = Spawn(Class'Gameplay.ScriptedTriggerController');
	TriggerController.InitializeFor(self);
	return;
}

function bool ValidAction(int N)
{
	return Actions[N].bValidForTrigger;
	return;
}

defaultproperties
{
	Texture=Texture'Gameplay.S_SpecialEvent'
}
