//=============================================================================
// TexModifier - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class TexModifier extends Modifier
	native
	noteditinlinenew
	collapsecategories
 hidecategories(Object,Material);

enum ETexCoordSrc
{
	TCS_Stream0,                    // 0
	TCS_Stream1,                    // 1
	TCS_Stream2,                    // 2
	TCS_Stream3,                    // 3
	TCS_Stream4,                    // 4
	TCS_Stream5,                    // 5
	TCS_Stream6,                    // 6
	TCS_Stream7,                    // 7
	TCS_WorldCoords,                // 8
	TCS_CameraCoords,               // 9
	TCS_WorldEnvMapCoords,          // 10
	TCS_CameraEnvMapCoords,         // 11
	TCS_ProjectorCoords,            // 12
	TCS_NoChange,                   // 13
	TCS_NormalViewSpaceEnvMap       // 14
};

enum ETexCoordCount
{
	TCN_2DCoords,                   // 0
	TCN_3DCoords,                   // 1
	TCN_4DCoords                    // 2
};

// NEW IN 1.60
var TexModifier.ETexCoordSrc TexCoordSource;
// NEW IN 1.60
var TexModifier.ETexCoordCount TexCoordCount;
var bool TexCoordProjected;

defaultproperties
{
	TexCoordSource=13
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var ETexCoordSrc
// REMOVED IN 1.60: var ETexCoordCount
