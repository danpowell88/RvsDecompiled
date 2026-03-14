//=============================================================================
// CheatManager - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// CheatManager
// Object within playercontroller that manages "cheat" commands
// only spawned in single player mode
//=============================================================================
class CheatManager extends Object within PlayerController
    native;

//R6CODE+
var bool m_bUnlockAllCheat;
var Rotator LockedRotation;

function bool CanExec()
{
	// End:0x0B
	if(m_bUnlockAllCheat)
	{
		return true;
	}
	// End:0x44
	if(__NFUN_154__(int(Outer.Level.NetMode), int(NM_Client)))
	{
		Outer.ClientErrorMessageLocalized("Exec");
		return false;
	}
	// End:0x68
	if(__NFUN_154__(int(Outer.Level.NetMode), int(NM_Standalone)))
	{
		return true;
	}
	Outer.ClientErrorMessageLocalized("Exec");
	return false;
	return;
}

exec function SloMo(float t)
{
	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	Outer.Level.Game.SetGameSpeed(t);
	Outer.Level.Game.__NFUN_536__();
	Outer.Level.Game.GameReplicationInfo.__NFUN_536__();
	return;
}

exec function KillAll(Class<Actor> aClass)
{
	local Actor A;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x2F
	if(__NFUN_258__(aClass, Class'Engine.Pawn'))
	{
		KillAllPawns(Class<Pawn>(aClass));
		return;
	}
	// End:0x6E
	foreach Outer.__NFUN_313__(Class'Engine.Actor', A)
	{
		// End:0x6D
		if(__NFUN_258__(A.Class, aClass))
		{
			A.__NFUN_279__();
		}		
	}	
	return;
}

// Kill non-player pawns and their controllers
function KillAllPawns(Class<Pawn> aClass)
{
	local Pawn P;

	// End:0x7E
	foreach Outer.__NFUN_313__(Class'Engine.Pawn', P)
	{
		// End:0x7D
		if(__NFUN_130__(__NFUN_258__(P.Class, aClass), __NFUN_129__(P.IsHumanControlled())))
		{
			// End:0x71
			if(__NFUN_119__(P.Controller, none))
			{
				P.Controller.__NFUN_279__();
			}
			P.__NFUN_279__();
		}		
	}	
	return;
}

exec function ViewSelf(optional bool bQuiet)
{
	Outer.bBehindView = false;
	// End:0x45
	if(__NFUN_119__(Outer.Pawn, none))
	{
		Outer.SetViewTarget(Outer.Pawn);		
	}
	else
	{
		Outer.SetViewTarget(Outer);
	}
	// End:0x86
	if(__NFUN_129__(bQuiet))
	{
		Outer.ClientMessage(Outer.OwnCamera, 'Event');
	}
	Outer.FixFOV();
	return;
}

exec function ViewActor(name ActorName)
{
	local Actor A;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x67
	foreach Outer.__NFUN_304__(Class'Engine.Actor', A)
	{
		// End:0x66
		if(__NFUN_254__(A.Name, ActorName))
		{
			Outer.SetViewTarget(A);
			Outer.bBehindView = true;			
			return;
		}		
	}	
	return;
}

exec function ViewClass(Class<Actor> aClass, optional bool bQuiet, optional bool bCheat)
{
	local Actor Other, first;
	local bool bFound;

	// End:0x0D
	if(__NFUN_129__(CanExec()))
	{
		return;
	}
	// End:0x61
	if(__NFUN_130__(__NFUN_130__(__NFUN_129__(bCheat), __NFUN_119__(Outer.Level.Game, none)), __NFUN_129__(Outer.Level.Game.bCanViewOthers)))
	{
		return;
	}
	first = none;
	// End:0xF8
	foreach Outer.__NFUN_304__(aClass, Other)
	{
		// End:0xD7
		if(__NFUN_132__(bFound, __NFUN_114__(first, none)))
		{
			// End:0xD7
			if(__NFUN_132__(__NFUN_114__(Pawn(Other), none), Pawn(Other).IsAlive()))
			{
				first = Other;
				// End:0xD7
				if(bFound)
				{
					// End:0xF8
					break;
				}
			}
		}
		// End:0xF7
		if(__NFUN_114__(Other, Outer.ViewTarget))
		{
			bFound = true;
		}		
	}	
	// End:0x1F5
	if(__NFUN_119__(first, none))
	{
		// End:0x180
		if(__NFUN_129__(bQuiet))
		{
			// End:0x155
			if(__NFUN_119__(Pawn(first), none))
			{
				Outer.ClientMessage(__NFUN_168__(Outer.ViewingFrom, first.GetHumanReadableName()), 'Event');				
			}
			else
			{
				Outer.ClientMessage(__NFUN_168__(Outer.ViewingFrom, string(first)), 'Event');
			}
		}
		Outer.SetViewTarget(first);
		Outer.bBehindView = __NFUN_119__(Outer.ViewTarget, Outer);
		// End:0x1E3
		if(Outer.bBehindView)
		{
			Outer.ViewTarget.BecomeViewTarget();
		}
		Outer.FixFOV();		
	}
	else
	{
		ViewSelf(bQuiet);
	}
	return;
}

// R6CODE +
exec event LogThis(optional bool bDontTraceActor, optional Actor anActor)
{
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function FreezeFrame
// REMOVED IN 1.60: function WriteToLog
// REMOVED IN 1.60: function SetFlash
// REMOVED IN 1.60: function SetFogR
// REMOVED IN 1.60: function SetFogG
// REMOVED IN 1.60: function SetFogB
// REMOVED IN 1.60: function LogScriptedSequences
// REMOVED IN 1.60: function Teleport
// REMOVED IN 1.60: function ChangeSize
// REMOVED IN 1.60: function LockCamera
// REMOVED IN 1.60: function SetCameraDist
// REMOVED IN 1.60: function EndPath
// REMOVED IN 1.60: function FreeCamera
// REMOVED IN 1.60: function CauseEvent
// REMOVED IN 1.60: function Amphibious
// REMOVED IN 1.60: function Fly
// REMOVED IN 1.60: function Walk
// REMOVED IN 1.60: function Ghost
// REMOVED IN 1.60: function Invisible
// REMOVED IN 1.60: function SetJumpZ
// REMOVED IN 1.60: function SetGravity
// REMOVED IN 1.60: function SetDebugSpeed
// REMOVED IN 1.60: function KillPawns
// REMOVED IN 1.60: function Avatar
// REMOVED IN 1.60: function Summon
// REMOVED IN 1.60: function PlayersOnly
// REMOVED IN 1.60: function CheatView
// REMOVED IN 1.60: function RememberSpot
// REMOVED IN 1.60: function ViewPlayer
// REMOVED IN 1.60: function ViewBot
// REMOVED IN 1.60: function Loaded
