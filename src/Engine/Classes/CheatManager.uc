//=============================================================================
// CheatManager
// Object within playercontroller that manages "cheat" commands
// only spawned in single player mode
//=============================================================================
class CheatManager extends Object
    native;

// --- Variables ---
//R6CODE+
var bool m_bUnlockAllCheat;
var Rotator LockedRotation;

// --- Functions ---
// function ? Amphibious(...); // REMOVED IN 1.60
// function ? Avatar(...); // REMOVED IN 1.60
// function ? CauseEvent(...); // REMOVED IN 1.60
// function ? ChangeSize(...); // REMOVED IN 1.60
// function ? CheatView(...); // REMOVED IN 1.60
// function ? EndPath(...); // REMOVED IN 1.60
// function ? Fly(...); // REMOVED IN 1.60
// function ? FreeCamera(...); // REMOVED IN 1.60
// function ? FreezeFrame(...); // REMOVED IN 1.60
// function ? Ghost(...); // REMOVED IN 1.60
// function ? Invisible(...); // REMOVED IN 1.60
// function ? KillPawns(...); // REMOVED IN 1.60
// function ? Loaded(...); // REMOVED IN 1.60
// function ? LockCamera(...); // REMOVED IN 1.60
// function ? LogScriptedSequences(...); // REMOVED IN 1.60
// function ? PlayersOnly(...); // REMOVED IN 1.60
// function ? RememberSpot(...); // REMOVED IN 1.60
// function ? SetCameraDist(...); // REMOVED IN 1.60
// function ? SetDebugSpeed(...); // REMOVED IN 1.60
// function ? SetFlash(...); // REMOVED IN 1.60
// function ? SetFogB(...); // REMOVED IN 1.60
// function ? SetFogG(...); // REMOVED IN 1.60
// function ? SetFogR(...); // REMOVED IN 1.60
// function ? SetGravity(...); // REMOVED IN 1.60
// function ? SetJumpZ(...); // REMOVED IN 1.60
// function ? Summon(...); // REMOVED IN 1.60
// function ? Teleport(...); // REMOVED IN 1.60
// function ? ViewBot(...); // REMOVED IN 1.60
// function ? ViewPlayer(...); // REMOVED IN 1.60
// function ? Walk(...); // REMOVED IN 1.60
// function ? WriteToLog(...); // REMOVED IN 1.60
exec function SloMo(float t) {}
exec function ViewSelf(optional bool bQuiet) {}
exec function ViewActor(name ActorName) {}
exec function KillAll(class<Actor> aClass) {}
// Kill non-player pawns and their controllers
function KillAllPawns(class<Pawn> aClass) {}
exec function ViewClass(optional bool bQuiet, optional bool bCheat, class<Actor> aClass) {}
function bool CanExec() {}
// ^ NEW IN 1.60
// R6CODE +
exec event LogThis(optional bool bDontTraceActor, optional Actor anActor) {}

defaultproperties
{
}
