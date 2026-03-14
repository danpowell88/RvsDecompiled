//=============================================================================
// TetrahedronBuilder: Builds an octahedron (not tetrahedron) - experimental.
//=============================================================================
class TetrahedronBuilder extends BrushBuilder;

// --- Variables ---
var float Radius;
var int SphereExtrapolation;
var name GroupName;

// --- Functions ---
function Extrapolate(float Radius, int Count, int A, int B, int C) {}
function BuildTetrahedron(int SphereExtrapolation, float R) {}
event bool Build() {}
// ^ NEW IN 1.60

defaultproperties
{
}
