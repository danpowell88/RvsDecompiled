//=============================================================================
// Object to facilitate properties editing
//=============================================================================
class MeshEditProps extends Object
    native;

// --- Structs ---
struct LODLevel
{
    var float DistanceFactor;
    var float ReductionFactor;
    var float Hysteresis;
    var int MaxInfluences;
    var bool SwitchRedigest;
};

// --- Variables ---
var const int WBrowserAnimationPtr;
var Vector Scale;
// ^ NEW IN 1.60
var Vector Translation;
// ^ NEW IN 1.60
var Rotator Rotation;
// ^ NEW IN 1.60
var Vector MinVisBound;
// ^ NEW IN 1.60
var Vector MaxVisBound;
// ^ NEW IN 1.60
var Vector VisSphereCenter;
// ^ NEW IN 1.60
var float VisSphereRadius;
// ^ NEW IN 1.60
var int LODStyle;
// ^ NEW IN 1.60
var MeshAnimation DefaultAnimation;
// ^ NEW IN 1.60
var array<array> Material;
// ^ NEW IN 1.60
var float LOD_Strength;
// ^ NEW IN 1.60
var array<array> LODLevels;
// ^ NEW IN 1.60

defaultproperties
{
}
