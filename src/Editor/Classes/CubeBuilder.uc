//=============================================================================
// CubeBuilder: Builds a 3D cube brush.
//=============================================================================
class CubeBuilder extends BrushBuilder;

// --- Variables ---
var float WallThickness;
var float Breadth;
var float Width;
var float Height;
var bool Hollow;
var bool Tessellated;
var name GroupName;

// --- Functions ---
function BuildCube(int direction, float dz, float dx, float dy, bool _tessellated) {}
event bool Build() {}
// ^ NEW IN 1.60

defaultproperties
{
}
