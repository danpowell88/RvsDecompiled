//=============================================================================
// BrushBuilder - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
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
    abstract
    native;

struct BuilderPoly
{
	var array<int> VertexIndices;
	var int direction;
	var name Item;
	var int PolyFlags;
};

var private bool MergeCoplanars;
var private name Group;
var array<Vector> Vertices;
var array<BuilderPoly> Polys;
var() string BitmapFilename;
var() string ToolTip;

// Export UBrushBuilder::execBeginBrush(FFrame&, void* const)
// Native support.
native function BeginBrush(bool MergeCoplanars, name Group);

// Export UBrushBuilder::execEndBrush(FFrame&, void* const)
native function bool EndBrush();

// Export UBrushBuilder::execGetVertexCount(FFrame&, void* const)
native function int GetVertexCount();

// Export UBrushBuilder::execGetVertex(FFrame&, void* const)
native function Vector GetVertex(int i);

// Export UBrushBuilder::execGetPolyCount(FFrame&, void* const)
native function int GetPolyCount();

// Export UBrushBuilder::execBadParameters(FFrame&, void* const)
native function bool BadParameters(optional string Msg);

// Export UBrushBuilder::execVertexv(FFrame&, void* const)
native function int Vertexv(Vector V);

// Export UBrushBuilder::execVertex3f(FFrame&, void* const)
native function int Vertex3f(float X, float Y, float Z);

// Export UBrushBuilder::execPoly3i(FFrame&, void* const)
native function Poly3i(int direction, int i, int j, int k, optional name ItemName, optional int PolyFlags);

// Export UBrushBuilder::execPoly4i(FFrame&, void* const)
native function Poly4i(int direction, int i, int j, int k, int L, optional name ItemName, optional int PolyFlags);

// Export UBrushBuilder::execPolyBegin(FFrame&, void* const)
native function PolyBegin(int direction, optional name ItemName, optional int PolyFlags);

// Export UBrushBuilder::execPolyi(FFrame&, void* const)
native function Polyi(int i);

// Export UBrushBuilder::execPolyEnd(FFrame&, void* const)
native function PolyEnd();

// Build interface.
event bool Build()
{
	return;
}

defaultproperties
{
	BitmapFilename="BBGeneric"
	ToolTip="Generic Builder"
}
