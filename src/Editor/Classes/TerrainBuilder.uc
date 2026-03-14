//=============================================================================
// TerrainBuilder: Builds a 3D cube brush, with a tessellated bottom.
//=============================================================================
class TerrainBuilder extends BrushBuilder;

// --- Variables ---
var int DepthSegments;
var int WidthSegments;
var float Breadth;
var float Width;
var float Height;
var name GroupName;

// --- Functions ---
function BuildTerrain(int DepthSeg, int WidthSeg, int direction, float dy, float dx, float dz) {}
event bool Build() {}
// ^ NEW IN 1.60

defaultproperties
{
}
