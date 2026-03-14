//
// OpacityModifier — material modifier that overrides the opacity channel of a shader.
// Used with terrain shaders and other material chains to inject a custom opacity
// texture without modifying the base material asset.
// Extracted from retail Engine.u.
//
// OpacityModfifer - used to override a shader's opacity channel (eg for shaders on terrain).
//
class OpacityModifier extends Modifier
    native;

// --- Variables ---
var Material Opacity;
var bool bOverrideTexModifier;

defaultproperties
{
}
