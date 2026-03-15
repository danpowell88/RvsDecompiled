//=============================================================================
// SubActionTrigger - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// SubActionTrigger:
//
// Fires off a trigger.
//=============================================================================
class SubActionTrigger extends MatSubAction
    native
	editinlinenew;

var(Trigger) name EventName;  // The event to trigger

defaultproperties
{
	Icon=Texture'Engine.SubActionTrigger'
	Desc="Trigger"
}
