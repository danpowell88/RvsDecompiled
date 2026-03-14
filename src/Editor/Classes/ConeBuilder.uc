//=============================================================================
// ConeBuilder: Builds a 3D cone brush, compatible with cylinder of same size.
//=============================================================================
class ConeBuilder extends BrushBuilder;

// --- Variables ---
var int Sides;
var float InnerRadius;
var float OuterRadius;
var float Height;
var bool Hollow;
var float CapHeight;
var bool AlignToSide;
var name GroupName;

// --- Functions ---
function BuildCone(int Sides, float Radius, name Item, float Height, int direction, bool AlignToSide) {}
function bool Build() {}
// ^ NEW IN 1.60

defaultproperties
{
}
