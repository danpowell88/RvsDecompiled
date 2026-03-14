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
		Loc = __NFUN_215__(C.Pawn.Location, LocationOffset);
		Rot = __NFUN_316__(C.Pawn.Rotation, RotationOffset);		
	}
	else
	{
		Loc = __NFUN_215__(C.SequenceScript.Location, LocationOffset);
		Rot = __NFUN_316__(C.SequenceScript.Rotation, RotationOffset);
	}
	A = C.__NFUN_278__(ActorClass,,, Loc, Rot);
	A.Instigator = C.Pawn;
	// End:0x101
	if(__NFUN_255__(ActorTag, 'None'))
	{
		A.Tag = ActorTag;
	}
	return false;
	return;
}

function string GetActionString()
{
	return __NFUN_168__(ActionString, string(ActorClass));
	return;
}

defaultproperties
{
	ActionString="Spawn actor"
}
