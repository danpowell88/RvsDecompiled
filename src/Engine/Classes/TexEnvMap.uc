//=============================================================================
// TexEnvMap - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class TexEnvMap extends TexModifier
    native
	editinlinenew
    collapsecategories
    hidecategories(Object,Material);

enum ETexEnvMapType
{
	EM_WorldSpace,                  // 0
	EM_CameraSpace                  // 1
};

// NEW IN 1.60
var() TexEnvMap.ETexEnvMapType EnvMapType;

defaultproperties
{
	EnvMapType=1
	TexCoordCount=1
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var ETexEnvMapType
