//=============================================================================
// VolumetricBuilder: Builds a volumetric brush (criss-crossed sheets).
//=============================================================================
class VolumetricBuilder extends BrushBuilder;

// --- Variables ---
var int NumSheets;
var float Radius;
var float Height;
var name GroupName;

// --- Functions ---
function BuildVolumetric(int NumSheets, float Height, float Radius, int direction) {}
function bool Build() {}
// ^ NEW IN 1.60

defaultproperties
{
}
