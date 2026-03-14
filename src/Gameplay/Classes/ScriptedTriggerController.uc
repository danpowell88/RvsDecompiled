//=============================================================================
// ScriptedTriggerController - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// ScriptedTriggerController
// used for playing ScriptedTrigger scripts
// A ScriptedTriggerController never has a pawn
//=============================================================================
class ScriptedTriggerController extends ScriptedController;

function InitializeFor(ScriptedTrigger t)
{
	SequenceScript = t;
	ActionNum = 0;
	SequenceScript.SetActions(self);
	__NFUN_113__('Scripting');
	return;
}

function DestroyPawn()
{
	// End:0x17
	if(__NFUN_119__(Instigator, none))
	{
		Instigator.__NFUN_279__();
	}
	return;
}

function ClearAnimation()
{
	return;
}

function SetNewScript(ScriptedSequence NewScript)
{
	SequenceScript = NewScript;
	ActionNum = 0;
	Focus = none;
	SequenceScript.SetActions(self);
	return;
}

state Scripting
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		Instigator = EventInstigator;
		super.Trigger(Other, EventInstigator);
		return;
	}

	function LeaveScripting()
	{
		__NFUN_279__();
		return;
	}
Begin:

	InitForNextAction();
	// End:0x16
	if(bBroken)
	{
		__NFUN_113__('Broken');
	}
	// End:0x2F
	if(CurrentAction.TickedAction())
	{
		__NFUN_117__('Tick');
	}
	stop;				
}

state Broken
{Begin:

	__NFUN_232__(__NFUN_112__(__NFUN_112__(__NFUN_112__(" Trigger Scripted Sequence BROKEN ", string(SequenceScript)), " ACTION "), string(CurrentAction)));
	stop;			
}

