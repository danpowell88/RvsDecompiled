// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class AnimNotify_Effect extends AnimNotify
    native;

// --- Variables ---
var class<Actor> EffectClass;
// ^ NEW IN 1.60
var name Bone;
// ^ NEW IN 1.60
var Vector OffsetLocation;
// ^ NEW IN 1.60
var Rotator OffsetRotation;
// ^ NEW IN 1.60
var bool Attach;
// ^ NEW IN 1.60
var name Tag;
// ^ NEW IN 1.60
var float DrawScale;
// ^ NEW IN 1.60
var Vector DrawScale3D;
// ^ NEW IN 1.60
// Valid only in the editor.
var transient Actor LastSpawnedEffect;

defaultproperties
{
}
