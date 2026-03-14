//=============================================================================
// DecorationList:  Defines a list of decorations which can be attached to volumes
//=============================================================================
class DecorationList extends Keypoint
    native;

#exec Texture Import File=Textures\DecorationList.pcx Name=S_DecorationList Mips=Off MASKED=1

// --- Structs ---
struct DecorationType
{
	var() StaticMesh	StaticMesh;
	var() range			Count;
	var() range			DrawScale;
	var() int			bAlign;
	var() int			bRandomPitch;
	var() int			bRandomYaw;
	var() int			bRandomRoll;
};

// --- Variables ---
var array<array> Decorations;

defaultproperties
{
}
