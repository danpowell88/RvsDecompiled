//=============================================================================
// Brush - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// The brush class.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Brush extends Actor
	native
 notplaceable;

enum ECsgOper
{
	CSG_Active,                     // 0
	CSG_Add,                        // 1
	CSG_Subtract,                   // 2
	CSG_Intersect,                  // 3
	CSG_Deintersect                 // 4
};

// NEW IN 1.60
var() Brush.ECsgOper CsgOper;
var() int PolyFlags;
var() bool bColored;
// Outdated.
var const Object UnusedLightMesh;
var Vector PostPivot;
// Scaling.
// Outdated : these are only here to allow the "ucc mapconvert" commandlet to work.
//            They are NOT used by the engine/editor for anything else.
var Scale MainScale;
var Scale PostScale;
var Scale TempScale;
// Information.
var() Color BrushColor;

defaultproperties
{
	MainScale=(Scale=(X=1.0000000,Y=1.0000000,Z=1.0000000))
	PostScale=(Scale=(X=1.0000000,Y=1.0000000,Z=1.0000000))
	TempScale=(Scale=(X=1.0000000,Y=1.0000000,Z=1.0000000))
	DrawType=3
	bStatic=true
	bHidden=true
	bNoDelete=true
	bFixedRotationDir=true
	bEdShouldSnap=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var ECsgOper
