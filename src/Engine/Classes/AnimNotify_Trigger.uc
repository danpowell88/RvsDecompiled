//=============================================================================
// AnimNotify_Trigger - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class AnimNotify_Trigger extends AnimNotify_Scripted
	editinlinenew
	collapsecategories
 hidecategories(Object);

var() name EventName;

event Notify(Actor Owner)
{
	Owner.TriggerEvent(EventName, Owner, Pawn(Owner));
	return;
}

