// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class Combiner extends Material
    native;

// --- Enums ---
enum EAlphaOperation
{
	AO_Use_Mask,
	AO_Multiply,
	AO_Add,
	AO_Use_Alpha_From_Material1,
	AO_Use_Alpha_From_Material2,
};
enum EColorOperation
{
	CO_Use_Color_From_Material1,
	CO_Use_Color_From_Material2,
	CO_Multiply,
	CO_Add,
	CO_Subtract,
	CO_AlphaBlend_With_Mask,
	CO_Add_With_Mask_Modulation,
        CO_Use_Color_From_Mask,
//#ifdef R6BUMPWEAPON
	CO_Bump,
//#endif
};

// --- Variables ---
var EColorOperation CombineOperation;
var EAlphaOperation AlphaOperation;
var Material Material1;
var Material Material2;
var Material Mask;
var bool InvertMask;
var bool Modulate2X;
var bool Modulate4X;

defaultproperties
{
}
