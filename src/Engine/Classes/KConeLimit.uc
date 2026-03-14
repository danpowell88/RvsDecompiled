//=============================================================================
// The Cone Limit joint class.
//=============================================================================
class KConeLimit extends KConstraint
    native;

#exec Texture Import File=Textures\S_KConeLimit.pcx Name=S_KConeLimit Mips=Off MASKED=1

// --- Variables ---
var float KHalfAngle;
var float KStiffness;
var float KDamping;

defaultproperties
{
}
