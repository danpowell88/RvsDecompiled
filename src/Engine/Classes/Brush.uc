//=============================================================================
// The brush class.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Brush extends Actor
    native;

// --- Enums ---
enum ECsgOper
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var ECsgOper CsgOper;
// ^ NEW IN 1.60
// Outdated.
var const Object UnusedLightMesh;
var Vector PostPivot;
// Scaling.
// Outdated : these are only here to allow the "ucc mapconvert" commandlet to work.
//            They are NOT used by the engine/editor for anything else.
var Scale MainScale;
var Scale PostScale;
var Scale TempScale;
var Color BrushColor;
// ^ NEW IN 1.60
var int PolyFlags;
// ^ NEW IN 1.60
var bool bColored;
// ^ NEW IN 1.60

defaultproperties
{
}
