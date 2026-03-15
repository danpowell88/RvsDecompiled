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
	if((ViewTargetTag == 'Enemy'))
	{
		C.ScriptedFocus = C.Enemy;		
	}
	else
	{
		// End:0x62
		if(((ViewTargetTag == 'None') || (ViewTargetTag == 'None')))
		{
			C.ScriptedFocus = none;			
		}
		else
		{
			// End:0xA1
			if(((ViewTarget == none) && (ViewTargetTag != 'None')))
			{
				// End:0xA0
				foreach C.AllActors(Class'Engine.Actor', ViewTarget, ViewTargetTag)
				{
					// End:0xA0
					break;					
				}				
			}
			// End:0xBD
			if((ViewTarget == none))
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
	return ((ActionString @ string(ViewTarget)) @ string(ViewTargetTag));
	return;
}

defaultproperties
{
	bValidForTrigger=false
	ActionString="set viewtarget"
}
