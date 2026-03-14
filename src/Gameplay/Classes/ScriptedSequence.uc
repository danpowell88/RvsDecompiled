//=============================================================================
// ScriptedSequence - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// ScriptedSequence
// used for setting up scripted sequences for pawns.
// A ScriptedController is spawned to carry out the scripted sequence.
//=============================================================================
class ScriptedSequence extends AIScript;

var Class<ScriptedController> ScriptControllerClass;
var(AIScript) export editinline array<export editinline ScriptedAction> Actions;

function SpawnControllerFor(Pawn P)
{
	super.SpawnControllerFor(P);
	TakeOver(P);
	return;
}

function TakeOver(Pawn P)
{
	local ScriptedController S;

	// End:0x35
	if(__NFUN_119__(ScriptedController(P.Controller), none))
	{
		S = ScriptedController(P.Controller);		
	}
	else
	{
		S = __NFUN_278__(ScriptControllerClass);
		S.PendingController = P.Controller;
		// End:0x8C
		if(__NFUN_119__(S.PendingController, none))
		{
			S.PendingController.PendingStasis();
		}
	}
	S.MyScript = self;
	S.TakeControlOf(P);
	S.SetNewScript(self);
	return;
}

function bool ValidAction(int N)
{
	return true;
	return;
}

function SetActions(ScriptedController C)
{
	local ScriptedSequence NewScript;
	local bool bDone;

	// End:0x31
	if(__NFUN_119__(C.CurrentAnimation, none))
	{
		C.CurrentAnimation.SetCurrentAnimationFor(C);
	}
	J0x31:

	// End:0x2C8 [Loop If]
	if(__NFUN_129__(bDone))
	{
		// End:0xF8
		if(__NFUN_150__(C.ActionNum, Actions.Length))
		{
			// End:0x94
			if(ValidAction(C.ActionNum))
			{
				NewScript = Actions[C.ActionNum].GetScript(self);				
			}
			else
			{
				NewScript = none;
				__NFUN_232__(__NFUN_112__(__NFUN_168__(__NFUN_112__(__NFUN_112__(GetItemName(string(self)), " action "), string(C.ActionNum)), Actions[C.ActionNum].GetActionString()), " NOT VALID!!!"));
			}			
		}
		else
		{
			NewScript = none;
		}
		// End:0x11C
		if(__NFUN_114__(NewScript, none))
		{
			C.CurrentAction = none;
			return;
		}
		// End:0x13D
		if(__NFUN_119__(NewScript, self))
		{
			C.SetNewScript(NewScript);
			return;
		}
		// End:0x196
		if(__NFUN_114__(Actions[C.ActionNum], none))
		{
			__NFUN_232__(__NFUN_112__(__NFUN_112__(__NFUN_112__(string(self), " no action "), string(C.ActionNum)), "!!!"));
			C.CurrentAction = none;
			return;
		}
		bDone = Actions[C.ActionNum].InitActionFor(C);
		// End:0x23A
		if(bLoggingEnabled)
		{
			__NFUN_231__(__NFUN_168__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetItemName(string(C.Pawn)), " script "), GetItemName(string(Tag))), " action "), string(C.ActionNum)), Actions[C.ActionNum].GetActionString()));
		}
		// End:0x2C5
		if(__NFUN_129__(bDone))
		{
			// End:0x2A2
			if(__NFUN_114__(Actions[C.ActionNum], none))
			{
				__NFUN_232__(__NFUN_112__(__NFUN_112__(__NFUN_112__(string(self), " has no action "), string(C.ActionNum)), "!!!"));
				C.CurrentAction = none;
				return;
			}
			Actions[C.ActionNum].ProceedToNextAction(C);
		}
		// [Loop Continue]
		goto J0x31;
	}
	return;
}

defaultproperties
{
	ScriptControllerClass=Class'Gameplay.ScriptedController'
	bNavigate=true
	bStatic=false
	bCollideWhenPlacing=true
	bDirectional=true
	CollisionRadius=50.0000000
	CollisionHeight=100.0000000
}
