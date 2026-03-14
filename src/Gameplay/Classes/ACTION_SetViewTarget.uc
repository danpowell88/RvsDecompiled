//=============================================================================
// ACTION_SetViewTarget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_SetViewTarget extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var Actor ViewTarget;
var(Action) name ViewTargetTag;

function bool InitActionFor(ScriptedController C)
{
	// End:0x2F
	if(__NFUN_254__(ViewTargetTag, 'Enemy'))
	{
		C.ScriptedFocus = C.Enemy;		
	}
	else
	{
		// End:0x62
		if(__NFUN_132__(__NFUN_254__(ViewTargetTag, 'None'), __NFUN_254__(ViewTargetTag, 'None')))
		{
			C.ScriptedFocus = none;			
		}
		else
		{
			// End:0xA1
			if(__NFUN_130__(__NFUN_114__(ViewTarget, none), __NFUN_255__(ViewTargetTag, 'None')))
			{
				// End:0xA0
				foreach C.__NFUN_304__(Class'Engine.Actor', ViewTarget, ViewTargetTag)
				{
					// End:0xA0
					break;					
				}				
			}
			// End:0xBD
			if(__NFUN_114__(ViewTarget, none))
			{
				C.bBroken = true;
			}
			C.ScriptedFocus = ViewTarget;
		}
	}
	return false;
	return;
}

function string GetActionString()
{
	return __NFUN_168__(__NFUN_168__(ActionString, string(ViewTarget)), string(ViewTargetTag));
	return;
}

defaultproperties
{
	bValidForTrigger=false
	ActionString="set viewtarget"
}
