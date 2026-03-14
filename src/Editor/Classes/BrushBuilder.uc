//=============================================================================
// BrushBuilder: Base class of UnrealEd brush builders.
//
// Tips for writing brush builders:
//
// * Always validate the user-specified and call BadParameters function
//   if anything is wrong, instead of actually building geometry.
//   If you build an invalid brush due to bad user parameters, you'll
//   cause an extraordinary amount of pain for the poor user.
//
// * When generating polygons with more than 3 vertices, BE SURE all the
//   polygon's vertices are coplanar!  Out-of-plane polygons will cause
//   geometry to be corrupted.
//=============================================================================
class BrushBuilder extends Object
    native
    abstract;

// --- Structs ---
struct BuilderPoly
{
	var array<int> VertexIndices;
	var int Direction;
	var name Item;
	var int PolyFlags;
};

// --- Variables ---
// var ? Direction; // REMOVED IN 1.60
// var ? Item; // REMOVED IN 1.60
// var ? PolyFlags; // REMOVED IN 1.60
// var ? VertexIndices; // REMOVED IN 1.60
var bool MergeCoplanars;
var name Group;
var array<array> Polys;
var array<array> Vertices;
var string ToolTip;
// ^ NEW IN 1.60
var string BitmapFilename;
// ^ NEW IN 1.60

// --- Functions ---
// Build interface.
event bool Build() {}
// ^ NEW IN 1.60
native function Poly3i(int direction, int i, int j, int k, optional name ItemName, optional int PolyFlags) {}
native function Poly4i(optional int PolyFlags, optional name ItemName, int L, int k, int j, int i, int direction) {}
native function int Vertex3f(float X, float Y, float Z) {}
// ^ NEW IN 1.60
native function int Vertexv(Vector V) {}
// ^ NEW IN 1.60
// Native support.
native function BeginBrush(name Group, bool MergeCoplanars) {}
native function bool BadParameters(optional string Msg) {}
// ^ NEW IN 1.60
native function Vector GetVertex(int i) {}
// ^ NEW IN 1.60
native function PolyBegin(optional int PolyFlags, optional name ItemName, int direction) {}
native function Polyi(int i) {}
native function PolyEnd() {}
native function int GetPolyCount() {}
// ^ NEW IN 1.60
native function int GetVertexCount() {}
// ^ NEW IN 1.60
native function bool EndBrush() {}
// ^ NEW IN 1.60

defaultproperties
{
}
