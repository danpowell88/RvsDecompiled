//=============================================================================
// SavedMove is used during network play to buffer recent client moves,
// for use when the server modifies the clients actual position, etc.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class SavedMove extends Info
    native;

// --- Variables ---
// also stores info in Acceleration attribute
// Next move in linked list.
var SavedMove NextMove;
// Distance moved.
var float Delta;
//rb var bool	bPressedJump;
// Double click info.
var EDoubleClickDir DoubleClickMove;
// #ifdef R6PlayerMovements
var bool m_bCrawl;
var bool bDuck;
// Time of this move.
var float TimeStamp;
var bool bRun;

// --- Functions ---
final function Clear() {}
final function SetMoveFor(Vector NewAccel, PlayerController P, float DeltaTime, EDoubleClickDir InDoubleClick) {}

defaultproperties
{
}
