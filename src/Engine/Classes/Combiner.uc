//=============================================================================
// Combiner - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class Combiner extends Material
    native
	editinlinenew
    collapsecategories
    hidecategories(Object);

enum EColorOperation
{
	CO_Use_Color_From_Material1,    // 0
	CO_Use_Color_From_Material2,    // 1
	CO_Multiply,                    // 2
	CO_Add,                         // 3
	CO_Subtract,                    // 4
	CO_AlphaBlend_With_Mask,        // 5
	CO_Add_With_Mask_Modulation,    // 6
	CO_Use_Color_From_Mask,         // 7
	CO_Bump                         // 8
};

enum EAlphaOperation
{
	AO_Use_Mask,                    // 0
	AO_Multiply,                    // 1
	AO_Add,                         // 2
	AO_Use_Alpha_From_Material1,    // 3
	AO_Use_Alpha_From_Material2     // 4
};

var() Combiner.EColorOperation CombineOperation;
var() Combiner.EAlphaOperation AlphaOperation;
var() bool InvertMask;
var() bool Modulate2X;
var() bool Modulate4X;
var() editinlineuse Material Material1;
var() editinlineuse Material Material2;
var() editinlineuse Material Mask;

