//=============================================================================
// KBSJoint - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// The Ball-and-Socket joint class.
//=============================================================================

#exec Texture Import File=Textures\S_KBSJoint.pcx Name=S_KBSJoint Mips=Off MASKED=1
class KBSJoint extends KConstraint
    native
    placeable;

defaultproperties
{
	Texture=Texture'Engine.S_KBSJoint'
}
