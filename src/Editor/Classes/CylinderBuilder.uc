//=============================================================================
// CylinderBuilder: Builds a 3D cylinder brush.
//=============================================================================
class CylinderBuilder extends BrushBuilder;

// --- Variables ---
var int Sides;
var float InnerRadius;
var float OuterRadius;
var float Height;
var bool Hollow;
var bool AlignToSide;
var name GroupName;

// --- Functions ---
function BuildCylinder(int Sides, float Radius, bool AlignToSide, float Height, int direction) {}
function bool Build() {}
// ^ NEW IN 1.60

defaultproperties
{
}
