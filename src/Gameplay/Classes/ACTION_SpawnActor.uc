//=============================================================================
// ACTION_SpawnActor - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_SpawnActor extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var(Action) bool bOffsetFromScriptedPawn;
var(Action) name ActorTag;
var(Action) Class<Actor> ActorClass;
var(Action) Vector LocationOffset;
var(Action) Rotator RotationOffset;

function bool InitActionFor(ScriptedController C)
{
	local Vector Loc;
	local Rotator Rot;
	local Actor A;

	// End:0x55
	if(bOffsetFromScriptedPawn)
	{
		Loc = (C.Pawn.Location + LocationOffset);
		Rot = (C.Pawn.Rotation + RotationOffset);		
	}
	else
	{
		Loc = (C.SequenceScript.Location + LocationOffset);
		Rot = (C.SequenceScript.Rotation + RotationOffset);
	}
	A = C.Spawn(ActorClass,,, Loc, Rot);
	A.Instigator = C.Pawn;
	// End:0x101
	if((ActorTag != 'None'))
	{
		A.Tag = ActorTag;
	}
	return false;
	return;
}

function string GetActionString()
{
	return (ActionString @ string(ActorClass));
	return;
}

defaultproperties
{
	ActionString="Spawn actor"
}
